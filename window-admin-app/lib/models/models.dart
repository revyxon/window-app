/// Device model for admin app
class Device {
  final String deviceId;
  final String status;
  final DateTime? registeredAt;
  final DateTime? lastActiveAt;
  final String? appVersion;
  final DateTime? licenseExpiry;

  Device({
    required this.deviceId,
    required this.status,
    this.registeredAt,
    this.lastActiveAt,
    this.appVersion,
    this.licenseExpiry,
  });

  bool get isActive => status == 'active';
  bool get isLocked => status == 'locked';
  bool get isExpired => status == 'expired';

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      deviceId: json['deviceId'] as String,
      status: json['status'] as String? ?? 'active',
      registeredAt: json['registeredAt'] != null
          ? DateTime.tryParse(json['registeredAt'])
          : null,
      lastActiveAt: json['lastActiveAt'] != null
          ? DateTime.tryParse(json['lastActiveAt'])
          : null,
      appVersion: json['appVersion'] as String?,
      licenseExpiry: json['licenseExpiry'] != null
          ? DateTime.tryParse(json['licenseExpiry'])
          : null,
    );
  }
}

/// Analytics model
class Analytics {
  final int totalDevices;
  final int activeToday;
  final int totalCustomers;
  final int totalWindows;
  final Map<String, int> statusBreakdown;

  Analytics({
    required this.totalDevices,
    required this.activeToday,
    required this.totalCustomers,
    required this.totalWindows,
    required this.statusBreakdown,
  });

  factory Analytics.fromJson(Map<String, dynamic> json) {
    final analytics = json['analytics'] as Map<String, dynamic>;
    final breakdown =
        analytics['statusBreakdown'] as Map<String, dynamic>? ?? {};

    return Analytics(
      totalDevices: analytics['totalDevices'] as int? ?? 0,
      activeToday: analytics['activeToday'] as int? ?? 0,
      totalCustomers: analytics['totalCustomers'] as int? ?? 0,
      totalWindows: analytics['totalWindows'] as int? ?? 0,
      statusBreakdown: breakdown.map((k, v) => MapEntry(k, v as int)),
    );
  }
}

/// Activity log entry
class ActivityLog {
  final String id;
  final String deviceId;
  final String actionName;
  final String page;
  final String? context;
  final DateTime? timestamp;

  ActivityLog({
    required this.id,
    required this.deviceId,
    required this.actionName,
    required this.page,
    this.context,
    this.timestamp,
  });

  factory ActivityLog.fromJson(Map<String, dynamic> json) {
    return ActivityLog(
      id: json['id'] as String,
      deviceId:
          json['deviceId'] as String? ?? json['device_id'] as String? ?? '',
      actionName:
          json['actionName'] as String? ?? json['action_name'] as String? ?? '',
      page: json['page'] as String? ?? '',
      context: json['context'] as String?,
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'])
          : null,
    );
  }
}

/// App update model
class AppUpdate {
  final String? id;
  final String version;
  final int buildNumber;
  final String apkUrl;
  final int fileSize;
  final String? releaseNotes;
  final bool forceUpdate;
  final bool skipAllowed;
  final DateTime? createdAt;

  AppUpdate({
    this.id,
    required this.version,
    required this.buildNumber,
    required this.apkUrl,
    required this.fileSize,
    this.releaseNotes,
    this.forceUpdate = false,
    this.skipAllowed = true,
    this.createdAt,
  });

  factory AppUpdate.fromJson(Map<String, dynamic> json) {
    return AppUpdate(
      id: json['id'] as String?,
      version: json['version'] as String,
      buildNumber: json['buildNumber'] as int,
      apkUrl: json['apkUrl'] as String,
      fileSize: json['fileSize'] as int? ?? 0,
      releaseNotes: json['releaseNotes'] as String?,
      forceUpdate:
          json['forceUpdate'] as bool? ?? json['mandatory'] as bool? ?? false,
      skipAllowed: json['skipAllowed'] as bool? ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
    );
  }
}
