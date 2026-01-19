import 'package:flutter/material.dart';
import '../../services/restore_service.dart';
import '../design_system.dart';
import '../../utils/haptics.dart';

class RestoreDialog extends StatefulWidget {
  const RestoreDialog({super.key});

  @override
  State<RestoreDialog> createState() => _RestoreDialogState();
}

class _RestoreDialogState extends State<RestoreDialog> {
  String _statusMessage = 'Initializing...';
  double _progress = 0.0;
  bool _isComplete = false;
  RestoreResults? _results;
  String? _error;

  @override
  void initState() {
    super.initState();
    _startRestore();
  }

  Future<void> _startRestore() async {
    // Artificial delay for UX
    await Future.delayed(const Duration(milliseconds: 500));

    final results = await RestoreService().restoreFromCloud(
      onProgress: (stage, progress) {
        if (mounted) {
          setState(() {
            _statusMessage = stage;
            _progress = progress;
          });
        }
      },
    );

    if (mounted) {
      if (results.success) {
        Haptics.success();
        setState(() {
          _isComplete = true;
          _results = results;
          _progress = 1.0;
          _statusMessage = 'Restore Complete!';
        });
      } else {
        Haptics.error();
        setState(() {
          _isComplete = true; // Complete with error
          _error = results.error;
          _progress = 0.0;
          _statusMessage = 'Restore Failed';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: _error != null
                    ? Colors.red.withValues(alpha: 0.1)
                    : _isComplete
                    ? Colors.green.withValues(alpha: 0.1)
                    : theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: _error != null
                    ? const Icon(
                        Icons.error_outline_rounded,
                        color: Colors.red,
                        size: 32,
                      )
                    : _isComplete
                    ? const Icon(
                        Icons.check_rounded,
                        color: Colors.green,
                        size: 32,
                      )
                    : SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.colorScheme.primary,
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Title
            Text(
              _error != null
                  ? 'Error'
                  : (_isComplete ? 'Restored Successfully' : 'Restoring Data'),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // Status / Error Message
            Text(
              _error ?? _statusMessage,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: _error != null
                    ? Colors.red
                    : theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppSpacing.xl),

            // Progress Bar (if running)
            if (!_isComplete && _error == null) ...[
              LinearProgressIndicator(
                value: _progress,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],

            // Stats (if complete & success)
            if (_isComplete && _results != null) ...[
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStat(
                      context,
                      'Customers',
                      _results!.customers.toString(),
                    ),
                    _buildStat(
                      context,
                      'Windows',
                      _results!.windows.toString(),
                    ),
                    _buildStat(
                      context,
                      'Enquiries',
                      _results!.enquiries.toString(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],

            // Button
            if (_isComplete || _error != null)
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                  ),
                  child: const Text('Close'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}
