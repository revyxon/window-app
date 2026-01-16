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

    // Generate random UUID v4 if no ID exists (simple fallback)
    _deviceId = const Uuid().v4();

    // Cache it
    await prefs.setString(_prefKey, _deviceId!);

    return _deviceId!;
  }
}
