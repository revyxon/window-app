import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'license_service.dart';

/// Utility class for permission checks and UI helpers
class PermissionHelper {
  static final PermissionHelper _instance = PermissionHelper._internal();
  factory PermissionHelper() => _instance;
  PermissionHelper._internal();

  /// Check if action is allowed and show dialog if not
  bool checkAndShowDialog(
    BuildContext context,
    String action,
    String actionName,
  ) {
    // We now only check if the system is locked globally
    // We ignore the specific 'action' parameter as all actions are allowed if active
    if (LicenseService().isLocked) {
      _showBlockedDialog(context, actionName);
      return false;
    }
    return true;
  }

  /// Show blocked action dialog
  void _showBlockedDialog(BuildContext context, String actionName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(
          FluentIcons.shield_error_24_regular,
          color: Colors.orange,
          size: 48,
        ),
        title: const Text('Action Restricted'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$actionName has been disabled by your administrator.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Contact your admin if you need access to this feature.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
