import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../db/database_helper.dart';
import 'firestore_service.dart';
import 'app_logger.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  bool _isSyncing = false;
  final StreamController<bool> _syncStatusController =
      StreamController<bool>.broadcast();
  Timer? _syncTimer;
  String? _lastError;

  Stream<bool> get isSyncingStream => _syncStatusController.stream;
  String? get lastError => _lastError;

  void initialize() async {
    // Run one-time migration to force resync of old Supabase data
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('migrated_to_firebase_reset_v3') != true) {
      await AppLogger().info(
        'SYNC',
        'Running one-time data migration for Firebase',
      );
      await DatabaseHelper.instance.markAllAsUnsynced();
      await prefs.setBool('migrated_to_firebase_reset_v3', true);
    }

    // Register device on first launch
    try {
      await FirestoreService().registerDevice(appVersion: '1.0.0');
    } catch (e) {
      await AppLogger().error('SYNC', 'Device registration failed: $e');
    }

    // Listen to network changes
    Connectivity().onConnectivityChanged.listen((result) {
      if (!result.contains(ConnectivityResult.none)) {
        syncData();
      }
    });

    // Periodic sync every 5 minutes
    _syncTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      syncData();
    });

    // Initial sync
    syncData();
  }

  /// Sync data to Firebase - returns error message if failed, null if success
  Future<String?> syncData() async {
    if (_isSyncing) return null; // Silent if already syncing

    _lastError = null;

    try {
      _isSyncing = true;
      _syncStatusController.add(true);

      // Sync customers
      await _syncCustomers();

      // Sync windows
      await _syncWindows();

      // Sync enquiries
      await _syncEnquiries();

      // Sync activity logs (push only - no pull needed)
      await _syncActivityLogs();

      // Update last active timestamp
      try {
        await FirestoreService().updateLastActive();
      } catch (_) {}

      return null; // Success
    } catch (e) {
      _lastError = e.toString();
      return _lastError;
    } finally {
      _isSyncing = false;
      _syncStatusController.add(false);
    }
  }

  Future<void> _syncCustomers() async {
    final db = DatabaseHelper.instance;
    final firestore = FirestoreService();

    // PUSH: Get dirty records and upload
    final dirtyCustomers = await db.getUnsyncedCustomers();

    if (dirtyCustomers.isNotEmpty) {
      final customersMap = dirtyCustomers.map((c) => c.toMap()).toList();
      try {
        await firestore.upsertCustomers(customersMap);
      } catch (e) {
        await AppLogger().error('SYNC', 'Failed to push customers: $e');
        rethrow;
      }

      // Mark as synced locally
      for (var c in dirtyCustomers) {
        if (c.id != null) {
          await db.markCustomerSynced(c.id!);
        }
      }
    }

    // PULL: Fetch from server (wrapped in try-catch to not block windows sync)
    try {
      final remoteCustomers = await firestore.fetchCustomers(
        since: DateTime.fromMillisecondsSinceEpoch(0),
      );

      for (var remoteData in remoteCustomers) {
        try {
          await db.upsertCustomerFromRemote(remoteData);
        } catch (e) {
          await AppLogger().error('SYNC', 'Failed to upsert customer: $e');
        }
      }
    } catch (e) {
      await AppLogger().error('SYNC', 'Failed to pull customers: $e');
    }
  }

  Future<void> _syncWindows() async {
    final db = DatabaseHelper.instance;
    final firestore = FirestoreService();

    // PUSH
    final dirtyWindows = await db.getUnsyncedWindows();

    if (dirtyWindows.isNotEmpty) {
      final windowsMap = dirtyWindows.map((w) => w.toMap()).toList();
      try {
        await firestore.upsertWindows(windowsMap);
      } catch (e) {
        await AppLogger().error('SYNC', 'Failed to push windows: $e');
        rethrow;
      }

      for (var w in dirtyWindows) {
        if (w.id != null) {
          await db.markWindowSynced(w.id!);
        }
      }
    }

    // PULL (wrapped in try-catch)
    try {
      final remoteWindows = await firestore.fetchWindows(
        since: DateTime.fromMillisecondsSinceEpoch(0),
      );

      for (var remoteData in remoteWindows) {
        try {
          await db.upsertWindowFromRemote(remoteData);
        } catch (e) {
          await AppLogger().error('SYNC', 'Failed to upsert window: $e');
        }
      }
    } catch (e) {
      await AppLogger().error('SYNC', 'Failed to pull windows: $e');
    }

    // Clean up deleted records that are synced
    await db.cleanSyncedDeletes();
  }

  Future<void> _syncEnquiries() async {
    final db = DatabaseHelper.instance;
    final firestore = FirestoreService();

    // PUSH
    final dirtyEnquiries = await db.getUnsyncedEnquiries();

    if (dirtyEnquiries.isNotEmpty) {
      final enquiriesMap = dirtyEnquiries.map((e) => e.toMap()).toList();
      try {
        await firestore.upsertEnquiries(enquiriesMap);
      } catch (e) {
        await AppLogger().error('SYNC', 'Failed to push enquiries: $e');
        rethrow;
      }

      for (var e in dirtyEnquiries) {
        if (e.id != null) {
          await db.markEnquirySynced(e.id!);
        }
      }
    }

    // PULL
    try {
      final remoteEnquiries = await firestore.fetchEnquiries(
        since: DateTime.fromMillisecondsSinceEpoch(0),
      );

      for (var remoteData in remoteEnquiries) {
        try {
          await db.upsertEnquiryFromRemote(remoteData);
        } catch (e) {
          await AppLogger().error('SYNC', 'Failed to upsert enquiry: $e');
        }
      }
    } catch (e) {
      await AppLogger().error('SYNC', 'Failed to pull enquiries: $e');
    }
  }

  /// Sync activity logs to Firebase (push only)
  Future<void> _syncActivityLogs() async {
    final db = DatabaseHelper.instance;
    final firestore = FirestoreService();

    try {
      final unsyncedLogs = await db.getUnsyncedActivityLogs();
      if (unsyncedLogs.isEmpty) return;

      final logsMap = unsyncedLogs.map((l) => l.toMap()).toList();
      await firestore.upsertActivityLogs(logsMap);

      // Mark as synced
      final ids = unsyncedLogs.map((l) => l.id!).toList();
      await db.markActivityLogsSynced(ids);

      // Clean old synced logs to save space
      await db.cleanOldActivityLogs();
    } catch (e) {
      // Don't rethrow - activity log sync failure shouldn't block other syncs
      await AppLogger().error('SYNC', 'Failed to sync activity logs: $e');
    }
  }

  Future<void> clearCloudData() async {
    try {
      await FirestoreService().clearAllCloudData();
    } catch (e) {
      await AppLogger().error('SYNC', 'Failed to clear cloud data: $e');
      rethrow;
    }
  }

  void dispose() {
    _syncTimer?.cancel();
    _syncStatusController.close();
  }
}
