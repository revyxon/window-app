import 'package:flutter/material.dart';
import '../services/license_service.dart';
import '../services/update_service.dart';
import '../models/user_controls.dart';
import '../screens/locked_screen.dart';
import '../screens/update_screen.dart';
import '../screens/offline_lock_screen.dart';

class SystemGuard extends StatefulWidget {
  final Widget child;

  const SystemGuard({super.key, required this.child});

  @override
  State<SystemGuard> createState() => _SystemGuardState();
}

class _SystemGuardState extends State<SystemGuard> {
  bool _isChecking = true;
  LicenseStatus? _licenseStatus;
  UpdateCheckResult? _updateResult;
  bool _isOfflineLocked = false;
  bool _skippedUpdate = false;

  @override
  void initState() {
    super.initState();
    _performSystemCheck();

    // Listen for real-time license changes
    LicenseService().addListener(_onLicenseChanged);
  }

  @override
  void dispose() {
    LicenseService().removeListener(_onLicenseChanged);
    super.dispose();
  }

  void _onLicenseChanged(LicenseStatus status) {
    setState(() {
      _licenseStatus = status;
    });
  }

  Future<void> _performSystemCheck() async {
    setState(() {
      _isChecking = true;
      _isOfflineLocked = false;
    });

    try {
      // 1. Check License & Updates in parallel for speed
      final results = await Future.wait([
        LicenseService().checkStatus(),
        UpdateService().checkForUpdate(),
      ]);

      final LicenseStatus license = results[0] as LicenseStatus;
      final UpdateCheckResult update = results[1] as UpdateCheckResult;

      // Check if we failed to get status AND we've been offline too long (> 24h)
      final lastCheckTime = LicenseService().lastCheckTime;
      bool isStale =
          lastCheckTime == null ||
          DateTime.now().difference(lastCheckTime).inHours >= 24;

      // If we are offline (failed to fetch) AND status is stale, we LOCK.
      // Note: checkStatus() returns cached if offline.
      // We need a more explicit 'didFetchSucceed' check ideally, but for now:
      // If we couldn't get update info (hasUpdate is false but no error),
      // or if checkForUpdate threw an error.

      bool fetchFailed = update.error != null;

      setState(() {
        _licenseStatus = license;
        _updateResult = update;
        _isOfflineLocked = fetchFailed && isStale;
        _isChecking = false;
      });
    } catch (e) {
      setState(() {
        _isChecking = false;
        _isOfflineLocked = true;
      });
    }
  }

  void _onSkipUpdate() {
    if (_updateResult?.version != null) {
      UpdateService().skipUpdate(_updateResult!.version!);
      setState(() {
        _skippedUpdate = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.black),
              SizedBox(height: 24),
              Text(
                'Securing System...',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 1. Priority: Offline Lock (Cannot verify status)
    if (_isOfflineLocked) {
      return OfflineLockScreen(onRetry: _performSystemCheck);
    }

    // 2. Priority: Administrative Lock
    if (_licenseStatus?.isLocked == true) {
      return LockedScreen(
        reason: _licenseStatus?.lockReason,
        onRetry: _performSystemCheck,
      );
    }

    // 3. Priority: Mandatory Update
    if (_updateResult?.hasUpdate == true &&
        _updateResult?.isMandatory == true &&
        !_skippedUpdate) {
      return UpdateScreen(
        updateResult: _updateResult!,
        // No onSkip provided means it's mandatory (button won't show)
      );
    }

    // 4. Low Priority: Optional Update (show as child)
    // We actually want to show the UpdateScreen if an update is available even if not mandatory,
    // but allow skipping.
    if (_updateResult?.hasUpdate == true && !_skippedUpdate) {
      return UpdateScreen(updateResult: _updateResult!, onSkip: _onSkipUpdate);
    }

    // 5. System clear
    return widget.child;
  }
}
