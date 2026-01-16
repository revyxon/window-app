import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../db/database_helper.dart';
import '../models/activity_log.dart';
import 'device_id_service.dart';
import 'app_logger.dart';

class LogService {
  static final LogService _instance = LogService._internal();
  factory LogService() => _instance;
  LogService._internal();

  final AppLogger _logger = AppLogger();

  /// Log a generic event
  Future<void> logEvent(
    String actionName, {
    String page = 'Unknown',
    Map<String, dynamic>? details,
  }) async {
    try {
      final deviceId = await DeviceIdService.instance.getDeviceId();

      final log = ActivityLog(
        id: const Uuid().v4(),
        deviceId: deviceId,
        actionName: actionName,
        page: page,
        context: details != null ? jsonEncode(details) : null,
        timestamp: DateTime.now(),
        syncStatus: 1, // Created
      );

      await DatabaseHelper.instance.createActivityLog(log);
    } catch (e) {
      _logger.error('LOG', 'Failed to log event: $e');
    }
  }

  /// Convenience for screen views
  Future<void> logScreenView(String screenName, {String? details}) async {
    await logEvent(
      ActionNames.viewScreen,
      page: screenName,
      details: details != null ? {'info': details} : null,
    );
  }

  // --- Business Logic Tracking ---

  Future<void> logCustomerAction(
    String action,
    String customerId, {
    String? name,
  }) async {
    await logEvent(
      action,
      page: ScreenNames.customerDetail,
      details: {
        'customerId': customerId,
        if (name != null) 'customerName': name,
      },
    );
  }

  Future<void> logWindowAction(
    String action,
    String windowId, {
    String? customerId,
    bool? holdState,
  }) async {
    await logEvent(
      action,
      page: ScreenNames.windowInput,
      details: {
        'windowId': windowId,
        if (customerId != null) 'customerId': customerId,
        if (holdState != null) 'isOnHold': holdState,
      },
    );
  }

  Future<void> logShareAction(
    String action,
    String customerId,
    String type,
  ) async {
    await logEvent(
      action,
      page: ScreenNames.customerDetail,
      details: {'customerId': customerId, 'type': type},
    );
  }

  Future<void> logSettingsAction(
    String action,
    String setting,
    dynamic value,
  ) async {
    await logEvent(
      action,
      page: ScreenNames.settings,
      details: {'setting': setting, 'value': value.toString()},
    );
  }

  /// Clean old logs (older than 7 days)
  Future<void> cleanupOldLogs() async {
    try {
      final count = await DatabaseHelper.instance.cleanOldActivityLogs();
      if (count > 0) {
        _logger.info('LOG', 'Cleaned up $count old activity logs');
      }
    } catch (e) {
      _logger.error('LOG', 'Cleanup failed: $e');
    }
  }
}
