import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
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
  StreamSubscription? _connectivitySubscription;
  String? _lastError;

  Stream<bool> get isSyncingStream => _syncStatusController.stream;
  String? get lastError => _lastError;

  Future<void> initialize() async {
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

    // Register device on first launch with actual app version
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      await FirestoreService().registerDevice(appVersion: packageInfo.version);
    } catch (e) {
      await AppLogger().error('SYNC', 'Device registration failed: $e');
    }

    // Listen to network changes
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      result,
    ) {
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

  /// Sync data to Firebase - Push only (Local -> Cloud)
  Future<String?> syncData() async {
    if (_isSyncing) return null;

    // Check connectivity explicitly
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      return null;
    }

    _lastError = null;

    try {
      _isSyncing = true;
      _syncStatusController.add(true);
      await AppLogger().info('SYNC', 'Starting 5m Sync (Push Only)...');

      // 1. Devices (Registration update)
      await FirestoreService().updateLastActive();

      // 2. Customers
      await _syncCustomers();

      // 3. Windows
      await _syncWindows();

      // 4. Enquiries
      await _syncEnquiries();

      // 5. Activity Logs
      await _syncActivityLogs();

      await AppLogger().info('SYNC', 'Sync Completed Successfully');
      return null;
    } catch (e) {
      _lastError = e.toString();
      await AppLogger().error('SYNC', 'Sync Failed', 'error=$e');
      return _lastError;
    } finally {
      _isSyncing = false;
      _syncStatusController.add(false);
    }
  }

  Future<void> _syncCustomers() async {
    final db = DatabaseHelper.instance;
    final firestore = FirestoreService();

    final dirty = await db.getUnsyncedCustomers();
    if (dirty.isNotEmpty) {
      await AppLogger().debug('SYNC', 'Pushing ${dirty.length} customers');
      final data = dirty.map((e) => e.toMap()).toList();
      await firestore.upsertCustomers(data);

      for (var item in dirty) {
        if (item.id != null) await db.markCustomerSynced(item.id!);
      }
    }
  }

  Future<void> _syncWindows() async {
    final db = DatabaseHelper.instance;
    final firestore = FirestoreService();

    final dirty = await db.getUnsyncedWindows();
    if (dirty.isNotEmpty) {
      await AppLogger().debug('SYNC', 'Pushing ${dirty.length} windows');
      final data = dirty.map((e) => e.toMap()).toList();
      await firestore.upsertWindows(data);

      for (var item in dirty) {
        if (item.id != null) await db.markWindowSynced(item.id!);
      }
    }
  }

  Future<void> _syncEnquiries() async {
    final db = DatabaseHelper.instance;
    final firestore = FirestoreService();

    final dirty = await db.getUnsyncedEnquiries();
    if (dirty.isNotEmpty) {
      await AppLogger().debug('SYNC', 'Pushing ${dirty.length} enquiries');
      final data = dirty.map((e) => e.toMap()).toList();
      await firestore.upsertEnquiries(data);

      for (var item in dirty) {
        if (item.id != null) await db.markEnquirySynced(item.id!);
      }
    }
  }

  Future<void> _syncActivityLogs() async {
    final db = DatabaseHelper.instance;
    final firestore = FirestoreService();

    final dirty = await db.getUnsyncedActivityLogs();
    if (dirty.isNotEmpty) {
      await AppLogger().debug('SYNC', 'Pushing ${dirty.length} logs');
      final data = dirty.map((e) => e.toMap()).toList();
      await firestore.upsertActivityLogs(data);

      // Batch mark as synced
      final ids = dirty.map((e) => e.id).whereType<String>().toList();
      await db.markActivityLogsSynced(ids);

      // Cleanup old logs
      await db.cleanOldActivityLogs();
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
    _connectivitySubscription?.cancel();
    _syncStatusController.close();
  }
}
