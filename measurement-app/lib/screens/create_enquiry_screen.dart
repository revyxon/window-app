import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import '../models/enquiry.dart';
import '../providers/app_provider.dart';
import '../widgets/premium_toast.dart';

class CreateEnquiryScreen extends StatefulWidget {
  const CreateEnquiryScreen({super.key});

  @override
  State<CreateEnquiryScreen> createState() => _CreateEnquiryScreenState();
}

class _CreateEnquiryScreenState extends State<CreateEnquiryScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _requirementsController = TextEditingController();
  final _expectedWindowsController = TextEditingController();
  final _notesController = TextEditingController();

  // FocusNodes
  final _nameFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _locationFocus = FocusNode();
  final _requirementsFocus = FocusNode();
  final _expectedWindowsFocus = FocusNode();
  final _notesFocus = FocusNode();

  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _requirementsController.dispose();
    _expectedWindowsController.dispose();
    _notesController.dispose();
    _nameFocus.dispose();
    _phoneFocus.dispose();
    _locationFocus.dispose();
    _requirementsFocus.dispose();
    _expectedWindowsFocus.dispose();
    _notesFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'New Enquiry',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.black,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          children: [
            // Name
            TextFormField(
              controller: _nameController,
              focusNode: _nameFocus,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) =>
                  FocusScope.of(context).requestFocus(_phoneFocus),
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 18,
                color: Color(0xFF1F2937),
              ),
              decoration: _buildInputDecoration(
                'Customer Name *',
                Icons.person_outline_rounded,
              ),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Please enter name' : null,
            ),
            const SizedBox(height: 16),

            // Phone
            TextFormField(
              controller: _phoneController,
              focusNode: _phoneFocus,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) =>
                  FocusScope.of(context).requestFocus(_locationFocus),
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 18,
                color: Color(0xFF1F2937),
              ),
              decoration: _buildInputDecoration(
                'Phone (Optional)',
                Icons.phone_outlined,
              ),
            ),
            const SizedBox(height: 16),

            // Location
            TextFormField(
              controller: _locationController,
              focusNode: _locationFocus,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) =>
                  FocusScope.of(context).requestFocus(_requirementsFocus),
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 18,
                color: Color(0xFF1F2937),
              ),
              decoration: _buildInputDecoration(
                'Location / Area *',
                Icons.location_on_outlined,
              ),
              validator: (value) => value == null || value.isEmpty
                  ? 'Please enter location'
                  : null,
            ),
            const SizedBox(height: 16),

            // Requirements
            TextFormField(
              controller: _requirementsController,
              focusNode: _requirementsFocus,
              textInputAction: TextInputAction.next,
              maxLines: 2,
              onFieldSubmitted: (_) =>
                  FocusScope.of(context).requestFocus(_expectedWindowsFocus),
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 18,
                color: Color(0xFF1F2937),
                height: 1.3,
              ),
              decoration: _buildInputDecoration(
                'Requirements (e.g. 5 Windows, 2 Doors)',
                Icons.assignment_outlined,
              ),
            ),
            const SizedBox(height: 16),

            // Expected Windows / Count
            TextFormField(
              controller: _expectedWindowsController,
              focusNode: _expectedWindowsFocus,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) =>
                  FocusScope.of(context).requestFocus(_notesFocus),
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 18,
                color: Color(0xFF1F2937),
              ),
              decoration: _buildInputDecoration(
                'Expected Windows (Optional)',
                Icons.grid_view_rounded,
              ),
            ),
            const SizedBox(height: 16),

            // Notes
            TextFormField(
              controller: _notesController,
              focusNode: _notesFocus,
              textInputAction: TextInputAction.done,
              maxLines: 3,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 18,
                color: Color(0xFF1F2937),
                height: 1.3,
              ),
              decoration: _buildInputDecoration(
                'Optional Notes',
                Icons.note_alt_outlined,
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: SizedBox(
            height: 54,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _isSaving ? null : _saveEnquiry,
              child: _isSaving
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Create Enquiry',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      alignLabelWithHint: true,
      labelStyle: const TextStyle(
        color: Color(0xFF6B7280),
        fontSize: 17,
        fontWeight: FontWeight.w400,
      ),
      floatingLabelStyle: const TextStyle(
        color: Color(0xFF2563EB),
        fontSize: 15,
        fontWeight: FontWeight.w600,
        backgroundColor: Colors.white,
      ),
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      prefixIcon: Padding(
        padding: const EdgeInsets.only(left: 14, right: 10),
        child: Icon(icon, color: const Color(0xFF374151), size: 26),
      ),
      prefixIconConstraints: const BoxConstraints(minWidth: 50, minHeight: 50),
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      isCollapsed: false,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
      ),
      errorStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
    );
  }

  Future<void> _saveEnquiry() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);

      final enquiry = Enquiry.create(
        name: _nameController.text.trim(),
        location: _locationController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        requirements: _requirementsController.text.trim().isEmpty
            ? null
            : _requirementsController.text.trim(),
        expectedWindows: _expectedWindowsController.text.trim().isEmpty
            ? null
            : _expectedWindowsController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      try {
        await Provider.of<AppProvider>(
          context,
          listen: false,
        ).addEnquiry(enquiry);
        if (!mounted) return;
        Navigator.pop(context);
        ToastService.show(context, 'Enquiry created successfully!');
      } catch (e) {
        if (!mounted) return;
        setState(() => _isSaving = false);
        ToastService.show(context, 'Error creating enquiry: $e', isError: true);
      }
    }
  }
}
