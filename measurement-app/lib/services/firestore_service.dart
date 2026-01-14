import 'package:cloud_firestore/cloud_firestore.dart';
import 'device_id_service.dart';
import 'device_info_service.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _deviceId;

  Future<String> _getDeviceId() async {
    _deviceId ??= await DeviceIdService.instance.getDeviceId();
    return _deviceId!;
  }

  // CUSTOMERS
  Future<void> upsertCustomers(List<Map<String, dynamic>> customers) async {
    final deviceId = await _getDeviceId();

    // Firestore batch limit is 500
    const batchSize = 500;
    for (var i = 0; i < customers.length; i += batchSize) {
      final batch = _firestore.batch();
      final chunk = customers.sublist(
        i,
        i + batchSize > customers.length ? customers.length : i + batchSize,
      );

      for (var customer in chunk) {
        if (customer['id'] == null) continue;

        final cleaned = Map<String, dynamic>.from(customer);
        cleaned['deviceId'] =
            deviceId; // Use deviceId instead of user_id for RLS/Filter
        cleaned['updated_at'] =
            FieldValue.serverTimestamp(); // Use server timestamp (snake_case to match DB but serialized to camelCase by Firestore? No, matches map key)
        // wait, local DB uses snake_case 'updated_at'. serialized map keys are what we sent.
        // let's ensure we use consistent keys.
        // If local map has 'updated_at', and we write it to firestore, it's 'updated_at'.
        cleaned.remove('sync_status');

        final docRef = _firestore.collection('customers').doc(customer['id']);
        batch.set(docRef, cleaned, SetOptions(merge: true));
      }

      await batch.commit();
    }
  }

  Future<List<Map<String, dynamic>>> fetchCustomers({
    required DateTime since,
  }) async {
    try {
      final deviceId = await _getDeviceId();

      final snapshot = await _firestore
          .collection('customers')
          .where('deviceId', isEqualTo: deviceId)
          .get();

      return snapshot.docs.map((doc) => _processDocument(doc.data())).toList();
    } catch (e) {
      print('Firestore fetch customers error: $e');
      return [];
    }
  }

  // WINDOWS
  Future<void> upsertWindows(List<Map<String, dynamic>> windows) async {
    final deviceId = await _getDeviceId();

    // Firestore batch limit is 500
    const batchSize = 500;
    for (var i = 0; i < windows.length; i += batchSize) {
      final batch = _firestore.batch();
      final chunk = windows.sublist(
        i,
        i + batchSize > windows.length ? windows.length : i + batchSize,
      );

      for (var window in chunk) {
        if (window['id'] == null) continue;

        final cleaned = Map<String, dynamic>.from(window);
        cleaned['deviceId'] = deviceId;
        cleaned['updated_at'] = FieldValue.serverTimestamp();
        cleaned.remove('sync_status');

        final docRef = _firestore.collection('windows').doc(window['id']);
        batch.set(docRef, cleaned, SetOptions(merge: true));
      }

      await batch.commit();
    }
  }

  Future<List<Map<String, dynamic>>> fetchWindows({
    required DateTime since,
  }) async {
    try {
      final deviceId = await _getDeviceId();

      final snapshot = await _firestore
          .collection('windows')
          .where('deviceId', isEqualTo: deviceId)
          .get();

      return snapshot.docs.map((doc) => _processDocument(doc.data())).toList();
    } catch (e) {
      print('Firestore fetch windows error: $e');
      return [];
    }
  }

  // ENQUIRIES
  Future<void> upsertEnquiries(List<Map<String, dynamic>> enquiries) async {
    final deviceId = await _getDeviceId();

    // Firestore batch limit is 500
    const batchSize = 500;
    for (var i = 0; i < enquiries.length; i += batchSize) {
      final batch = _firestore.batch();
      final chunk = enquiries.sublist(
        i,
        i + batchSize > enquiries.length ? enquiries.length : i + batchSize,
      );

      for (var enquiry in chunk) {
        if (enquiry['id'] == null) continue;

        final cleaned = Map<String, dynamic>.from(enquiry);
        cleaned['deviceId'] = deviceId;
        cleaned['updated_at'] = FieldValue.serverTimestamp();
        cleaned.remove('sync_status');

        final docRef = _firestore.collection('enquiries').doc(enquiry['id']);
        batch.set(docRef, cleaned, SetOptions(merge: true));
      }

      await batch.commit();
    }
  }

  Future<List<Map<String, dynamic>>> fetchEnquiries({
    required DateTime since,
  }) async {
    try {
      final deviceId = await _getDeviceId();

      final snapshot = await _firestore
          .collection('enquiries')
          .where('deviceId', isEqualTo: deviceId)
          .get();

      return snapshot.docs.map((doc) => _processDocument(doc.data())).toList();
    } catch (e) {
      print('Firestore fetch enquiries error: $e');
      return [];
    }
  }

  // ACTIVITY LOGS
  Future<void> upsertActivityLogs(List<Map<String, dynamic>> logs) async {
    if (logs.isEmpty) return;

    final deviceId = await _getDeviceId();

    // Firestore batch limit is 500
    const batchSize = 500;
    for (var i = 0; i < logs.length; i += batchSize) {
      final batch = _firestore.batch();
      final chunk = logs.sublist(
        i,
        i + batchSize > logs.length ? logs.length : i + batchSize,
      );

      for (var log in chunk) {
        if (log['id'] == null) continue;

        final cleaned = Map<String, dynamic>.from(log);
        cleaned['deviceId'] = deviceId;
        cleaned.remove('sync_status');

        final docRef = _firestore.collection('activity_logs').doc(log['id']);
        batch.set(docRef, cleaned, SetOptions(merge: true));
      }

      await batch.commit();
    }
  }

  // DEVICE REGISTRATION
  Future<void> registerDevice({String? appVersion}) async {
    final deviceId = await _getDeviceId();
    final deviceInfo = await DeviceInfoService().getCompleteDeviceInfo();

    final docRef = _firestore.collection('devices').doc(deviceId);
    final doc = await docRef.get();

    if (!doc.exists) {
      // First time registration - store complete device info
      await docRef.set({
        'deviceId': deviceId,
        'status': 'active',
        'registeredAt': FieldValue.serverTimestamp(),
        'lastActiveAt': FieldValue.serverTimestamp(),
        'appVersion': appVersion,
        'deviceInfo': deviceInfo,
      });
      print('FIRESTORE: New device registered with full info: $deviceId');
    } else {
      // Update last active and device info (may have changed after updates)
      await docRef.update({
        'lastActiveAt': FieldValue.serverTimestamp(),
        'appVersion': appVersion,
        'deviceInfo': deviceInfo,
      });
    }
  }

  Future<Map<String, dynamic>?> getDeviceStatus() async {
    try {
      final deviceId = await _getDeviceId();
      final doc = await _firestore.collection('devices').doc(deviceId).get();

      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print('Firestore getDeviceStatus error: $e');
      return null;
    }
  }

  Future<void> updateLastActive() async {
    try {
      final deviceId = await _getDeviceId();
      await _firestore.collection('devices').doc(deviceId).update({
        'lastActiveAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Silently fail - device may not be registered yet
      print('Firestore updateLastActive error: $e');
    }
  }

  Future<void> updateUpdateSkipStatus({
    int? skipCount,
    String? lastSkippedVersion,
  }) async {
    try {
      final deviceId = await _getDeviceId();
      final updates = <String, dynamic>{};
      if (skipCount != null) updates['updateSkipCount'] = skipCount;
      if (lastSkippedVersion != null) {
        updates['lastSkippedVersion'] = lastSkippedVersion;
      }

      if (updates.isNotEmpty) {
        await _firestore.collection('devices').doc(deviceId).update(updates);
      }
    } catch (e) {
      print('Firestore updateUpdateSkipStatus error: $e');
    }
  }

  Future<void> clearAllCloudData() async {
    final deviceId = await _getDeviceId();
    print('FIRESTORE: Clearing all data for device: $deviceId');

    // 1. Delete all Windows
    final windows = await _firestore
        .collection('windows')
        .where('deviceId', isEqualTo: deviceId)
        .get();

    if (windows.docs.isNotEmpty) {
      final batch = _firestore.batch();
      for (var doc in windows.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      print('FIRESTORE: Deleted ${windows.docs.length} windows');
    }

    // 2. Delete all Customers
    final customers = await _firestore
        .collection('customers')
        .where('deviceId', isEqualTo: deviceId)
        .get();

    if (customers.docs.isNotEmpty) {
      final batch = _firestore.batch();
      for (var doc in customers.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      print('FIRESTORE: Deleted ${customers.docs.length} customers');
    }

    // 3. Delete all Activity Logs
    final activityLogs = await _firestore
        .collection('activity_logs')
        .where('deviceId', isEqualTo: deviceId)
        .get();

    if (activityLogs.docs.isNotEmpty) {
      final batch = _firestore.batch();
      for (var doc in activityLogs.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      print('FIRESTORE: Deleted ${activityLogs.docs.length} activity logs');
    }

    // 4. Delete all Enquiries
    final enquiries = await _firestore
        .collection('enquiries')
        .where('deviceId', isEqualTo: deviceId)
        .get();

    if (enquiries.docs.isNotEmpty) {
      final batch = _firestore.batch();
      for (var doc in enquiries.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      print('FIRESTORE: Deleted ${enquiries.docs.length} enquiries');
    }

    print('FIRESTORE: Cloud data cleared successfully.');
  }

  // Helper to convert Timestamp to String and normalize key names for local DB compatibility
  Map<String, dynamic> _processDocument(Map<String, dynamic> data) {
    // Create a new map to ensure mutability
    final Map<String, dynamic> converted = {};

    // Key mapping from camelCase (Firestore) to snake_case (SQLite)
    const keyMap = {
      'updatedAt': 'updated_at',
      'createdAt': 'created_at',
      'customerId': 'customer_id',
      'userId': 'user_id',
      'glassType': 'glass_type',
      'ratePerSqft': 'rate_per_sqft',
      'isFinalMeasurement': 'is_final_measurement',
      'isDeleted': 'is_deleted',
      'isOnHold': 'is_on_hold',
      'syncStatus': 'sync_status',
    };

    data.forEach((key, value) {
      // Normalize key name
      final normalizedKey = keyMap[key] ?? key;

      // Convert Timestamp to ISO string
      if (value is Timestamp) {
        converted[normalizedKey] = value.toDate().toIso8601String();
      } else if (value is Map) {
        converted[normalizedKey] = Map<String, dynamic>.from(value);
      } else {
        converted[normalizedKey] = value;
      }
    });

    // Remove Firestore-specific fields that don't exist in local DB
    converted.remove('deviceId');

    // Ensure sync_status is set to 0 (Synced) for pulled data
    converted['sync_status'] = 0;

    return converted;
  }
}
