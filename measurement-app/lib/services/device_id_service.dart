import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Service to generate and persist a unique device ID as valid UUID
/// This ID persists across app reinstalls
class DeviceIdService {
  static DeviceIdService? _instance;
  static DeviceIdService get instance => _instance ??= DeviceIdService._();

  DeviceIdService._();

  String? _deviceId;
  static const String _prefKey = 'device_unique_uuid';

  /// Get the unique device ID as a valid UUID
  Future<String> getDeviceId() async {
    if (_deviceId != null) return _deviceId!;

    final prefs = await SharedPreferences.getInstance();
    _deviceId = prefs.getString(_prefKey);

    if (_deviceId != null && _deviceId!.isNotEmpty) {
      return _deviceId!;
    }

    // Generate UUID from device info
    String seedString;
    final deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      // Use Android ID + model + brand for uniqueness
      seedString =
          '${androidInfo.id}_${androidInfo.model}_${androidInfo.brand}';
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      seedString =
          iosInfo.identifierForVendor ??
          'ios_${DateTime.now().millisecondsSinceEpoch}';
    } else {
      seedString = 'device_${DateTime.now().millisecondsSinceEpoch}';
    }

    // Convert to valid UUID v5 (namespace-based)
    _deviceId = const Uuid().v5(Namespace.url.value, seedString);

    // Cache it
    await prefs.setString(_prefKey, _deviceId!);

    return _deviceId!;
  }
}
