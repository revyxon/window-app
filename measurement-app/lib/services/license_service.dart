import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'firestore_service.dart';
import '../services/app_logger.dart';

/// License status response from server/Firestore
class LicenseStatus {
  final String status; // 'active', 'locked', 'expired'
  final DateTime? licenseExpiry;
  final String? lockReason;
  // If forceCheck is true, the app must validate with server immediately
  final bool forceCheck;

  const LicenseStatus({
    required this.status,
    this.licenseExpiry,
    this.lockReason,
    this.forceCheck = false,
  });

  bool get isLocked => status == 'locked';
  bool get isExpired => status == 'expired';
  bool get isActive => status == 'active';

  factory LicenseStatus.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const LicenseStatus(status: 'active');
    }

    return LicenseStatus(
      status: json['status'] ?? 'active',
      licenseExpiry: json['licenseExpiry'] != null
          ? DateTime.tryParse(json['licenseExpiry'].toString())
          : null,
      lockReason: json['lockReason'],
      forceCheck: json['forceCheck'] ?? false,
    );
  }

  /// Default active status
  static const LicenseStatus active = LicenseStatus(status: 'active');
}

/// Service to manage license status with 7-DAY GRACE PERIOD.
/// Rules:
/// 1. Check network every 8 hours (Soft Schedule).
/// 2. Lock ONLY if:
///    a) Server returns LOCKED.
///    b) Offline for > 7 DAYS (Hard Expiry).
class LicenseService {
  static final LicenseService _instance = LicenseService._internal();
  factory LicenseService() => _instance;
  LicenseService._internal();

  LicenseStatus _status = LicenseStatus.active;
  DateTime? _lastValidCheck;

  // HARD LOCK: Lock if offline > 7 days
  static const Duration _gracePeriod = Duration(days: 7);
  static const String _statusKey = 'license_status_v2';
  static const String _checkKey = 'last_valid_check_v2';

  final List<void Function(LicenseStatus)> _listeners = [];

  LicenseStatus get status => _status;
  bool get isLocked => _status.isLocked;

  /// Returns determined status based on GRACE PERIOD validity.
  /// If offline and within 7 DAYS -> Active (Session is Valid)
  bool get isSessionValid {
    if (_status.isLocked)
      return false; // Strict Lock: Persists until server unlocks

    // If never checked, we assume need validation, but don't lock immediately unless enforce strict first run?
    // User wants "no auto lock". So if null, we allow temporarily or force check depending on policy.
    // Here we treat null as "Unknown/Active" but request check.
    if (_lastValidCheck == null) return true;

    final diff = DateTime.now().difference(_lastValidCheck!);
    final isValid = diff < _gracePeriod;

    if (!isValid) {
      AppLogger().warn('LICENSE', 'Grace period expired. Days: ${diff.inDays}');
    }
    return isValid;
  }

  /// Initialize: LOAD CACHE IMMEDIATELY.
  Future<void> initialize() async {
    await _loadCachedStatus();
  }

  /// Validate Logic with Robust Network Handling
  Future<LicenseStatus> validate() async {
    try {
      final deviceStatus = await FirestoreService().getDeviceStatus();

      if (deviceStatus != null) {
        final serverStatus = LicenseStatus.fromJson(deviceStatus);

        // PERSISTENT LOCK: If server says locked, we lock immediately and persist it.
        if (serverStatus.isLocked) {
          await _updateStatus(serverStatus);
        }
        // UNLOCK / RENEW: If server says active
        else {
          _lastValidCheck = DateTime.now(); // Renew lease
          await _updateStatus(serverStatus);
          await _cacheStatus(); // Save new lease
        }
      }
      return _status;
    } catch (e) {
      AppLogger().error('LICENSE', 'Validation failed: $e');
      // On failure, DO NOTHING. Keep current state.
      // isSessionValid will handle the 7-day expiry check.
      return _status;
    }
  }

  Future<void> _updateStatus(LicenseStatus newStatus) async {
    if (_status.status != newStatus.status ||
        _status.lockReason != newStatus.lockReason) {
      _status = newStatus;
      _notifyListeners();
      await _cacheStatus(); // Persist immediately on change
    }
  }

  Future<void> _cacheStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Store Status
      Map<String, dynamic> data = {
        'status': _status.status,
        'lockReason': _status.lockReason,
        'licenseExpiry': _status.licenseExpiry?.toIso8601String(),
        'forceCheck': _status.forceCheck,
      };
      await prefs.setString(_statusKey, jsonEncode(data));

      // Store Lease
      if (_lastValidCheck != null) {
        await prefs.setInt(_checkKey, _lastValidCheck!.millisecondsSinceEpoch);
      }
    } catch (e) {
      AppLogger().error('LICENSE', 'Cache error: $e');
    }
  }

  Future<void> _loadCachedStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final licenseData = prefs.getString(_statusKey);
      final lastSession = prefs.getInt(_checkKey);

      if (licenseData != null) {
        _status = LicenseStatus.fromJson(jsonDecode(licenseData));
      }

      if (lastSession != null) {
        _lastValidCheck = DateTime.fromMillisecondsSinceEpoch(lastSession);
      }

      AppLogger().info(
        'LICENSE',
        'Loaded cache. Status=${_status.status}, GracePeriodRemaining=${_getGraceRemaining()}',
      );
    } catch (_) {}
  }

  String _getGraceRemaining() {
    if (_lastValidCheck == null) return "First Run";
    if (_status.isLocked) return "Locked";

    final expiry = _lastValidCheck!.add(_gracePeriod);
    final remaining = expiry.difference(DateTime.now());
    if (remaining.isNegative)
      return "Expired (${remaining.inDays.abs()} days ago)";
    return "${remaining.inDays}d ${remaining.inHours % 24}h";
  }

  int get daysUntilExpiry {
    if (_lastValidCheck == null) return 7;
    final expiry = _lastValidCheck!.add(_gracePeriod);
    return expiry.difference(DateTime.now()).inDays;
  }

  void addListener(void Function(LicenseStatus) listener) {
    _listeners.add(listener);
  }

  void removeListener(void Function(LicenseStatus) listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners() {
    for (final listener in _listeners) {
      listener(_status);
    }
  }
}
