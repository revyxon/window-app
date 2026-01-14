import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// API Service for communicating with the license server
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  static const _storage = FlutterSecureStorage();
  static const _baseUrlKey = 'api_base_url';
  static const _apiKeyKey = 'api_key';

  String? _baseUrl;
  String? _apiKey;

  /// Initialize the service with stored credentials (HARDCODED)
  Future<void> initialize() async {
    // Hardcoded credentials as per user request to bypass login
    _baseUrl = 'https://window-license-server.vercel.app';
    _apiKey = '032007';
    // _baseUrl = await _storage.read(key: _baseUrlKey);
    // _apiKey = await _storage.read(key: _apiKeyKey);
  }

  /// Check if credentials are configured
  bool get isConfigured => _baseUrl != null && _apiKey != null;

  /// Get credentials for display
  String get baseUrl => _baseUrl ?? '';
  String get apiKey => _apiKey ?? '';

  /// Save credentials
  Future<void> saveCredentials(String baseUrl, String apiKey) async {
    await _storage.write(key: _baseUrlKey, value: baseUrl);
    await _storage.write(key: _apiKeyKey, value: apiKey);
    _baseUrl = baseUrl;
    _apiKey = apiKey;
  }

  /// Clear credentials
  Future<void> clearCredentials() async {
    await _storage.delete(key: _baseUrlKey);
    await _storage.delete(key: _apiKeyKey);
    _baseUrl = null;
    _apiKey = null;
  }

  static const String _hardcodedBaseUrl =
      'https://window-license-server.vercel.app';

  /// Make authenticated GET request
  Future<Map<String, dynamic>> get(String endpoint) async {
    final response = await http.get(
      Uri.parse('$_hardcodedBaseUrl$endpoint'),
      headers: {'Content-Type': 'application/json'},
    );

    return _handleResponse(response);
  }

  /// Make authenticated POST request
  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final response = await http.post(
      Uri.parse('$_hardcodedBaseUrl$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    return _handleResponse(response);
  }

  /// Make authenticated PATCH request
  Future<Map<String, dynamic>> patch(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final response = await http.patch(
      Uri.parse('$_hardcodedBaseUrl$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    return _handleResponse(response);
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } catch (e) {
        throw Exception('Failed to parse response: ${response.statusCode}');
      }
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized - check API key');
    } else {
      try {
        final body = jsonDecode(response.body);
        throw Exception(body['message'] ?? 'API error: ${response.statusCode}');
      } catch (_) {
        throw Exception('Server Error: ${response.statusCode}');
      }
    }
  }

  // ============ Admin API Methods ============

  /// Get all registered devices
  Future<Map<String, dynamic>> getUsers() async {
    return await get('/api/admin/users');
  }

  /// Get user details
  Future<Map<String, dynamic>> getUserDetails(String deviceId) async {
    return await get('/api/admin/users/$deviceId');
  }

  /// Update user status (lock/unlock)
  Future<Map<String, dynamic>> updateUserStatus(
    String deviceId,
    String status,
  ) async {
    return await patch('/api/admin/users/$deviceId', {'status': status});
  }

  /// Update user - general method supporting all fields
  Future<Map<String, dynamic>> updateUser(
    String deviceId, {
    String? status,
    Map<String, bool>? controls,
    String? lockReason,
  }) async {
    final body = <String, dynamic>{};
    if (status != null) body['status'] = status;
    if (controls != null) body['controls'] = controls;
    if (lockReason != null) body['lockReason'] = lockReason;
    return await patch('/api/admin/users/$deviceId', body);
  }

  /// Get analytics
  Future<Map<String, dynamic>> getAnalytics() async {
    return await get('/api/admin/analytics');
  }

  /// Get updates list
  Future<Map<String, dynamic>> getUpdates() async {
    return await get('/api/updates/upload');
  }

  /// Get upload URL for APK
  Future<Map<String, dynamic>> getUploadUrl(String fileName) async {
    return await get('/api/admin/updates/upload-url?fileName=$fileName');
  }

  /// Upload file to signed URL
  Future<void> uploadFile(String url, List<int> bytes) async {
    final response = await http.put(
      Uri.parse(url),
      headers: {'Content-Type': 'application/vnd.android.package-archive'},
      body: bytes,
    );
    if (response.statusCode != 200) {
      throw Exception(
        'Failed to upload file to storage: ${response.statusCode}',
      );
    }
  }

  /// Create new update
  Future<Map<String, dynamic>> createUpdate({
    required String version,
    required int buildNumber,
    required String apkUrl,
    required int fileSize,
    String? releaseNotes,
    bool forceUpdate = false,
    bool skipAllowed = true,
  }) async {
    return await post('/api/updates/upload', {
      'version': version,
      'buildNumber': buildNumber,
      'apkUrl': apkUrl,
      'fileSize': fileSize,
      'releaseNotes': releaseNotes,
      'forceUpdate': forceUpdate,
      'skipAllowed': skipAllowed,
    });
  }
}
