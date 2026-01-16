import 'dart:io';

/// Deep Device Info Service - Collects comprehensive device metadata silently
/// No permissions required for any of these data points
class DeviceInfoService {
  static final DeviceInfoService _instance = DeviceInfoService._internal();
  factory DeviceInfoService() => _instance;
  DeviceInfoService._internal();

  Map<String, dynamic>? _cachedInfo;

  /// Get complete device fingerprint data
  Future<Map<String, dynamic>> getCompleteDeviceInfo() async {
    if (_cachedInfo != null) return _cachedInfo!;

    final info = <String, dynamic>{
      'platform': Platform.operatingSystem,
      'platformVersion': Platform.operatingSystemVersion,
      'localeName': Platform.localeName,
      'numberOfProcessors': Platform.numberOfProcessors,
      'collectedAt': DateTime.now().toUtc().toIso8601String(),
      'isPhysicalDevice': true, // Assumption or hardcoded fallback
      'manufacturer': 'Unknown',
      'model': 'Unknown',
      'device': 'Unknown',
    };

    _cachedInfo = info;
    return info;
  }

  /// Generate a unique fingerprint hash from device data
  Future<String> generateDeviceFingerprint() async {
    final info = await getCompleteDeviceInfo();
    return info.toString().hashCode.toRadixString(16);
  }

  /// Get a summary for quick display
  Future<Map<String, String>> getDeviceSummary() async {
    final info = await getCompleteDeviceInfo();
    return {
      'Device': '${info['platform']}',
      'Version': '${info['platformVersion']}',
    };
  }

  /// Clear cached info (useful for testing)
  void clearCache() {
    _cachedInfo = null;
  }
}
