/// Activity log model for tracking user actions
/// Used for analytics and admin monitoring
class ActivityLog {
  final String? id;
  final String deviceId;
  final String actionName;
  final String page;
  final String? context; // JSON string for additional data
  final DateTime timestamp;
  final int syncStatus; // 0: Synced, 1: Created

  ActivityLog({
    this.id,
    required this.deviceId,
    required this.actionName,
    required this.page,
    this.context,
    required this.timestamp,
    this.syncStatus = 1,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'device_id': deviceId,
      'action_name': actionName,
      'page': page,
      'context': context,
      'timestamp': timestamp.toIso8601String(),
      'sync_status': syncStatus,
    };
  }

  factory ActivityLog.fromMap(Map<String, dynamic> map) {
    return ActivityLog(
      id: map['id'] as String?,
      deviceId: map['device_id'] as String,
      actionName: map['action_name'] as String,
      page: map['page'] as String,
      context: map['context'] as String?,
      timestamp: DateTime.tryParse(map['timestamp'] ?? '') ?? DateTime.now(),
      syncStatus: map['sync_status'] as int? ?? 1,
    );
  }

  ActivityLog copyWith({
    String? id,
    String? deviceId,
    String? actionName,
    String? page,
    String? context,
    DateTime? timestamp,
    int? syncStatus,
  }) {
    return ActivityLog(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      actionName: actionName ?? this.actionName,
      page: page ?? this.page,
      context: context ?? this.context,
      timestamp: timestamp ?? this.timestamp,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  @override
  String toString() {
    return 'ActivityLog(action: $actionName, page: $page, time: $timestamp)';
  }
}

/// Common action names for consistency
class ActionNames {
  // Navigation
  static const String viewScreen = 'VIEW_SCREEN';

  // Customer actions
  static const String addCustomer = 'ADD_CUSTOMER';
  static const String editCustomer = 'EDIT_CUSTOMER';
  static const String deleteCustomer = 'DELETE_CUSTOMER';
  static const String viewCustomer = 'VIEW_CUSTOMER';

  // Window actions
  static const String addWindow = 'ADD_WINDOW';
  static const String editWindow = 'EDIT_WINDOW';
  static const String deleteWindow = 'DELETE_WINDOW';
  static const String toggleWindowHold = 'TOGGLE_WINDOW_HOLD';

  // Sharing/Export
  static const String shareCustomer = 'SHARE_CUSTOMER';
  static const String printDocument = 'PRINT_DOCUMENT';
  static const String generatePdf = 'GENERATE_PDF';

  // Sync
  static const String manualSync = 'MANUAL_SYNC';
  static const String clearData = 'CLEAR_DATA';

  // Settings
  static const String changeTheme = 'CHANGE_THEME';
  static const String changeSettings = 'CHANGE_SETTINGS';

  // Search
  static const String searchCustomers = 'SEARCH_CUSTOMERS';
}

/// Screen names for consistency
class ScreenNames {
  static const String home = 'HomeScreen';
  static const String customerDetail = 'CustomerDetailScreen';
  static const String addCustomer = 'AddCustomerScreen';
  static const String windowInput = 'WindowInputScreen';
  static const String windowScreen = 'WindowScreen';
  static const String settings = 'SettingsScreen';
  static const String about = 'AboutScreen';
  static const String logViewer = 'LogViewerScreen';
}
