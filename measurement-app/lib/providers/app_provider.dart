import 'dart:async';
import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/customer.dart';
import '../models/window.dart';
import '../models/enquiry.dart';
import '../services/sync_service.dart';
import '../services/app_logger.dart';

class AppProvider with ChangeNotifier {
  List<Customer> _customers = [];
  List<Enquiry> _enquiries = [];
  bool _isLoading = false;
  final AppLogger _logger = AppLogger();

  List<Customer> get customers => _customers;
  List<Enquiry> get enquiries => _enquiries;
  bool get isLoading => _isLoading;

  Future<void> loadCustomers() async {
    _isLoading = true;
    notifyListeners();
    // Use optimized query
    _customers = await DatabaseHelper.instance.readCustomersWithStats();
    _isLoading = false;
    notifyListeners();
    // Trigger background sync to fetch latest if online
    unawaited(SyncService().syncData());
  }

  Future<Customer> addCustomer(Customer customer) async {
    final createdCustomer = await DatabaseHelper.instance.createCustomer(
      customer,
    );
    await loadCustomers();
    unawaited(SyncService().syncData());
    return createdCustomer;
  }

  Future<void> updateCustomer(Customer customer) async {
    await DatabaseHelper.instance.updateCustomer(customer);
    await loadCustomers();
    unawaited(SyncService().syncData());
  }

  Future<void> deleteCustomer(String id) async {
    await DatabaseHelper.instance.deleteCustomer(id);
    await loadCustomers();
    unawaited(SyncService().syncData());
  }

  // Enquiries
  Future<void> loadEnquiries() async {
    _isLoading = true;
    notifyListeners();
    _enquiries = await DatabaseHelper.instance.readAllEnquiries();
    _isLoading = false;
    notifyListeners();
  }

  Future<Enquiry> addEnquiry(Enquiry enquiry) async {
    final createdEnquiry = await DatabaseHelper.instance.createEnquiry(enquiry);
    await loadEnquiries();
    unawaited(SyncService().syncData());
    return createdEnquiry;
  }

  Future<void> updateEnquiry(Enquiry enquiry) async {
    await DatabaseHelper.instance.updateEnquiry(enquiry);
    await loadEnquiries();
    unawaited(SyncService().syncData());
  }

  Future<void> deleteEnquiry(String id) async {
    await DatabaseHelper.instance.deleteEnquiry(id);
    await loadEnquiries();
    unawaited(SyncService().syncData());
  }

  // Cache for windows to enable optimistic UI
  final Map<String, List<Window>> _windowCache = {};

  // Windows
  Future<List<Window>> getWindows(String customerId) async {
    if (_windowCache.containsKey(customerId)) {
      return _windowCache[customerId]!;
    }
    final windows = await DatabaseHelper.instance.readWindowsByCustomer(
      customerId,
    );
    _windowCache[customerId] = windows;
    return windows;
  }

  Future<void> addWindow(Window window) async {
    await _logger.info(
      'PROVIDER',
      'addWindow called',
      'customerId=${window.customerId}, name=${window.name}',
    );

    // Optimistic Update
    if (_windowCache.containsKey(window.customerId)) {
      _windowCache[window.customerId]!.add(window);
      notifyListeners();
    }

    try {
      await DatabaseHelper.instance.createWindow(window);
      await _logger.info(
        'PROVIDER',
        'Window added successfully',
        'customerId=${window.customerId}',
      );
      // Refresh customers list to update stats (count/sqft)
      await loadCustomers();
    } catch (e) {
      await _logger.error('PROVIDER', 'FAILED to add window', 'Error: $e');
      // Revert optimistic update on failure
      if (_windowCache.containsKey(window.customerId)) {
        _windowCache[window.customerId]!.removeWhere(
          (w) => w.name == window.name,
        );
        notifyListeners();
      }
      rethrow;
    }

    unawaited(SyncService().syncData());
  }

  Future<void> updateWindow(Window window) async {
    // Optimistic Update
    if (_windowCache.containsKey(window.customerId)) {
      final index = _windowCache[window.customerId]!.indexWhere(
        (w) => w.id == window.id,
      );
      if (index != -1) {
        _windowCache[window.customerId]![index] = window;
        notifyListeners();
      }
    }

    await DatabaseHelper.instance.updateWindow(window);
    await loadCustomers(); // Refresh stats
    unawaited(SyncService().syncData());
  }

  Future<void> deleteWindow(String id) async {
    // We need customerId to update cache efficiently, but we only have ID here.
    // We can search the cache.
    String? customerIdFound;
    for (var entry in _windowCache.entries) {
      if (entry.value.any((w) => w.id == id)) {
        customerIdFound = entry.key;
        break;
      }
    }

    if (customerIdFound != null) {
      _windowCache[customerIdFound]!.removeWhere((w) => w.id == id);
      notifyListeners();
    }

    await DatabaseHelper.instance.deleteWindow(id);
    await loadCustomers(); // Refresh stats
    unawaited(SyncService().syncData());
  }

  Future<int> getWindowCount(String customerId) async {
    if (_windowCache.containsKey(customerId)) {
      return _windowCache[customerId]!.length;
    }
    final windows = await DatabaseHelper.instance.readWindowsByCustomer(
      customerId,
    );
    _windowCache[customerId] = windows;
    return windows.length;
  }

  Future<double> getTotalSqFt(String customerId) async {
    List<Window> windows;
    if (_windowCache.containsKey(customerId)) {
      windows = _windowCache[customerId]!;
    } else {
      windows = await DatabaseHelper.instance.readWindowsByCustomer(customerId);
      _windowCache[customerId] = windows;
    }
    return windows.fold<double>(0.0, (sum, window) => sum + window.sqFt);
  }
}
