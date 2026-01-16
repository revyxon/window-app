/// Device registration model for license management
class DeviceRegistration {
  final String deviceId;
  final String status; // 'active', 'locked', 'expired'
  final DateTime? licenseExpiry;
  final DateTime registeredAt;
  final DateTime lastActiveAt;
  final String? appVersion;

  DeviceRegistration({
    required this.deviceId,
    this.status = 'active',
    this.licenseExpiry,
    required this.registeredAt,
    required this.lastActiveAt,
    this.appVersion,
  });

  bool get isActive => status == 'active';
  bool get isLocked => status == 'locked';
  bool get isExpired {
    if (status == 'expired') return true;
    if (licenseExpiry != null && DateTime.now().isAfter(licenseExpiry!)) {
      return true;
    }
    return false;
  }

  Map<String, dynamic> toMap() {
    return {
      'deviceId': deviceId,
      'status': status,
      'licenseExpiry': licenseExpiry?.toIso8601String(),
      'registeredAt': registeredAt.toIso8601String(),
      'lastActiveAt': lastActiveAt.toIso8601String(),
      'appVersion': appVersion,
    };
  }

  factory DeviceRegistration.fromMap(Map<String, dynamic> map) {
    return DeviceRegistration(
      deviceId: map['deviceId'] as String,
      status: map['status'] as String? ?? 'active',
      licenseExpiry: map['licenseExpiry'] != null
          ? DateTime.tryParse(map['licenseExpiry'])
          : null,
      registeredAt:
          DateTime.tryParse(map['registeredAt'] ?? '') ?? DateTime.now(),
      lastActiveAt:
          DateTime.tryParse(map['lastActiveAt'] ?? '') ?? DateTime.now(),
      appVersion: map['appVersion'] as String?,
    );
  }

  DeviceRegistration copyWith({
    String? deviceId,
    String? status,
    DateTime? licenseExpiry,
    DateTime? registeredAt,
    DateTime? lastActiveAt,
    String? appVersion,
  }) {
    return DeviceRegistration(
      deviceId: deviceId ?? this.deviceId,
      status: status ?? this.status,
      licenseExpiry: licenseExpiry ?? this.licenseExpiry,
      registeredAt: registeredAt ?? this.registeredAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      appVersion: appVersion ?? this.appVersion,
    );
  }
}
