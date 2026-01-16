import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';
import '../models/customer.dart';
import '../models/window.dart';
import '../models/enquiry.dart';
import '../models/activity_log.dart';
import '../services/app_logger.dart';
import '../services/device_id_service.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  static String? _databasePath;
  static Completer<Database>? _initCompleter; // Lock for initialization
  final AppLogger _logger = AppLogger();

  static const _databaseVersion = 7;

  DatabaseHelper._init();

  Future<Database> get database async {
    // If already initialized, return immediately
    if (_database != null) return _database!;

    // If initialization is in progress, wait for it
    if (_initCompleter != null) {
      await _logger.debug('DB', 'Waiting for existing initialization...');
      return _initCompleter!.future;
    }

    // Start initialization with lock
    _initCompleter = Completer<Database>();

    try {
      _database = await _initDB('window_measurements_v3.db');
      _initCompleter!.complete(_database);
      return _database!;
    } catch (e) {
      _initCompleter!.completeError(e);
      _initCompleter = null;
      rethrow;
    }
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    _databasePath = path;

    await _logger.info(
      'DB',
      'Opening database (SINGLE CONNECTION)',
      'path=$path, version=$_databaseVersion',
    );

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future _createDB(Database db, int version) async {
    // UUIDs are stored as TEXT
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const textNullableType = 'TEXT';
    const doubleType = 'REAL NOT NULL';
    const doubleNullableType = 'REAL';
    const boolType = 'INTEGER NOT NULL DEFAULT 0';
    const intType = 'INTEGER NOT NULL';

    // Sync Status: 0=Synced, 1=Created, 2=Updated, 3=Deleted
    const syncStatusType = 'INTEGER NOT NULL DEFAULT 1';

    await db.execute('''
      CREATE TABLE customers (
        id $idType,
        user_id $textNullableType,
        name $textType,
        location $textType,
        phone $textNullableType,
        framework $textType,
        glass_type $textNullableType,
        rate_per_sqft $doubleNullableType,
        is_final_measurement $boolType,
        created_at $textType,
        updated_at $textNullableType,
        is_deleted $boolType,
        sync_status $syncStatusType
      )
    ''');

    // Indices for Customers
    await db.execute(
      'CREATE INDEX idx_customers_user_id ON customers(user_id)',
    );
    await db.execute(
      'CREATE INDEX idx_customers_sync_status ON customers(sync_status)',
    );

    await db.execute('''
      CREATE TABLE windows (
        id $idType,
        user_id $textNullableType,
        customer_id $textType,
        name $textType,
        width $doubleType,
        height $doubleType,
        type $textType,
        width2 $doubleNullableType,
        formula $textNullableType,
        custom_name $textNullableType,
        quantity $intType DEFAULT 1,
        is_on_hold $boolType,
        notes $textNullableType,
        created_at $textNullableType,
        updated_at $textNullableType,
        is_deleted $boolType,
        sync_status $syncStatusType,
        FOREIGN KEY (customer_id) REFERENCES customers (id) ON DELETE CASCADE
      )
    ''');

    // Indices for Windows
    await db.execute('CREATE INDEX idx_windows_user_id ON windows(user_id)');
    await db.execute(
      'CREATE INDEX idx_windows_customer_id ON windows(customer_id)',
    );
    await db.execute(
      'CREATE INDEX idx_windows_sync_status ON windows(sync_status)',
    );

    // Activity Logs table
    await db.execute('''
      CREATE TABLE activity_logs (
        id $idType,
        device_id $textType,
        action_name $textType,
        page $textType,
        context $textNullableType,
        timestamp $textType,
        sync_status $syncStatusType
      )
    ''');

    // Indices for Activity Logs
    await db.execute(
      'CREATE INDEX idx_activity_logs_device_id ON activity_logs(device_id)',
    );
    await db.execute(
      'CREATE INDEX idx_activity_logs_sync_status ON activity_logs(sync_status)',
    );
    await db.execute(
      'CREATE INDEX idx_activity_logs_timestamp ON activity_logs(timestamp)',
    );

    // Enquiries table
    await db.execute('''
      CREATE TABLE enquiries (
        id $idType,
        user_id $textNullableType,
        name $textType,
        phone $textNullableType,
        location $textNullableType,
        requirements $textNullableType,
        expected_windows $textNullableType,
        notes $textNullableType,
        status $textType,
        reminder_date $textNullableType,
        created_at $textType,
        updated_at $textNullableType,
        sync_status $syncStatusType,
        is_deleted $boolType
      )
    ''');

    // Indices for Enquiries
    await db.execute(
      'CREATE INDEX idx_enquiries_user_id ON enquiries(user_id)',
    );
    await db.execute(
      'CREATE INDEX idx_enquiries_sync_status ON enquiries(sync_status)',
    );
    await db.execute('CREATE INDEX idx_enquiries_status ON enquiries(status)');
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 4) {
      // Upgrade to v4: Add indices
      // Check if indices exist first? CREATE INDEX IF NOT EXISTS is widely supported but safely:
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_customers_user_id ON customers(user_id)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_customers_sync_status ON customers(sync_status)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_windows_user_id ON windows(user_id)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_windows_customer_id ON windows(customer_id)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_windows_sync_status ON windows(sync_status)',
      );
    }

    if (oldVersion < 5) {
      // Upgrade to v5: Add L-Corner fields
      await db.execute('ALTER TABLE windows ADD COLUMN width2 REAL');
      await db.execute('ALTER TABLE windows ADD COLUMN formula TEXT');
      await db.execute('ALTER TABLE windows ADD COLUMN custom_name TEXT');
    }

    if (oldVersion < 6) {
      // Upgrade to v6: Add activity_logs table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS activity_logs (
          id TEXT PRIMARY KEY,
          device_id TEXT NOT NULL,
          action_name TEXT NOT NULL,
          page TEXT NOT NULL,
          context TEXT,
          timestamp TEXT NOT NULL,
          sync_status INTEGER NOT NULL DEFAULT 1
        )
      ''');
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_activity_logs_device_id ON activity_logs(device_id)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_activity_logs_sync_status ON activity_logs(sync_status)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_activity_logs_timestamp ON activity_logs(timestamp)',
      );
    }

    if (oldVersion < 7) {
      // Upgrade to v7: Add enquiries table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS enquiries (
          id TEXT PRIMARY KEY,
          user_id TEXT,
          name TEXT NOT NULL,
          phone TEXT,
          location TEXT,
          requirements TEXT,
          expected_windows TEXT,
          notes TEXT,
          status TEXT NOT NULL DEFAULT 'pending',
          reminder_date TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT,
          sync_status INTEGER NOT NULL DEFAULT 1,
          is_deleted INTEGER NOT NULL DEFAULT 0
        )
      ''');
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_enquiries_user_id ON enquiries(user_id)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_enquiries_sync_status ON enquiries(sync_status)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_enquiries_status ON enquiries(status)',
      );
    }
  }

  // ==================== Customer Operations ====================

  Future<Customer> createCustomer(Customer customer) async {
    final db = await instance.database;
    final map = customer.toMap();
    // Ensure ID is set
    if (map['id'] == null) {
      map['id'] = const Uuid().v4();
    }
    map['sync_status'] = 1; // Created
    map['is_deleted'] = 0;

    // createdAt is handled by model usually, but ensure it's in map
    if (map['created_at'] == null) {
      map['created_at'] = DateTime.now().toIso8601String();
    }
    map['user_id'] = await DeviceIdService.instance.getDeviceId();
    map['updated_at'] = DateTime.now().toIso8601String();

    await db.insert('customers', map);

    // return payload with new ID
    return Customer.fromMap(map);
  }

  Future<Customer?> readCustomer(String id) async {
    final db = await instance.database;
    final maps = await db.query(
      'customers',
      where: 'id = ? AND is_deleted = 0',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Customer.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<List<Customer>> readCustomersWithStats() async {
    final db = await instance.database;
    try {
      /*
      // Optimized query to get customer details + window count + total area in ONE go.
      // Updated to include L-Corner Formula A and B logic in SqFt calculation
      */
      final result = await db.rawQuery('''
        SELECT 
          c.*,
          COALESCE(SUM(CASE WHEN w.is_deleted = 0 THEN w.quantity ELSE 0 END), 0) as window_count,
          COALESCE(SUM(
            CASE 
              WHEN w.is_deleted = 0 THEN 
                CASE 
                  WHEN (w.type = 'LC' OR w.type = 'L-Corner') AND w.width2 IS NOT NULL THEN
                    CASE 
                      WHEN w.formula = 'A' THEN ((w.width + w.width2) * w.height * w.quantity) / 90903.0
                      ELSE ((w.width * w.height) + (w.width2 * w.height)) * w.quantity / 92903.04
                    END
                  ELSE (w.width * w.height * w.quantity) / 92903.04
                END
              ELSE 0 
            END
          ), 0.0) as total_sqft
        FROM customers c
        LEFT JOIN windows w ON c.id = w.customer_id
        WHERE c.is_deleted = 0
        GROUP BY c.id
        ORDER BY c.created_at DESC
      ''');

      /*
      // DEBUG: Log the raw result to check if stats are coming through
      if (result.isNotEmpty) {
        await _logger.debug('DB', 'First customer stats', '${result.first}');
      }
      */

      return result.map((json) {
        // The raw query returns columns. Customer.fromMap handles the standard ones.
        // We ensured fromMap looks for 'window_count' and 'total_sqft'.
        return Customer.fromMap(json);
      }).toList();
    } catch (e) {
      await _logger.error('DB', 'readCustomersWithStats FAILED', 'error=$e');
      return [];
    }
  }

  // Deprecated/Basic version if needed, but we prefer the one above for Home Screen
  Future<List<Customer>> readAllCustomers() async {
    return await readCustomersWithStats();
  }

  Future<int> updateCustomer(Customer customer) async {
    final db = await instance.database;
    final map = customer.toMap();

    map['updated_at'] = DateTime.now().toIso8601String();

    // status: if currently Synced(0), becomes Updated(2).
    // If Created(1), stays Created(1).
    // If Updated(2), stays Updated(2).
    final current = await readCustomer(customer.id!);
    int newStatus = 2; // Default to Updated
    if (current != null && current.syncStatus == 1) {
      newStatus = 1; // Keep as Created if not yet synced
    }

    map['sync_status'] = newStatus;

    await _logger.info(
      'DB',
      'Updating customer',
      'id=${customer.id}, status=$newStatus',
    );

    return db.update(
      'customers',
      map,
      where: 'id = ?',
      whereArgs: [customer.id],
    );
  }

  Future<int> deleteCustomer(String id) async {
    final db = await instance.database;

    try {
      // Check current status
      final result = await db.query(
        'customers',
        columns: ['sync_status'],
        where: 'id = ?',
        whereArgs: [id],
      );
      if (result.isEmpty) {
        await _logger.warn(
          'DB',
          'deleteCustomer: Customer not found',
          'id=$id',
        );
        return 0;
      }

      int currentStatus = result.first['sync_status'] as int;
      await _logger.info(
        'DB',
        'Deleting customer',
        'id=$id, currentStatus=$currentStatus',
      );

      if (currentStatus == 1) {
        // CASE 1: Created but NOT synced. Safe to HARD DELETE everything.
        // Hard delete windows first (manual cascade)
        final wDel = await db.delete(
          'windows',
          where: 'customer_id = ?',
          whereArgs: [id],
        );
        final cDel = await db.delete(
          'customers',
          where: 'id = ?',
          whereArgs: [id],
        );

        await _logger.info(
          'DB',
          'Hard deleted local-only customer',
          'windows=$wDel, customer=$cDel',
        );
        return cDel;
      } else {
        // CASE 2: Synced (0) or Updated (2). Must SOFT DELETE to sync deletion to server.
        // Mark Customer as Deleted(3)
        // Mark Windows:
        //  - If Window is Created(1) -> HARD DELETE (server never knew about it)
        //  - Else -> SOFT DELETE (is_deleted=1, sync_status=3)

        // 1. Hard delete local-only windows
        final wHardDel = await db.delete(
          'windows',
          where: 'customer_id = ? AND sync_status = 1',
          whereArgs: [id],
        );

        // 2. Soft delete the rest of the windows
        // We set is_deleted=1 and sync_status=3
        final wSoftDel = await db.update(
          'windows',
          {
            'is_deleted': 1,
            'sync_status': 3,
            'updated_at': DateTime.now().toIso8601String(),
          },
          where: 'customer_id = ? AND sync_status != 1',
          whereArgs: [id],
        );

        await _logger.info(
          'DB',
          'Soft deleting windows',
          'hard_deleted=$wHardDel, soft_deleted=$wSoftDel',
        );

        // 3. Update Customer to Deleted
        return await db.update(
          'customers',
          {
            'is_deleted': 1,
            'sync_status': 3,
            'updated_at': DateTime.now().toIso8601String(),
          },
          where: 'id = ?',
          whereArgs: [id],
        );
      }
    } catch (e) {
      await _logger.error('DB', 'deleteCustomer FAILED', 'error=$e');
      rethrow;
    }
  }

  // ==================== Enquiry Operations ====================

  Future<Enquiry> createEnquiry(Enquiry enquiry) async {
    final db = await instance.database;
    final map = enquiry.toMap();

    if (map['id'] == null) {
      map['id'] = const Uuid().v4();
    }
    map['sync_status'] = 1; // Created
    map['is_deleted'] = 0;

    if (map['created_at'] == null) {
      map['created_at'] = DateTime.now().toIso8601String();
    }
    map['user_id'] = await DeviceIdService.instance.getDeviceId();
    map['updated_at'] = DateTime.now().toIso8601String();

    await db.insert('enquiries', map);
    return Enquiry.fromMap(map);
  }

  Future<Enquiry?> readEnquiry(String id) async {
    final db = await instance.database;
    final maps = await db.query(
      'enquiries',
      where: 'id = ? AND is_deleted = 0',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Enquiry.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<List<Enquiry>> readAllEnquiries({String? statusFilter}) async {
    final db = await instance.database;
    final String whereClause = statusFilter != null
        ? 'is_deleted = 0 AND status = ?'
        : 'is_deleted = 0';
    final List<Object?> whereArgs = statusFilter != null ? [statusFilter] : [];

    final result = await db.query(
      'enquiries',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'created_at DESC',
    );

    return result.map((json) => Enquiry.fromMap(json)).toList();
  }

  Future<int> updateEnquiry(Enquiry enquiry) async {
    final db = await instance.database;
    final map = enquiry.toMap();
    map['updated_at'] = DateTime.now().toIso8601String();

    final current = await readEnquiry(enquiry.id!);
    int newStatus = 2; // Updated
    if (current != null && current.syncStatus == 1) {
      newStatus = 1; // Keep as Created
    }
    map['sync_status'] = newStatus;

    return db.update(
      'enquiries',
      map,
      where: 'id = ?',
      whereArgs: [enquiry.id],
    );
  }

  Future<int> deleteEnquiry(String id) async {
    final db = await instance.database;
    final result = await db.query(
      'enquiries',
      columns: ['sync_status'],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isEmpty) return 0;
    int currentStatus = result.first['sync_status'] as int;

    if (currentStatus == 1) {
      // Created but not synced -> Hard Delete
      return await db.delete('enquiries', where: 'id = ?', whereArgs: [id]);
    } else {
      // Synced -> Soft Delete
      return await db.update(
        'enquiries',
        {
          'is_deleted': 1,
          'sync_status': 3,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }

  // ==================== Window Operations ====================

  Future<Window> createWindow(Window window) async {
    final db = await instance.database;
    final map = window.toMap();
    if (map['id'] == null) {
      map['id'] = const Uuid().v4();
    }
    map['sync_status'] = 1;
    map['is_deleted'] = 0;

    if (map['created_at'] == null) {
      map['created_at'] = DateTime.now().toIso8601String();
    }
    map['user_id'] = await DeviceIdService.instance.getDeviceId();
    map['updated_at'] = DateTime.now().toIso8601String();

    try {
      await _logger.debug(
        'DB',
        'Inserting window',
        'id=${map['id']}, customer_id=${map['customer_id']}, db_path=$_databasePath',
      );

      // Capture the row ID to verify insert actually worked
      final rowId = await db.insert('windows', map);
      await _logger.info(
        'DB',
        'Window INSERT returned',
        'rowId=$rowId, window_id=${map['id']}',
      );

      // IMMEDIATELY verify the data exists
      final verification = await db.query(
        'windows',
        where: 'id = ?',
        whereArgs: [map['id']],
      );
      await _logger.info(
        'DB',
        'Window INSERT verification',
        'found=${verification.length} rows for id=${map['id']}',
      );

      if (verification.isEmpty) {
        await _logger.error(
          'DB',
          'CRITICAL: Window not found after INSERT!',
          'id=${map['id']}',
        );
      }

      return Window.fromMap(map);
    } catch (e) {
      await _logger.error(
        'DB',
        'FAILED to create window',
        'Error: $e, Data: $map',
      );
      rethrow;
    }
  }

  Future<List<Window>> readWindowsByCustomer(String customerId) async {
    final db = await instance.database;
    final result = await db.query(
      'windows',
      where: 'customer_id = ? AND is_deleted = 0',
      whereArgs: [customerId],
      orderBy: 'created_at ASC',
    );
    return result.map((json) => Window.fromMap(json)).toList();
  }

  Future<Window?> readWindow(String id) async {
    final db = await instance.database;
    final maps = await db.query(
      'windows',
      where: 'id = ? AND is_deleted = 0',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Window.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<int> updateWindow(Window window) async {
    final db = await instance.database;
    final map = window.toMap();
    map['updated_at'] = DateTime.now().toIso8601String();

    final current = await readWindow(window.id!);
    int newStatus = 2;
    if (current != null && current.syncStatus == 1) {
      newStatus = 1;
    }
    map['sync_status'] = newStatus;

    return db.update('windows', map, where: 'id = ?', whereArgs: [window.id]);
  }

  Future<int> deleteWindow(String id) async {
    final db = await instance.database;

    final result = await db.query(
      'windows',
      columns: ['sync_status'],
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return 0;
    int currentStatus = result.first['sync_status'] as int;

    if (currentStatus == 1) {
      return await db.delete('windows', where: 'id = ?', whereArgs: [id]);
    } else {
      return await db.update(
        'windows',
        {
          'is_deleted': 1,
          'sync_status': 3,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }

  Future<void> batchSaveWindows(List<Window> windows) async {
    final db = await instance.database;
    await db.transaction((txn) async {
      final batch = txn.batch();
      for (var window in windows) {
        final map = window.toMap();
        map['updated_at'] = DateTime.now().toIso8601String();

        if (window.id == null) {
          // CREATE
          map['id'] = const Uuid().v4();
          map['sync_status'] = 1;
          map['is_deleted'] = 0;
          if (map['created_at'] == null) {
            map['created_at'] = DateTime.now().toIso8601String();
          }
          map['user_id'] = await DeviceIdService.instance.getDeviceId();
          batch.insert('windows', map);
        } else {
          // UPDATE
          // Check current status only if needed, but for batch efficiency we might skip the read check
          // and just set to Updated(2) if it was Synced(0).
          // However, if it was Created(1), it should stay 1.
          // Reading inside batch for every row might be slow?
          // Let's optimisticly set to 2, or maybe reading is fine in txn.
          // Better: Use `txn.query` to check.
          // For simplicity and speed in batch, we can assume typical update flow.
          // But to be correct:

          // We can't easily read inside the batch commit loop easily if we use batch.commit().
          // If we don't use batch(), we can await txn.query.
          // `db.transaction` allows async await.

          // Let's use individual txn operations instead of batch() object for logic handling
          // OR just use SQL: UPDATE windows SET ... WHERE id=?
          // Setting sync_status logic in SQL:
          // sync_status = CASE WHEN sync_status = 1 THEN 1 ELSE 2 END
          map['sync_status'] = 2; // Default
        }
      }
    });

    // Re-implementing with individual txn awaits for correctness on SyncStatus logic
    await db.transaction((txn) async {
      for (var window in windows) {
        final map = window.toMap();
        map['updated_at'] = DateTime.now().toIso8601String();

        if (window.id == null) {
          // INSERT
          map['id'] = const Uuid().v4();
          map['sync_status'] = 1;
          map['is_deleted'] = 0;
          if (map['created_at'] == null) {
            map['created_at'] = DateTime.now().toIso8601String();
          }
          map['user_id'] = await DeviceIdService.instance.getDeviceId();
          await txn.insert('windows', map);
        } else {
          // UPDATE
          // Check existing status
          final List<Map<String, dynamic>> existing = await txn.query(
            'windows',
            columns: ['sync_status'],
            where: 'id = ?',
            whereArgs: [window.id],
          );

          int newStatus = 2;
          if (existing.isNotEmpty) {
            final currentStatus = existing.first['sync_status'] as int;
            if (currentStatus == 1) newStatus = 1;
          }
          map['sync_status'] = newStatus;

          await txn.update(
            'windows',
            map,
            where: 'id = ?',
            whereArgs: [window.id],
          );
        }
      }
    });
  }

  // Get unsynced (dirty) customers
  Future<List<Customer>> getUnsyncedCustomers() async {
    final db = await instance.database;
    final result = await db.query('customers', where: 'sync_status != 0');
    // Includes Created(1), Updated(2), Deleted(3)
    return result.map((json) => Customer.fromMap(json)).toList();
  }

  // Get unsynced (dirty) windows
  Future<List<Window>> getUnsyncedWindows() async {
    final db = await instance.database;
    final result = await db.query('windows', where: 'sync_status != 0');
    return result.map((json) => Window.fromMap(json)).toList();
  }

  // ==================== Remote Sync Upserts ====================

  Future<void> upsertCustomerFromRemote(Map<String, dynamic> data) async {
    final db = await instance.database;
    // status=0 indicates it's synced from server
    data['sync_status'] = 0;
    // Ensure boolean fields are 0/1 ints for SQLite
    if (data['is_deleted'] is bool)
      data['is_deleted'] = data['is_deleted'] ? 1 : 0;
    if (data['is_final_measurement'] is bool)
      data['is_final_measurement'] = data['is_final_measurement'] ? 1 : 0;

    await db.insert(
      'customers',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> upsertWindowFromRemote(Map<String, dynamic> data) async {
    final db = await instance.database;
    data['sync_status'] = 0;
    if (data['is_deleted'] is bool)
      data['is_deleted'] = data['is_deleted'] ? 1 : 0;
    if (data['is_on_hold'] is bool)
      data['is_on_hold'] = data['is_on_hold'] ? 1 : 0;

    await db.insert(
      'windows',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> upsertEnquiryFromRemote(Map<String, dynamic> data) async {
    final db = await instance.database;
    data['sync_status'] = 0;
    if (data['is_deleted'] is bool)
      data['is_deleted'] = data['is_deleted'] ? 1 : 0;

    await db.insert(
      'enquiries',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> markAllAsUnsynced() async {
    final db = await instance.database;
    // Set all to Created(1) or Updated(2)?
    // Setting to Updated(2) ensures they get pushed.
    await db.update('customers', {'sync_status': 2});
    await db.update('windows', {'sync_status': 2});
    await db.update('enquiries', {'sync_status': 2});
    await _logger.info('DB', 'Marked all data as unsynced (Force Push mode)');
  }

  // Mark as synced
  Future<void> markCustomerSynced(String id) async {
    final db = await instance.database;
    // If it was marked as deleted(3), we should now hard delete it?
    // Or keep it as soft deleted with synced status?
    // Usually soft delete + synced(0) means "Server knows it's deleted".
    // We can just keep it or remove it. Let's keep it clean: Hard delete if it was is_deleted=1?
    // For now, just set sync_status=0.
    await db.update(
      'customers',
      {'sync_status': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> markWindowSynced(String id) async {
    await _logger.debug('DB', 'markWindowSynced called', 'id=$id');
    final db = await instance.database;
    final rowsAffected = await db.update(
      'windows',
      {'sync_status': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
    await _logger.info(
      'DB',
      'markWindowSynced completed',
      'id=$id, rowsAffected=$rowsAffected',
    );
  }

  Future<void> markEnquirySynced(String id) async {
    final db = await instance.database;
    await db.update(
      'enquiries',
      {'sync_status': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== Activity Log Operations ====================

  Future<ActivityLog> createActivityLog(ActivityLog log) async {
    final db = await instance.database;
    final map = log.toMap();

    if (map['id'] == null) {
      map['id'] = const Uuid().v4();
    }
    map['sync_status'] = 1; // Created

    await db.insert('activity_logs', map);
    return ActivityLog.fromMap(map);
  }

  Future<List<ActivityLog>> getUnsyncedActivityLogs() async {
    final db = await instance.database;
    final result = await db.query(
      'activity_logs',
      where: 'sync_status != 0',
      orderBy: 'timestamp ASC',
    );
    return result.map((json) => ActivityLog.fromMap(json)).toList();
  }

  Future<void> markActivityLogsSynced(List<String> ids) async {
    if (ids.isEmpty) return;

    final db = await instance.database;
    final placeholders = List.filled(ids.length, '?').join(',');
    await db.rawUpdate(
      'UPDATE activity_logs SET sync_status = 0 WHERE id IN ($placeholders)',
      ids,
    );
  }

  Future<int> cleanOldActivityLogs() async {
    final db = await instance.database;
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    return await db.delete(
      'activity_logs',
      where: 'sync_status = 0 AND timestamp < ?',
      whereArgs: [cutoff.toIso8601String()],
    );
  }

  // Clean deleted items that are synced
  Future<void> cleanSyncedDeletes() async {
    await _logger.debug('DB', 'cleanSyncedDeletes starting...');
    final db = await instance.database;

    final windowsDeleted = await db.delete(
      'windows',
      where: 'is_deleted = 1 AND sync_status = 0',
    );
    final customersDeleted = await db.delete(
      'customers',
      where: 'is_deleted = 1 AND sync_status = 0',
    );
    final enquiriesDeleted = await db.delete(
      'enquiries',
      where: 'is_deleted = 1 AND sync_status = 0',
    );

    await _logger.info(
      'DB',
      'cleanSyncedDeletes completed',
      'windowsDeleted=$windowsDeleted, customersDeleted=$customersDeleted, enquiriesDeleted=$enquiriesDeleted',
    );
  }

  // Get unsynced enquiries
  Future<List<Enquiry>> getUnsyncedEnquiries() async {
    final db = await instance.database;
    final result = await db.query('enquiries', where: 'sync_status != 0');
    return result.map((json) => Enquiry.fromMap(json)).toList();
  }

  // No changes needed here, just removing the duplicates that follow.

  // ==================== Activity Log Operations ====================

  // Activity Log deduplicated above.

  /// Get recent activity logs for display
  Future<List<ActivityLog>> getRecentActivityLogs({int limit = 100}) async {
    final db = await instance.database;
    final result = await db.query(
      'activity_logs',
      orderBy: 'timestamp DESC',
      limit: limit,
    );
    return result.map((json) => ActivityLog.fromMap(json)).toList();
  }

  /// Get activity log count
  Future<int> getActivityLogCount() async {
    final db = await instance.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as cnt FROM activity_logs',
    );
    return result.first['cnt'] as int? ?? 0;
  }

  // Deduped above.

  // ==================== Utils ====================

  Future<Map<String, int>> getDatabaseStats() async {
    final db = await instance.database;

    // Log all window records for debugging
    final allWindows = await db.rawQuery(
      'SELECT id, customer_id, is_deleted, sync_status FROM windows',
    );
    await _logger.debug(
      'DB',
      'All windows in DB',
      'count=${allWindows.length}, data=$allWindows',
    );

    final customerCount =
        Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM customers WHERE is_deleted = 0',
          ),
        ) ??
        0;
    final windowCount =
        Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM windows WHERE is_deleted = 0',
          ),
        ) ??
        0;
    final enquiryCount =
        Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM enquiries WHERE is_deleted = 0',
          ),
        ) ??
        0;

    await _logger.info(
      'DB',
      'getDatabaseStats',
      'customers=$customerCount, windows=$windowCount',
    );

    return {
      'customerCount': customerCount,
      'windowCount': windowCount,
      'enquiryCount': enquiryCount,
    };
  }

  Future<void> clearAllData() async {
    final db = await instance.database;
    await db.delete('windows');
    await db.delete('customers');
    await db.delete('enquiries');
    await db.delete('activity_logs');
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
    _database = null;
  }
}
