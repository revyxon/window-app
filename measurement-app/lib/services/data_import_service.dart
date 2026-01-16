import 'dart:convert';
import 'dart:io';
import '../models/customer.dart';
import '../models/window.dart';
import '../db/database_helper.dart';
import 'app_logger.dart';

class DataImportService {
  static final DataImportService _instance = DataImportService._internal();
  factory DataImportService() => _instance;
  DataImportService._internal();

  final _logger = AppLogger();

  Future<Map<String, dynamic>> importFromFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return {'success': false, 'message': 'File not found'};
      }

      final content = await file.readAsString();
      final jsonData = jsonDecode(content);

      int customersImported = 0;
      int windowsImported = 0;

      // Handle List of Customers
      List<dynamic> list;
      if (jsonData is List) {
        list = jsonData;
      } else if (jsonData is Map && jsonData.containsKey('customers')) {
        list = jsonData['customers'];
      } else {
        // Try single object?
        list = [jsonData];
      }

      for (var item in list) {
        if (item is Map<String, dynamic>) {
          // Try Standard vs Legacy
          Customer? customer = _parseCustomer(item);
          if (customer != null) {
            // Save Customer
            // Check duplicates? For now, we assume simple import = create new or update if ID matches?
            // Existing logic: create new to avoid conflicts if ID weird?
            // Better: upsert. passing ID if exists.

            // We'll treat imported data as "New" usually to avoid overwriting valid data unless it's a restore.
            // But user said "fit old data into new schema". Implies migration.
            // We will generate NEW IDs to be safe, unless user specifies otherwise.

            final createdCustomer = await DatabaseHelper.instance
                .createCustomer(
                  customer.copyWith(
                    id: null, // Force new ID
                    syncStatus: 1, // Created
                    createdAt: DateTime.now(), // New timestamp
                  ),
                );
            customersImported++;

            // Parse Windows
            final windowsList = _extractWindows(item);
            for (var wMap in windowsList) {
              Window? win = _parseWindow(wMap);
              if (win != null) {
                await DatabaseHelper.instance.createWindow(
                  win.copyWith(
                    id: null,
                    customerId: createdCustomer.id, // Link to new customer
                    syncStatus: 1,
                  ),
                );
                windowsImported++;
              }
            }
          }
        }
      }

      return {
        'success': true,
        'message':
            'Imported $customersImported customers and $windowsImported windows',
      };
    } catch (e) {
      _logger.error('IMPORT', 'Failed to import', e.toString());
      return {'success': false, 'message': 'Import failed: $e'};
    }
  }

  Customer? _parseCustomer(Map<String, dynamic> map) {
    try {
      // 1. Try Standard Format
      if (map.containsKey('name') &&
          map.containsKey('location') &&
          map.containsKey('framework')) {
        return Customer.fromMap(map);
      }

      // 2. Try Legacy/Different Format (Heuristic)
      // "old data easily fit" handling
      return Customer(
        name:
            map['name'] ??
            map['clientName'] ??
            map['customer_name'] ??
            'Unknown Import',
        location: map['location'] ?? map['address'] ?? map['city'] ?? '',
        phone: map['phone'] ?? map['mobile'] ?? map['contact'] ?? '',
        framework: map['framework'] ?? map['system'] ?? 'Inventa', // Default
        glassType: map['glass_type'] ?? map['glass'] ?? map['glassType'],
        ratePerSqft: (map['rate_per_sqft'] ?? map['rate'] ?? map['price'])
            ?.toDouble(),
        createdAt: DateTime.now(),
        isFinalMeasurement: false, // Default
      );
    } catch (_) {
      return null;
    }
  }

  List<Map<String, dynamic>> _extractWindows(Map<String, dynamic> map) {
    if (map.containsKey('windows') && map['windows'] is List) {
      return List<Map<String, dynamic>>.from(map['windows']);
    }
    if (map.containsKey('measurements') && map['measurements'] is List) {
      // Legacy?
      return List<Map<String, dynamic>>.from(map['measurements']);
    }
    if (map.containsKey('items') && map['items'] is List) {
      // Legacy?
      return List<Map<String, dynamic>>.from(map['items']);
    }
    return [];
  }

  Window? _parseWindow(Map<String, dynamic> map) {
    try {
      // Standard
      if (map.containsKey('width') && map.containsKey('height')) {
        return Window(
          id: null,
          customerId: '', // Set later
          name: map['name'] ?? map['location'] ?? 'Window',
          width: (map['width'] ?? 0).toDouble(),
          height: (map['height'] ?? 0).toDouble(),
          type: map['type'] ?? 'Sliding',
          width2: (map['width2'] ?? map['width_b'])?.toDouble(),
          formula: map['formula'],
          quantity: (map['quantity'] ?? map['qty'] ?? 1).toInt(),
          isOnHold: false,
          createdAt: DateTime.now(),
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
