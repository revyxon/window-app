import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import '../services/api_service.dart';
import '../utils/app_colors.dart';

class PublishUpdateScreen extends StatefulWidget {
  const PublishUpdateScreen({super.key});

  @override
  State<PublishUpdateScreen> createState() => _PublishUpdateScreenState();
}

class _PublishUpdateScreenState extends State<PublishUpdateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _versionController = TextEditingController();
  final _buildNumberController = TextEditingController();
  final _releaseNotesController = TextEditingController();

  PlatformFile? _selectedFile;
  bool _isUploading = false;
  double _uploadProgress = 0;
  bool _forceUpdate = false;
  bool _skipAllowed = true;

  @override
  void dispose() {
    _versionController.dispose();
    _buildNumberController.dispose();
    _releaseNotesController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['apk'],
    );

    if (result != null) {
      setState(() {
        _selectedFile = result.files.first;
      });
    }
  }

  String? _validateVersion(String? value) {
    if (value == null || value.isEmpty) return 'Required';
    final regExp = RegExp(r'^\d+\.\d+\.\d+$');
    if (!regExp.hasMatch(value)) return 'Use MAJOR.MINOR.PATCH (e.g. 1.0.5)';
    return null;
  }

  Future<void> _publishUpdate() async {
    if (!_formKey.currentState!.validate() || _selectedFile == null) {
      if (_selectedFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an APK file')),
        );
      }
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.1;
    });

    try {
      // 1. Get signed URL
      final urlResponse = await ApiService().getUploadUrl(_selectedFile!.name);
      final uploadUrl = urlResponse['uploadUrl'];
      final fileUrl = urlResponse['fileUrl'];

      setState(() => _uploadProgress = 0.3);

      // 2. Upload file
      final fileBytes =
          _selectedFile!.bytes ??
          await File(_selectedFile!.path!).readAsBytes();
      await ApiService().uploadFile(uploadUrl, fileBytes);

      setState(() => _uploadProgress = 0.7);

      // 3. Create update entry
      await ApiService().createUpdate(
        version: _versionController.text,
        buildNumber: int.parse(_buildNumberController.text),
        apkUrl: fileUrl,
        fileSize: _selectedFile!.size,
        releaseNotes: _releaseNotesController.text,
        forceUpdate: _forceUpdate,
        skipAllowed: _skipAllowed,
      );

      setState(() => _uploadProgress = 1.0);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✓ Update published successfully!')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Publish Update'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: _isUploading
          ? _buildUploadingUI()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('APK FILE'),
                    _buildFilePicker(),
                    const SizedBox(height: 32),
                    _buildSectionHeader('VERSION INFO'),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: _buildTextField(
                            controller: _versionController,
                            label: 'Version',
                            hint: '1.0.0',
                            validator: _validateVersion,
                            icon: FluentIcons.tag_24_regular,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            controller: _buildNumberController,
                            label: 'Build',
                            hint: '1',
                            keyboardType: TextInputType.number,
                            icon: FluentIcons.number_row_24_regular,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader('UPDATE SETTINGS'),
                    _buildToggleTile(
                      title: 'Force Update',
                      subtitle: 'Users must update to continue using the app',
                      value: _forceUpdate,
                      onChanged: (v) => setState(() => _forceUpdate = v),
                      icon: FluentIcons.lock_closed_24_regular,
                    ),
                    _buildToggleTile(
                      title: 'Skip Allowed',
                      subtitle: 'Allow users to skip this update (max 3 times)',
                      value: _skipAllowed,
                      onChanged: (v) => setState(() => _skipAllowed = v),
                      icon: FluentIcons.dismiss_24_regular,
                    ),
                    const SizedBox(height: 32),
                    _buildSectionHeader('RELEASE NOTES (MARKDOWN)'),
                    _buildTextField(
                      controller: _releaseNotesController,
                      label: 'Release Notes',
                      hint: 'Describe what\'s new in this version...',
                      maxLines: 5,
                    ),
                    const SizedBox(height: 48),
                    _buildPublishButton(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Colors.grey.shade600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildFilePicker() {
    return InkWell(
      onTap: _pickFile,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(
              _selectedFile != null
                  ? FluentIcons.folder_24_regular
                  : FluentIcons.arrow_upload_24_regular,
              size: 48,
              color: _selectedFile != null ? AppColors.primary : Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              _selectedFile?.name ?? 'Select APK File',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _selectedFile != null
                    ? Colors.black
                    : Colors.grey.shade600,
              ),
            ),
            if (_selectedFile != null) ...[
              const SizedBox(height: 4),
              Text(
                '${(_selectedFile!.size / (1024 * 1024)).toStringAsFixed(2)} MB',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    IconData? icon,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator ?? (v) => v?.isEmpty == true ? 'Required' : null,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: icon != null ? Icon(icon, size: 20) : null,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
      ),
    );
  }

  Widget _buildToggleTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        secondary: Icon(icon, color: value ? AppColors.primary : Colors.grey),
        activeThumbColor: AppColors.primary,
      ),
    );
  }

  Widget _buildPublishButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _publishUpdate,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Publish Update Now',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildUploadingUI() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(
                strokeWidth: 6,
                color: Colors.black,
                backgroundColor: Color(0xFFE5E7EB),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Publishing Update...',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Uploading APK and saving metadata',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 32),
            LinearProgressIndicator(
              value: _uploadProgress,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation(Colors.black),
              borderRadius: BorderRadius.circular(10),
              minHeight: 10,
            ),
            const SizedBox(height: 12),
            Text('${(_uploadProgress * 100).toInt()}% Complete'),
          ],
        ),
      ),
    );
  }
}
