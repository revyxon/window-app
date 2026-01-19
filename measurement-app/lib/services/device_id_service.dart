import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'app_logger.dart';

/// Service to generate and persist a unique device ID.
/// Uses `android_id` on Android for strict persistence across reinstalls.
/// Falls back to UUID on other platforms or if android_id is unavailable.
class DeviceIdService {
  static DeviceIdService? _instance;
  static DeviceIdService get instance => _instance ??= DeviceIdService._();

  DeviceIdService._();

  String? _deviceId;
  static const String _prefKey = 'device_unique_uuid';
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  /// Get the unique device ID.
  /// 1. Checks memory cache.
  /// 2. Checks SharedPreferences (Legacy/Migration).
  /// 3. Generates STRICT ID based on Platform (Android ID / iOS Vendor).
  /// 4. Falls back to UUID v4.
  Future<String> getDeviceId() async {
    if (_deviceId != null) return _deviceId!;

    // 1. Check Prefs (Legacy/Cache)
    final prefs = await SharedPreferences.getInstance();
    String? storedId = prefs.getString(_prefKey);

    // 2. Try to get strict hardware ID
    String? strictId;
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        // androidId is unique to the device + signing key, stable across reinstalls
        strictId = androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        strictId = iosInfo.identifierForVendor;
      }
    } catch (e) {
      AppLogger().error('DEVICE_ID', 'Failed to get hardware ID: $e');
    }

    // 3. Logic:
    // If we have a strictId, USE IT (This ensures persistence on reinstall).
    // EXCEPT: If we have a storedId that is DIFFERENT, we might be overwriting a legacy user?
    // User requested "Fixed Device ID even after reinstall".
    // So `strictId` (Hardware ID) > `storedId` (Random UUID).

    if (strictId != null && strictId.isNotEmpty && strictId != 'unknown') {
      _deviceId = strictId;
    } else if (storedId != null && storedId.isNotEmpty) {
      // Fallback to existing UUID
      _deviceId = storedId;
    } else {
      // Generate new UUID
      _deviceId = const Uuid().v4();
    }

    // Persist whatever we decided on (for faster reads next time)
    if (_deviceId != storedId) {
      await prefs.setString(_prefKey, _deviceId!);
    }

    return _deviceId!;
  }
}
