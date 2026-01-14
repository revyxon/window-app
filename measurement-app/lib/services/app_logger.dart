import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Log levels for filtering
enum LogLevel { debug, info, warn, error }

/// A single log entry
class LogEntry {
  final DateTime timestamp;
  final LogLevel level;
  final String tag;
  final String message;
  final String? data;

  LogEntry({
    required this.timestamp,
    required this.level,
    required this.tag,
    required this.message,
    this.data,
  });

  Map<String, dynamic> toJson() => {
    'timestamp': timestamp.toIso8601String(),
    'level': level.index,
    'tag': tag,
    'message': message,
    'data': data,
  };

  factory LogEntry.fromJson(Map<String, dynamic> json) => LogEntry(
    timestamp: DateTime.parse(json['timestamp']),
    level: LogLevel.values[json['level']],
    tag: json['tag'],
    message: json['message'],
    data: json['data'],
  );

  String get levelString {
    switch (level) {
      case LogLevel.debug:
        return 'DEBUG';
      case LogLevel.info:
        return 'INFO';
      case LogLevel.warn:
        return 'WARN';
      case LogLevel.error:
        return 'ERROR';
    }
  }

  String get formattedTime {
    final h = timestamp.hour.toString().padLeft(2, '0');
    final m = timestamp.minute.toString().padLeft(2, '0');
    final s = timestamp.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  String toString() {
    final dataStr = data != null ? ' | $data' : '';
    return '[$formattedTime] [$levelString] [$tag] $message$dataStr';
  }
}

/// Singleton App Logger - logs everything with 24-hour auto-cleanup
class AppLogger {
  static final AppLogger _instance = AppLogger._internal();
  factory AppLogger() => _instance;
  AppLogger._internal();

  static const String _storageKey = 'app_logs';
  static const int _maxLogAge = 24 * 60 * 60 * 1000; // 24 hours in ms

  final List<LogEntry> _logs = [];
  bool _initialized = false;

  List<LogEntry> get logs => List.unmodifiable(_logs);

  /// Initialize and load existing logs
  Future<void> initialize() async {
    if (_initialized) return;

    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_storageKey);

    if (stored != null) {
      try {
        final List<dynamic> decoded = jsonDecode(stored);
        _logs.clear();
        for (var item in decoded) {
          _logs.add(LogEntry.fromJson(item));
        }
      } catch (e) {
        // Corrupted logs, clear them
        await prefs.remove(_storageKey);
      }
    }

    // Clean old logs on startup
    await _cleanOldLogs();
    _initialized = true;

    info('LOGGER', 'App Logger initialized', 'Total logs: ${_logs.length}');
  }

  /// Clean logs older than 24 hours
  Future<void> _cleanOldLogs() async {
    final now = DateTime.now();
    final cutoff = now.subtract(const Duration(milliseconds: _maxLogAge));

    _logs.removeWhere((log) => log.timestamp.isBefore(cutoff));
    await _persist();
  }

  /// Persist logs to SharedPreferences
  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_logs.map((l) => l.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }

  /// Add a log entry
  Future<void> _log(
    LogLevel level,
    String tag,
    String message,
    String? data,
  ) async {
    final entry = LogEntry(
      timestamp: DateTime.now(),
      level: level,
      tag: tag,
      message: message,
      data: data,
    );

    _logs.add(entry);

    // Persist every log (could optimize with batching later)
    await _persist();
  }

  /// Log debug message
  Future<void> debug(String tag, String message, [String? data]) async {
    await _log(LogLevel.debug, tag, message, data);
  }

  /// Log info message
  Future<void> info(String tag, String message, [String? data]) async {
    await _log(LogLevel.info, tag, message, data);
  }

  /// Log warning message
  Future<void> warn(String tag, String message, [String? data]) async {
    await _log(LogLevel.warn, tag, message, data);
  }

  /// Log error message
  Future<void> error(String tag, String message, [String? data]) async {
    await _log(LogLevel.error, tag, message, data);
  }

  /// Clear all logs
  Future<void> clearLogs() async {
    _logs.clear();
    await _persist();
  }

  /// Get logs filtered by level
  List<LogEntry> getLogsByLevel(LogLevel level) {
    return _logs.where((l) => l.level == level).toList();
  }

  /// Get logs filtered by tag
  List<LogEntry> getLogsByTag(String tag) {
    return _logs
        .where((l) => l.tag.toLowerCase().contains(tag.toLowerCase()))
        .toList();
  }

  /// Search logs
  List<LogEntry> search(String query) {
    final q = query.toLowerCase();
    return _logs
        .where(
          (l) =>
              l.message.toLowerCase().contains(q) ||
              l.tag.toLowerCase().contains(q) ||
              (l.data?.toLowerCase().contains(q) ?? false),
        )
        .toList();
  }

  /// Export all logs as string
  String exportLogs() {
    return _logs.map((l) => l.toString()).join('\n');
  }

  /// Get log count by level
  Map<LogLevel, int> getLogStats() {
    return {
      LogLevel.debug: _logs.where((l) => l.level == LogLevel.debug).length,
      LogLevel.info: _logs.where((l) => l.level == LogLevel.info).length,
      LogLevel.warn: _logs.where((l) => l.level == LogLevel.warn).length,
      LogLevel.error: _logs.where((l) => l.level == LogLevel.error).length,
    };
  }
}
