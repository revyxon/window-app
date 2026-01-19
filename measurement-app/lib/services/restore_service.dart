import '../db/database_helper.dart';
import 'firestore_service.dart';
import 'app_logger.dart';

class RestoreResults {
  final int customers;
  final int windows;
  final int enquiries;
  final bool success;
  final String? error;

  RestoreResults({
    this.customers = 0,
    this.windows = 0,
    this.enquiries = 0,
    required this.success,
    this.error,
  });
}

class RestoreService {
  static final RestoreService _instance = RestoreService._internal();
  factory RestoreService() => _instance;
  RestoreService._internal();

  /// Restores all data from Cloud to Local DB.
  /// 1. Clears local DB (Optional? No, let's merge/overwrite logic).
  ///    Actually, "Restore" usually means "I lost my data, give it back".
  ///    But if we have local data, we should probably upsert.
  ///    Safest strategy: Upsert based on ID.
  Future<RestoreResults> restoreFromCloud({
    required Function(String stage, double progress) onProgress,
  }) async {
    final db = DatabaseHelper.instance;
    final firestore = FirestoreService();
    int customerCount = 0;
    int windowCount = 0;
    int enquiryCount = 0;

    try {
      await AppLogger().info('RESTORE', 'Starting Cloud Restore...');
      onProgress('Connecting to Cloud...', 0.1);

      // 1. Fetch Customers
      onProgress('Fetching Customers...', 0.2);
      final customers = await firestore.fetchCustomers(
        since: DateTime.fromMillisecondsSinceEpoch(0),
      );

      onProgress('Restoring ${customers.length} Customers...', 0.3);
      for (var data in customers) {
        await db.upsertCustomerFromRemote(data);
      }
      customerCount = customers.length;

      // 2. Fetch Windows
      onProgress('Fetching Windows...', 0.5);
      final windows = await firestore.fetchWindows(
        since: DateTime.fromMillisecondsSinceEpoch(0),
      );

      onProgress('Restoring ${windows.length} Windows...', 0.6);
      // Batch insert windows for performance?
      // SQLite batch support in our helper is 'batchSaveWindows', but that validates.
      // We can use upsertWindowFromRemote loop for safety or add a batch method.
      // For 1000s of records, a loop is slow.
      // Let's use loop for now, optimize if needed.
      for (var data in windows) {
        await db.upsertWindowFromRemote(data);
      }
      windowCount = windows.length;

      // 3. Fetch Enquiries
      onProgress('Fetching Enquiries...', 0.8);
      final enquiries = await firestore.fetchEnquiries(
        since: DateTime.fromMillisecondsSinceEpoch(0),
      );

      onProgress('Restoring ${enquiries.length} Enquiries...', 0.9);
      for (var data in enquiries) {
        await db.upsertEnquiryFromRemote(data);
      }
      enquiryCount = enquiries.length;

      onProgress('Finalizing...', 1.0);
      await AppLogger().info(
        'RESTORE',
        'Restore Complete',
        'c=$customerCount, w=$windowCount, e=$enquiryCount',
      );

      return RestoreResults(
        success: true,
        customers: customerCount,
        windows: windowCount,
        enquiries: enquiryCount,
      );
    } catch (e) {
      await AppLogger().error('RESTORE', 'Restore Failed', 'error=$e');
      return RestoreResults(success: false, error: e.toString());
    }
  }
}
