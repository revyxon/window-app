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

  final List<void Function(LicenseStatus)> _listeners = []; // Callbacks

  LicenseStatus get status => _status;
  bool get isLocked => _status.isLocked; // Server enforced lock

  /// Returns determined status based on GRACE PERIOD validity.
  /// If offline and within 7 DAYS -> Active (Session is Valid)
  bool get isSessionValid {
    if (_status.isLocked) return false; // Server said lock -> Immediate Lock

    // If we never checked, we might allow (first run) or block.
    // Assuming first run logic is handled separately or treated as 'need check'.
    // If no check ever, we treat as invalid and force check.
    if (_lastValidCheck == null) return false;

    final diff = DateTime.now().difference(_lastValidCheck!);
    return diff < _gracePeriod;
  }

  /// Initialize: LOAD CACHE ONLY.
  Future<void> initialize() async {
    await _loadCachedStatus();
  }

  /// Validate Logic:
  /// - Only run actual network call if > 8 hours OR force check required.
  /// - BUT, since SystemGuard calls this on 15s timer explicitly, we run it.
  Future<LicenseStatus> validate() async {
    try {
      final deviceStatus = await FirestoreService().getDeviceStatus();

      if (deviceStatus != null) {
        final serverStatus = LicenseStatus.fromJson(deviceStatus);

        // If server explicitly locks, we update immediately
        if (serverStatus.isLocked) {
          _updateStatus(serverStatus);
        }
        // If server says active, we renew our 7-day lease
        else {
          _lastValidCheck = DateTime.now();
          _updateStatus(serverStatus);
          await _cacheStatus();
        }
      }
      return _status;
    } catch (e) {
      AppLogger().error('LICENSE', 'Validation failed (offline?): $e');
      // On failure, we DO NOT change status.
      // isSessionValid getter handles the 7-day grace check.
      return _status;
    }
  }

  void _updateStatus(LicenseStatus newStatus) {
    if (_status.status != newStatus.status ||
        _status.lockReason != newStatus.lockReason) {
      _status = newStatus;
      _notifyListeners();
    }
  }

  Future<void> _cacheStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      Map<String, dynamic> data = {
        'status': _status.status,
        'lockReason': _status.lockReason,
        'licenseExpiry': _status.licenseExpiry?.toIso8601String(),
        'forceCheck': _status.forceCheck,
      };

      await prefs.setString('license_data', jsonEncode(data));

      if (_lastValidCheck != null) {
        await prefs.setInt(
          'last_valid_session',
          _lastValidCheck!.millisecondsSinceEpoch,
        );
      }
    } catch (e) {
      AppLogger().error('LICENSE', 'Cache error: $e');
    }
  }

  Future<void> _loadCachedStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final licenseData = prefs.getString('license_data');
      final lastSession = prefs.getInt('last_valid_session');

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
    if (_lastValidCheck == null) return "None";
    final expiry = _lastValidCheck!.add(_gracePeriod);
    final remaining = expiry.difference(DateTime.now());
    return "${remaining.inDays}d ${remaining.inHours % 24}h";
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
