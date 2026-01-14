import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_controls.dart';
import 'firestore_service.dart';

/// Service to manage license status and user controls
class LicenseService {
  static final LicenseService _instance = LicenseService._internal();
  factory LicenseService() => _instance;
  LicenseService._internal();

  LicenseStatus _status = LicenseStatus.active;
  DateTime? _lastCheckTime;
  Timer? _checkTimer;

  // Callbacks for status changes
  final List<void Function(LicenseStatus)> _listeners = [];

  LicenseStatus get status => _status;
  UserControls get controls => _status.controls;
  bool get isLocked => _status.isLocked;
  bool get isActive => _status.isActive;
  DateTime? get lastCheckTime => _lastCheckTime;

  /// Initialize and check license status
  Future<LicenseStatus> initialize() async {
    // Load cached status first
    await _loadCachedStatus();

    // Then fetch latest from server
    await checkStatus();

    // Start periodic check (every 5 minutes)
    _startPeriodicCheck();

    return _status;
  }

  /// Check license status from Firestore
  Future<LicenseStatus> checkStatus() async {
    try {
      final deviceStatus = await FirestoreService().getDeviceStatus();

      if (deviceStatus != null) {
        _status = LicenseStatus.fromJson(deviceStatus);
        _lastCheckTime = DateTime.now();
        await _cacheStatus();
        _notifyListeners();
      }

      return _status;
    } catch (e) {
      print('LicenseService: Failed to check status: $e');
      return _status;
    }
  }

  /// Cache status locally
  Future<void> _cacheStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final deviceStatus = await FirestoreService().getDeviceStatus();
      if (deviceStatus != null) {
        await prefs.setString('license_data', jsonEncode(deviceStatus));
      }
      await prefs.setInt(
        'last_license_check',
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      print('LicenseService: Cache error: $e');
    }
  }

  /// Load cached status
  Future<void> _loadCachedStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final licenseData = prefs.getString('license_data');
      final lastCheck = prefs.getInt('last_license_check');

      if (licenseData != null) {
        final data = jsonDecode(licenseData);
        _status = LicenseStatus.fromJson(data);
      }
      if (lastCheck != null) {
        _lastCheckTime = DateTime.fromMillisecondsSinceEpoch(lastCheck);
      }
    } catch (e) {
      print('LicenseService: Load cache error: $e');
    }
  }

  /// Start periodic status check
  void _startPeriodicCheck() {
    _checkTimer?.cancel();
    _checkTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      checkStatus();
    });
  }

  /// Add listener for status changes
  void addListener(void Function(LicenseStatus) listener) {
    _listeners.add(listener);
  }

  /// Remove listener
  void removeListener(void Function(LicenseStatus) listener) {
    _listeners.remove(listener);
  }

  /// Notify all listeners
  void _notifyListeners() {
    for (final listener in _listeners) {
      listener(_status);
    }
  }

  /// Check if a specific action is allowed
  bool canPerform(String action) {
    if (isLocked) return false;

    switch (action) {
      case 'create_customer':
        return controls.canCreateCustomer;
      case 'edit_customer':
        return controls.canEditCustomer;
      case 'delete_customer':
        return controls.canDeleteCustomer;
      case 'create_window':
        return controls.canCreateWindow;
      case 'edit_window':
        return controls.canEditWindow;
      case 'delete_window':
        return controls.canDeleteWindow;
      case 'export':
        return controls.canExportData;
      case 'print':
        return controls.canPrint;
      case 'share':
        return controls.canShare;
      default:
        return true;
    }
  }

  /// Dispose resources
  void dispose() {
    _checkTimer?.cancel();
    _listeners.clear();
  }
}
