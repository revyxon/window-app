import 'dart:async';
import 'package:flutter/material.dart';
import '../services/license_service.dart';
import '../services/update_service.dart';
import '../services/app_logger.dart';
import '../services/log_service.dart';

import '../screens/locked_screen.dart';

import '../screens/offline_lock_screen.dart';
import '../screens/update_screen.dart';
import '../utils/globals.dart';

/// SystemGuard V2: Invisible License Check with 7-Day Grace Period
class SystemGuard extends StatefulWidget {
  final Widget child;

  const SystemGuard({super.key, required this.child});

  @override
  State<SystemGuard> createState() => _SystemGuardState();
}

class _SystemGuardState extends State<SystemGuard> with WidgetsBindingObserver {
  bool _isLocked = false;
  bool _isGracePeriodExpired = false; // "Offline Locked"
  LicenseStatus? _status;

  Timer? _validationTimer;

  @override
  void initState() {
    super.initState();

    // 1. Initial State Load (Sync, Fast)
    final service = LicenseService();
    _status = service.status;

    // Check if we are ALREADY locked from previous known state
    if (service.isLocked) {
      _isLocked = true;
    }
    // If not locked by server, check grace period
    else if (!service.isSessionValid && service.status.isActive) {
      // If grace period (7 days) expired, we allow 15s attempt to reconnec.
      // But we don't lock INSTANTLY on startup because we want to give chance to re-validate.
      // Unless it's vastly expired? For UX, we let them see the app for 15s, then lock if still offline.
    }

    // 2. Schedule Invisible Check (15s delay)
    // Runs after app has fully loaded and user is interacting
    _validationTimer = Timer(const Duration(seconds: 15), _runInvisibleCheck);

    // 3. Listen for real-time changes
    LicenseService().addListener(_onLicenseChanged);

    // 4. Lifecycle Observer
    WidgetsBinding.instance.addObserver(this);

    // 5. Log App Started
    LogService().logEvent(
      'APP_STARTED',
      details: {'timestamp': DateTime.now().toIso8601String()},
    );
  }

  @override
  void dispose() {
    _validationTimer?.cancel();
    LicenseService().removeListener(_onLicenseChanged);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      LogService().logEvent('APP_PAUSED');
    } else if (state == AppLifecycleState.resumed) {
      LogService().logEvent('APP_RESUMED');
    } else if (state == AppLifecycleState.detached) {
      LogService().logEvent('APP_TERMINATED');
    }
  }

  void _onLicenseChanged(LicenseStatus status) {
    if (!mounted) return;

    setState(() {
      _status = status;
      if (status.isLocked) {
        _isLocked = true;
      }
    });
  }

  Future<void> _runInvisibleCheck() async {
    AppLogger().info('GUARD', 'Running invisible validation (15s triggered)');

    // Check Update first (optional, silent)
    // Check Update first (optional, silent)
    try {
      final updateResult = await UpdateService().checkForUpdate();
      if (updateResult.hasUpdate && mounted) {
        AppLogger().info('GUARD', 'Update found: ${updateResult.version}');
        GlobalParams.navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (ctx) => UpdateScreen(
              updateResult: updateResult,
              onSkip: () {
                Navigator.of(ctx).pop();
                if (updateResult.version != null) {
                  UpdateService().skipUpdate(updateResult.version!);
                }
              },
            ),
          ),
        );
      }
    } catch (e) {
      AppLogger().error('GUARD', 'Update check failed: $e');
    }

    // Validate License
    await LicenseService().validate();

    // After validation, check if we need to lock due to GRACE PERIOD expiration
    if (!mounted) return;

    final service = LicenseService();

    // If we are NOT locked by server, but 7-Day Grace Period is over
    if (!service.isLocked && !service.isSessionValid) {
      setState(() {
        // This means: Offline > 7 days AND re-check failed.
        _isGracePeriodExpired = true;
      });
    } else {
      // If valid, clear any temporary lock
      if (_isGracePeriodExpired) {
        setState(() {
          _isGracePeriodExpired = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Priority: Server Lock (Explicit 'Locked' status)
    if (_isLocked && _status != null) {
      return LockedScreen(
        reason: _status!.lockReason,
        onRetry: () async {
          await LicenseService().validate();
          setState(() {
            _isLocked = LicenseService().isLocked;
          });
        },
      );
    }

    // 2. Priority: Grace Period Expired (Offline > 7 Days)
    if (_isGracePeriodExpired) {
      return OfflineLockScreen(
        onRetry: () async {
          await LicenseService().validate();
          setState(() {
            _isGracePeriodExpired = !LicenseService().isSessionValid;
          });
        },
      );
    }

    // 3. Render App (Invisible Guard)
    return widget.child;
  }
}
