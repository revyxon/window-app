import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/app_logger.dart';

class LogViewerScreen extends StatefulWidget {
  const LogViewerScreen({super.key});

  @override
  State<LogViewerScreen> createState() => _LogViewerScreenState();
}

class _LogViewerScreenState extends State<LogViewerScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  LogLevel? _filterLevel;
  String _searchQuery = '';

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<LogEntry> get filteredLogs {
    var logs = AppLogger().logs;

    if (_filterLevel != null) {
      logs = logs.where((l) => l.level == _filterLevel).toList();
    }

    if (_searchQuery.isNotEmpty) {
      logs = logs
          .where(
            (l) =>
                l.message.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                l.tag.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                (l.data?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
                    false),
          )
          .toList();
    }

    // Most recent first
    return logs.reversed.toList();
  }

  Color _getLevelColor(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return const Color(0xFF6B7280); // Gray
      case LogLevel.info:
        return const Color(0xFF10B981); // Green
      case LogLevel.warn:
        return const Color(0xFFF59E0B); // Amber
      case LogLevel.error:
        return const Color(0xFFEF4444); // Red
    }
  }

  @override
  Widget build(BuildContext context) {
    final stats = AppLogger().getLogStats();

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E), // Terminal dark background
      appBar: AppBar(
        backgroundColor: const Color(0xFF252526),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'App Logs',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'monospace',
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy, color: Colors.white70, size: 20),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: AppLogger().exportLogs()));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Logs copied to clipboard')),
              );
            },
            tooltip: 'Copy All',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
            onPressed: () async {
              await AppLogger().clearLogs();
              setState(() {});
              if (mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Logs cleared')));
              }
            },
            tooltip: 'Clear Logs',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Stats Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: const Color(0xFF252526),
            child: Row(
              children: [
                _buildStatChip(
                  'DEBUG',
                  stats[LogLevel.debug] ?? 0,
                  const Color(0xFF6B7280),
                ),
                _buildStatChip(
                  'INFO',
                  stats[LogLevel.info] ?? 0,
                  const Color(0xFF10B981),
                ),
                _buildStatChip(
                  'WARN',
                  stats[LogLevel.warn] ?? 0,
                  const Color(0xFFF59E0B),
                ),
                _buildStatChip(
                  'ERROR',
                  stats[LogLevel.error] ?? 0,
                  const Color(0xFFEF4444),
                ),
              ],
            ),
          ),
          // Search & Filter Bar
          Container(
            padding: const EdgeInsets.all(12),
            color: const Color(0xFF2D2D2D),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'monospace',
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search logs...',
                      hintStyle: TextStyle(color: Colors.grey.shade600),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.grey,
                        size: 20,
                      ),
                      filled: true,
                      fillColor: const Color(0xFF1E1E1E),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onChanged: (v) => setState(() => _searchQuery = v),
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<LogLevel?>(
                  icon: Icon(
                    Icons.filter_list,
                    color: _filterLevel != null
                        ? _getLevelColor(_filterLevel!)
                        : Colors.white70,
                  ),
                  color: const Color(0xFF2D2D2D),
                  onSelected: (level) => setState(() => _filterLevel = level),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: null,
                      child: Text(
                        'All Levels',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    ...LogLevel.values.map(
                      (level) => PopupMenuItem(
                        value: level,
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: _getLevelColor(level),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              level.toString().split('.').last.toUpperCase(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Log List
          Expanded(
            child: filteredLogs.isEmpty
                ? Center(
                    child: Text(
                      'No logs found',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontFamily: 'monospace',
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(12),
                    itemCount: filteredLogs.length,
                    itemBuilder: (context, index) {
                      final log = filteredLogs[index];
                      return _buildLogEntry(log);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, int count, Color color) {
    return GestureDetector(
      onTap: () => setState(() {
        if (_filterLevel ==
            LogLevel.values.firstWhere(
              (l) => l.toString().split('.').last.toUpperCase() == label,
              orElse: () => LogLevel.debug,
            )) {
          _filterLevel = null;
        } else {
          _filterLevel = LogLevel.values.firstWhere(
            (l) => l.toString().split('.').last.toUpperCase() == label,
            orElse: () => LogLevel.debug,
          );
        }
      }),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withAlpha(30),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: color.withAlpha(100)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(
              '$label: $count',
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogEntry(LogEntry log) {
    final color = _getLevelColor(log.level);

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF252526),
        borderRadius: BorderRadius.circular(4),
        border: Border(left: BorderSide(color: color, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                log.formattedTime,
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 11,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withAlpha(40),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  log.levelString,
                  style: TextStyle(
                    color: color,
                    fontSize: 9,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withAlpha(30),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  log.tag,
                  style: const TextStyle(
                    color: Color(0xFF60A5FA),
                    fontSize: 9,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            log.message,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontFamily: 'monospace',
            ),
          ),
          if (log.data != null) ...[
            const SizedBox(height: 4),
            Text(
              log.data!,
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 11,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ],
      ),
    );
  }
}
