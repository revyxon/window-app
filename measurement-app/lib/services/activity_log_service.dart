import 'dart:convert';
import '../db/database_helper.dart';
import '../models/activity_log.dart';
import 'device_id_service.dart';

/// Service for logging user activity
/// Provides a simple API for screens to log actions
class ActivityLogService {
  static final ActivityLogService _instance = ActivityLogService._internal();
  factory ActivityLogService() => _instance;
  ActivityLogService._internal();

  String? _deviceId;

  /// Initialize the service (call in main.dart)
  Future<void> initialize() async {
    _deviceId = await DeviceIdService.instance.getDeviceId();
  }

  /// Get device ID (ensures it's loaded)
  Future<String> _getDeviceId() async {
    _deviceId ??= await DeviceIdService.instance.getDeviceId();
    return _deviceId!;
  }

  /// Log a user action
  ///
  /// [actionName] - Use constants from ActionNames class
  /// [page] - Use constants from ScreenNames class
  /// [context] - Optional map with additional context (will be JSON encoded)
  Future<void> log(
    String actionName,
    String page, {
    Map<String, dynamic>? context,
  }) async {
    try {
      final deviceId = await _getDeviceId();

      final log = ActivityLog(
        deviceId: deviceId,
        actionName: actionName,
        page: page,
        context: context != null ? jsonEncode(context) : null,
        timestamp: DateTime.now(),
      );

      await DatabaseHelper.instance.createActivityLog(log);
    } catch (e) {
      // Silently fail - logging should never crash the app
      print('ActivityLogService: Failed to log action: $e');
    }
  }

  /// Log screen view
  Future<void> logScreenView(String screenName) async {
    await log(ActionNames.viewScreen, screenName);
  }

  /// Log customer actions
  Future<void> logAddCustomer(String customerId, String customerName) async {
    await log(
      ActionNames.addCustomer,
      ScreenNames.addCustomer,
      context: {'customerId': customerId, 'customerName': customerName},
    );
  }

  Future<void> logViewCustomer(String customerId, String customerName) async {
    await log(
      ActionNames.viewCustomer,
      ScreenNames.customerDetail,
      context: {'customerId': customerId, 'customerName': customerName},
    );
  }

  Future<void> logEditCustomer(String customerId) async {
    await log(
      ActionNames.editCustomer,
      ScreenNames.addCustomer,
      context: {'customerId': customerId},
    );
  }

  Future<void> logDeleteCustomer(String customerId) async {
    await log(
      ActionNames.deleteCustomer,
      ScreenNames.customerDetail,
      context: {'customerId': customerId},
    );
  }

  /// Log window actions
  Future<void> logAddWindow(String customerId, String windowId) async {
    await log(
      ActionNames.addWindow,
      ScreenNames.windowInput,
      context: {'customerId': customerId, 'windowId': windowId},
    );
  }

  Future<void> logEditWindow(String windowId) async {
    await log(
      ActionNames.editWindow,
      ScreenNames.windowInput,
      context: {'windowId': windowId},
    );
  }

  Future<void> logDeleteWindow(String windowId) async {
    await log(
      ActionNames.deleteWindow,
      ScreenNames.windowInput,
      context: {'windowId': windowId},
    );
  }

  Future<void> logToggleWindowHold(String windowId, bool isOnHold) async {
    await log(
      ActionNames.toggleWindowHold,
      ScreenNames.windowInput,
      context: {'windowId': windowId, 'isOnHold': isOnHold},
    );
  }

  /// Log sharing/export actions
  Future<void> logShareCustomer(String customerId, String shareType) async {
    await log(
      ActionNames.shareCustomer,
      ScreenNames.customerDetail,
      context: {'customerId': customerId, 'shareType': shareType},
    );
  }

  Future<void> logPrintDocument(String customerId, String documentType) async {
    await log(
      ActionNames.printDocument,
      ScreenNames.customerDetail,
      context: {'customerId': customerId, 'documentType': documentType},
    );
  }

  Future<void> logGeneratePdf(String customerId, String pdfType) async {
    await log(
      ActionNames.generatePdf,
      ScreenNames.customerDetail,
      context: {'customerId': customerId, 'pdfType': pdfType},
    );
  }

  /// Log sync actions
  Future<void> logManualSync() async {
    await log(ActionNames.manualSync, ScreenNames.home);
  }

  Future<void> logClearData() async {
    await log(ActionNames.clearData, ScreenNames.settings);
  }

  /// Log settings changes
  Future<void> logChangeTheme(String theme) async {
    await log(
      ActionNames.changeTheme,
      ScreenNames.settings,
      context: {'theme': theme},
    );
  }

  Future<void> logChangeSettings(String settingName, dynamic value) async {
    await log(
      ActionNames.changeSettings,
      ScreenNames.settings,
      context: {'setting': settingName, 'value': value.toString()},
    );
  }

  /// Log search
  Future<void> logSearch(String query) async {
    await log(
      ActionNames.searchCustomers,
      ScreenNames.home,
      context: {'query': query},
    );
  }

  /// Get recent logs for debugging/display
  Future<List<ActivityLog>> getRecentLogs({int limit = 50}) async {
    return await DatabaseHelper.instance.getRecentActivityLogs(limit: limit);
  }
}
