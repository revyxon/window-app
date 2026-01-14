import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

/// Deep Device Info Service - Collects comprehensive device metadata silently
/// No permissions required for any of these data points
class DeviceInfoService {
  static final DeviceInfoService _instance = DeviceInfoService._internal();
  factory DeviceInfoService() => _instance;
  DeviceInfoService._internal();

  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  Map<String, dynamic>? _cachedInfo;

  /// Get complete device fingerprint data
  Future<Map<String, dynamic>> getCompleteDeviceInfo() async {
    if (_cachedInfo != null) return _cachedInfo!;

    final info = <String, dynamic>{};

    if (Platform.isAndroid) {
      final androidInfo = await _deviceInfo.androidInfo;
      info.addAll(_extractAndroidInfo(androidInfo));
    } else if (Platform.isIOS) {
      final iosInfo = await _deviceInfo.iosInfo;
      info.addAll(_extractIOSInfo(iosInfo));
    }

    // Add platform-agnostic data
    info['platform'] = Platform.operatingSystem;
    info['platformVersion'] = Platform.operatingSystemVersion;
    info['localeName'] = Platform.localeName;
    info['numberOfProcessors'] = Platform.numberOfProcessors;
    info['collectedAt'] = DateTime.now().toUtc().toIso8601String();

    _cachedInfo = info;
    return info;
  }

  Map<String, dynamic> _extractAndroidInfo(AndroidDeviceInfo android) {
    return {
      // === DEVICE IDENTITY ===
      'manufacturer': android.manufacturer,
      'brand': android.brand,
      'model': android.model,
      'product': android.product,
      'device': android.device,
      'board': android.board,
      'hardware': android.hardware,

      // === BUILD INFO ===
      'buildId': android.id,
      'buildDisplay': android.display,
      'buildFingerprint': android.fingerprint,
      'bootloader': android.bootloader,
      'host': android.host,
      'buildTags': android.tags,
      'buildType': android.type,

      // === ANDROID VERSION ===
      'androidVersion': android.version.release,
      'sdkInt': android.version.sdkInt,
      'codename': android.version.codename,
      'incremental': android.version.incremental,
      'securityPatch': android.version.securityPatch,
      'baseOS': android.version.baseOS,
      'previewSdkInt': android.version.previewSdkInt,

      // === HARDWARE SPECS ===
      'supportedAbis': android.supportedAbis,
      'supported32BitAbis': android.supported32BitAbis,
      'supported64BitAbis': android.supported64BitAbis,

      // === SECURITY FLAGS ===
      'isPhysicalDevice': android.isPhysicalDevice,
    };
  }

  Map<String, dynamic> _extractIOSInfo(IosDeviceInfo ios) {
    return {
      // === DEVICE IDENTITY ===
      'name': ios.name,
      'model': ios.model,
      'localizedModel': ios.localizedModel,
      'systemName': ios.systemName,
      'systemVersion': ios.systemVersion,

      // === HARDWARE ===
      'machine': ios.utsname.machine,
      'nodename': ios.utsname.nodename,
      'release': ios.utsname.release,
      'sysname': ios.utsname.sysname,
      'version': ios.utsname.version,

      // === IDENTITY ===
      'identifierForVendor': ios.identifierForVendor,

      // === SECURITY FLAGS ===
      'isPhysicalDevice': ios.isPhysicalDevice,
    };
  }

  /// Generate a unique fingerprint hash from device data
  Future<String> generateDeviceFingerprint() async {
    final info = await getCompleteDeviceInfo();

    // Combine key identifying fields
    final fingerprintData = [
      info['manufacturer'] ?? '',
      info['model'] ?? '',
      info['hardware'] ?? '',
      info['board'] ?? '',
      info['buildFingerprint'] ?? '',
    ].join('|').toLowerCase();

    // Simple hash (for production, use crypto package for SHA-256)
    return fingerprintData.hashCode.toRadixString(16);
  }

  /// Get a summary for quick display
  Future<Map<String, String>> getDeviceSummary() async {
    final info = await getCompleteDeviceInfo();

    if (Platform.isAndroid) {
      return {
        'Device': '${info['brand']} ${info['model']}',
        'Android': '${info['androidVersion']} (API ${info['sdkInt']})',
        'Security Patch': info['securityPatch'] ?? 'Unknown',
        'Build': info['buildId'] ?? 'Unknown',
        'Hardware': info['hardware'] ?? 'Unknown',
        'Physical Device': info['isPhysicalDevice'] == true ? 'Yes' : 'No',
      };
    } else {
      return {
        'Device': '${info['name']} (${info['model']})',
        'iOS': info['systemVersion'] ?? 'Unknown',
        'Machine': info['machine'] ?? 'Unknown',
        'Physical Device': info['isPhysicalDevice'] == true ? 'Yes' : 'No',
      };
    }
  }

  /// Clear cached info (useful for testing)
  void clearCache() {
    _cachedInfo = null;
  }
}
