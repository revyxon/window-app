import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import '../services/update_service.dart';
import '../widgets/animated_press_button.dart';

class UpdateScreen extends StatefulWidget {
  final UpdateCheckResult updateResult;
  final VoidCallback? onSkip;

  const UpdateScreen({super.key, required this.updateResult, this.onSkip});

  @override
  State<UpdateScreen> createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen> {
  bool _isDownloading = false;
  double _downloadProgress = 0;
  String? _error;

  Future<void> _startUpdate() async {
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0;
      _error = null;
    });

    try {
      final dio = Dio();
      final tempDir = await getTemporaryDirectory();
      final savePath =
          '${tempDir.path}/update_${widget.updateResult.version}.apk';

      await dio.download(
        widget.updateResult.apkUrl!,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              _downloadProgress = received / total;
            });
          }
        },
      );

      setState(() {
        _downloadProgress = 1.0;
      });

      // Install APK
      final result = await OpenFilex.open(savePath);
      if (result.type != ResultType.done) {
        throw Exception('Could not launch installer: ${result.message}');
      }
    } catch (e) {
      setState(() {
        _error = 'Download failed: $e';
        _isDownloading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMandatory = widget.updateResult.isMandatory;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              _buildHeader(),
              const SizedBox(height: 32),
              _buildVersionInfo(),
              const SizedBox(height: 24),
              const Text(
                'WHAT\'S NEW',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Markdown(
                    data:
                        widget.updateResult.releaseNotes ??
                        'No release notes provided.',
                    padding: EdgeInsets.zero,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              if (_isDownloading)
                _buildDownloadProgress()
              else
                _buildActionButtons(isMandatory),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            FluentIcons.arrow_circle_up_24_filled,
            color: Colors.white,
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'App Update',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              'A new version is available',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVersionInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _buildInfoRow('New Version', 'v${widget.updateResult.version}'),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
          _buildInfoRow(
            'File Size',
            '${(widget.updateResult.fileSize! / (1024 * 1024)).toStringAsFixed(1)} MB',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 15)),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildDownloadProgress() {
    return Column(
      children: [
        LinearProgressIndicator(
          value: _downloadProgress,
          backgroundColor: Colors.grey.shade200,
          valueColor: const AlwaysStoppedAnimation(Colors.black),
          borderRadius: BorderRadius.circular(10),
          minHeight: 12,
        ),
        const SizedBox(height: 12),
        Text(
          'Downloading... ${(_downloadProgress * 100).toInt()}%',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        if (_error != null) ...[
          const SizedBox(height: 8),
          Text(
            _error!,
            style: const TextStyle(color: Colors.red, fontSize: 12),
          ),
          TextButton(onPressed: _startUpdate, child: const Text('Try Again')),
        ],
      ],
    );
  }

  Widget _buildActionButtons(bool isMandatory) {
    return Column(
      children: [
        AnimatedPressButton(
          onPressed: _startUpdate,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Text(
              'Update Now',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        if (!isMandatory) ...[
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              widget.onSkip?.call();
            },
            child: Text(
              'Skip for now (${3 - widget.updateResult.skipCount} left)',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
        ],
      ],
    );
  }
}
