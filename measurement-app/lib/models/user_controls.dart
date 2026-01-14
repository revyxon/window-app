/// Model class for granular user controls
/// Controls what actions a user can perform in the app
class UserControls {
  final bool canCreateCustomer;
  final bool canEditCustomer;
  final bool canDeleteCustomer;
  final bool canCreateWindow;
  final bool canEditWindow;
  final bool canDeleteWindow;
  final bool canExportData;
  final bool canPrint;
  final bool canShare;

  const UserControls({
    this.canCreateCustomer = true,
    this.canEditCustomer = true,
    this.canDeleteCustomer = true,
    this.canCreateWindow = true,
    this.canEditWindow = true,
    this.canDeleteWindow = true,
    this.canExportData = true,
    this.canPrint = true,
    this.canShare = true,
  });

  /// Default controls - all permissions enabled
  static const UserControls defaultControls = UserControls();

  /// Locked controls - all permissions disabled
  static const UserControls lockedControls = UserControls(
    canCreateCustomer: false,
    canEditCustomer: false,
    canDeleteCustomer: false,
    canCreateWindow: false,
    canEditWindow: false,
    canDeleteWindow: false,
    canExportData: false,
    canPrint: false,
    canShare: false,
  );

  factory UserControls.fromJson(Map<String, dynamic>? json) {
    if (json == null) return UserControls.defaultControls;

    return UserControls(
      canCreateCustomer: json['canCreateCustomer'] ?? true,
      canEditCustomer: json['canEditCustomer'] ?? true,
      canDeleteCustomer: json['canDeleteCustomer'] ?? true,
      canCreateWindow: json['canCreateWindow'] ?? true,
      canEditWindow: json['canEditWindow'] ?? true,
      canDeleteWindow: json['canDeleteWindow'] ?? true,
      canExportData: json['canExportData'] ?? true,
      canPrint: json['canPrint'] ?? true,
      canShare: json['canShare'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'canCreateCustomer': canCreateCustomer,
      'canEditCustomer': canEditCustomer,
      'canDeleteCustomer': canDeleteCustomer,
      'canCreateWindow': canCreateWindow,
      'canEditWindow': canEditWindow,
      'canDeleteWindow': canDeleteWindow,
      'canExportData': canExportData,
      'canPrint': canPrint,
      'canShare': canShare,
    };
  }

  @override
  String toString() =>
      'UserControls(create: $canCreateCustomer, edit: $canEditCustomer, delete: $canDeleteCustomer)';
}

/// License status response from server/Firestore
class LicenseStatus {
  final String status; // 'active', 'locked', 'expired'
  final UserControls controls;
  final DateTime? licenseExpiry;
  final String? lockReason;

  const LicenseStatus({
    required this.status,
    this.controls = const UserControls(),
    this.licenseExpiry,
    this.lockReason,
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
      controls: UserControls.fromJson(json['controls']),
      licenseExpiry: json['licenseExpiry'] != null
          ? DateTime.tryParse(json['licenseExpiry'].toString())
          : null,
      lockReason: json['lockReason'],
    );
  }

  /// Default active status
  static const LicenseStatus active = LicenseStatus(status: 'active');

  /// Locked status
  static const LicenseStatus locked = LicenseStatus(
    status: 'locked',
    controls: UserControls.lockedControls,
  );
}
