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

/// License status response from server
class LicenseStatus {
  final bool isValid;
  final String status;
  final String? message;
  final DateTime? expiresAt;
  final DateTime? cachedAt;

  LicenseStatus({
    required this.isValid,
    required this.status,
    this.message,
    this.expiresAt,
    this.cachedAt,
  });

  factory LicenseStatus.active() {
    return LicenseStatus(
      isValid: true,
      status: 'active',
      cachedAt: DateTime.now(),
    );
  }

  factory LicenseStatus.locked({String? message}) {
    return LicenseStatus(
      isValid: false,
      status: 'locked',
      message: message ?? 'Your device access has been revoked.',
      cachedAt: DateTime.now(),
    );
  }

  factory LicenseStatus.expired({String? message, DateTime? expiresAt}) {
    return LicenseStatus(
      isValid: false,
      status: 'expired',
      message: message ?? 'Your license has expired.',
      expiresAt: expiresAt,
      cachedAt: DateTime.now(),
    );
  }

  factory LicenseStatus.error({String? message}) {
    return LicenseStatus(
      isValid: false,
      status: 'error',
      message: message ?? 'Unable to validate license.',
      cachedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isValid': isValid,
      'status': status,
      'message': message,
      'expiresAt': expiresAt?.toIso8601String(),
      'cachedAt': cachedAt?.toIso8601String(),
    };
  }

  factory LicenseStatus.fromMap(Map<String, dynamic> map) {
    return LicenseStatus(
      isValid: map['isValid'] as bool? ?? false,
      status: map['status'] as String? ?? 'error',
      message: map['message'] as String?,
      expiresAt: map['expiresAt'] != null
          ? DateTime.tryParse(map['expiresAt'])
          : null,
      cachedAt: map['cachedAt'] != null
          ? DateTime.tryParse(map['cachedAt'])
          : null,
    );
  }
}
