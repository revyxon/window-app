import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:intl/intl.dart';
import '../utils/app_colors.dart';
import '../services/api_service.dart';
import '../models/models.dart';
import 'user_info_screen.dart';
import '../utils/fast_page_route.dart';

class UserDetailScreen extends StatefulWidget {
  final String deviceId;

  const UserDetailScreen({super.key, required this.deviceId});

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  bool _isUpdating = false;
  String? _error;

  Map<String, dynamic>? _deviceData;
  List<dynamic> _customers = [];
  List<dynamic> _windows = [];
  List<ActivityLog> _activityLogs = [];
  Map<String, int> _stats = {};

  // Controls state
  Map<String, bool> _controls = {
    'canCreateCustomer': true,
    'canEditCustomer': true,
    'canDeleteCustomer': true,
    'canCreateWindow': true,
    'canEditWindow': true,
    'canDeleteWindow': true,
    'canExportData': true,
    'canPrint': true,
    'canShare': true,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadUserDetails();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await ApiService().getUserDetails(widget.deviceId);
      setState(() {
        _deviceData = response['device'];
        _customers = response['customers'] ?? [];
        _windows = response['windows'] ?? [];
        _activityLogs =
            (response['activityLogs'] as List?)
                ?.map((e) => ActivityLog.fromJson(e))
                .toList() ??
            [];
        _stats = Map<String, int>.from(response['stats'] ?? {});

        // Load controls from device data
        final deviceControls =
            _deviceData?['controls'] as Map<String, dynamic>?;
        if (deviceControls != null) {
          _controls = {
            'canCreateCustomer': deviceControls['canCreateCustomer'] ?? true,
            'canEditCustomer': deviceControls['canEditCustomer'] ?? true,
            'canDeleteCustomer': deviceControls['canDeleteCustomer'] ?? true,
            'canCreateWindow': deviceControls['canCreateWindow'] ?? true,
            'canEditWindow': deviceControls['canEditWindow'] ?? true,
            'canDeleteWindow': deviceControls['canDeleteWindow'] ?? true,
            'canExportData': deviceControls['canExportData'] ?? true,
            'canPrint': deviceControls['canPrint'] ?? true,
            'canShare': deviceControls['canShare'] ?? true,
          };
        }
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateStatus(String newStatus) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${newStatus == 'locked' ? 'Lock' : 'Unlock'} Device?'),
        content: Text(
          newStatus == 'locked'
              ? 'This will prevent the user from accessing the app.'
              : 'This will restore the user\'s access to the app.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: newStatus == 'locked'
                  ? AppColors.error
                  : AppColors.success,
            ),
            child: Text(newStatus == 'locked' ? 'Lock' : 'Unlock'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isUpdating = true);

    try {
      await ApiService().updateUserStatus(widget.deviceId, newStatus);
      await _loadUserDetails();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Device ${newStatus == 'locked' ? 'locked' : 'unlocked'} successfully',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() => _isUpdating = false);
    }
  }

  void _showDeviceInfoDialog() {
    Navigator.push(
      context,
      FastPageRoute(
        page: UserInfoScreen(
          deviceData: _deviceData ?? {},
          deviceId: widget.deviceId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = _deviceData?['status'] ?? 'active';

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Details'),
        bottom: _isLoading
            ? null
            : TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Overview'),
                  Tab(text: 'Data'),
                  Tab(text: 'Activity'),
                  Tab(text: 'Controls'),
                ],
              ),
        actions: [
          if (!_isLoading && _deviceData != null)
            IconButton(
              icon: const Icon(FluentIcons.info_24_regular),
              tooltip: 'Device Info',
              onPressed: _showDeviceInfoDialog,
            ),
          if (!_isLoading && _deviceData != null)
            _isUpdating
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : PopupMenuButton<String>(
                    icon: const Icon(FluentIcons.more_vertical_24_regular),
                    onSelected: (value) {
                      if (value == 'lock') {
                        _updateStatus('locked');
                      } else if (value == 'unlock') {
                        _updateStatus('active');
                      }
                    },
                    itemBuilder: (context) => [
                      if (status != 'locked')
                        const PopupMenuItem(
                          value: 'lock',
                          child: Row(
                            children: [
                              Icon(
                                FluentIcons.lock_closed_24_regular,
                                size: 20,
                                color: Colors.red,
                              ),
                              SizedBox(width: 8),
                              Text('Lock Device'),
                            ],
                          ),
                        ),
                      if (status == 'locked')
                        const PopupMenuItem(
                          value: 'unlock',
                          child: Row(
                            children: [
                              Icon(
                                FluentIcons.lock_open_24_regular,
                                size: 20,
                                color: Colors.green,
                              ),
                              SizedBox(width: 8),
                              Text('Unlock Device'),
                            ],
                          ),
                        ),
                    ],
                  ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _buildError()
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildDataTab(),
                _buildActivityTab(),
                _buildControlsTab(),
              ],
            ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              FluentIcons.error_circle_24_regular,
              size: 48,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadUserDetails,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    final status = _deviceData?['status'] ?? 'active';
    final registeredAt = _deviceData?['registeredAt'] != null
        ? DateTime.tryParse(_deviceData!['registeredAt'])
        : null;
    final lastActiveAt = _deviceData?['lastActiveAt'] != null
        ? DateTime.tryParse(_deviceData!['lastActiveAt'])
        : null;
    final appVersion = _deviceData?['appVersion'];
    final deviceInfo = _deviceData?['deviceInfo'] as Map<String, dynamic>?;

    // Calculate activity breakdown
    final loginCount = _activityLogs
        .where((l) => l.actionName == 'APP_OPENED')
        .length;
    final viewCount = _activityLogs
        .where((l) => l.actionName == 'VIEW_SCREEN')
        .length;
    final syncCount = _activityLogs
        .where((l) => l.actionName == 'MANUAL_SYNC')
        .length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Device Summary Card (Quick View)
          if (deviceInfo != null) ...[
            _buildInfoCard(
              title: 'Device Summary',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          FluentIcons.phone_24_regular,
                          color: AppColors.primary,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${deviceInfo['brand'] ?? ''} ${deviceInfo['model'] ?? ''}'
                                  .trim(),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Android ${deviceInfo['androidVersion'] ?? '?'} (API ${deviceInfo['sdkInt'] ?? '?'})',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(FluentIcons.chevron_right_24_regular),
                        onPressed: _showDeviceInfoDialog,
                        tooltip: 'View Full Details',
                      ),
                    ],
                  ),
                  if (deviceInfo['hardware'] != null ||
                      deviceInfo['buildFingerprint'] != null) ...[
                    const Divider(height: 24),
                    _buildDetailRow(
                      'Hardware',
                      deviceInfo['hardware'] ?? 'N/A',
                    ),
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      'Security Patch',
                      deviceInfo['securityPatch'] ?? 'N/A',
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Status Card
          _buildInfoCard(
            title: 'License Status',
            child: Row(
              children: [
                _buildStatusBadge(status),
                const Spacer(),
                if (status == 'locked')
                  TextButton.icon(
                    onPressed: () => _updateStatus('active'),
                    icon: const Icon(
                      FluentIcons.lock_open_24_regular,
                      size: 18,
                    ),
                    label: const Text('Unlock'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.success,
                    ),
                  )
                else
                  TextButton.icon(
                    onPressed: () => _updateStatus('locked'),
                    icon: const Icon(
                      FluentIcons.lock_closed_24_regular,
                      size: 18,
                    ),
                    label: const Text('Lock'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.error,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Stats Grid
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Customers',
                  _stats['customerCount']?.toString() ?? '0',
                  FluentIcons.person_24_regular,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Windows',
                  _stats['windowCount']?.toString() ?? '0',
                  FluentIcons.window_24_regular,
                  Colors.purple,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Activities',
                  _stats['activityCount']?.toString() ?? '0',
                  FluentIcons.history_24_regular,
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Activity Breakdown
          _buildInfoCard(
            title: 'Activity Breakdown',
            child: Column(
              children: [
                _buildDetailRow('App Opens', '$loginCount times'),
                const Divider(height: 16),
                _buildDetailRow('Screens Viewed', '$viewCount screens'),
                const Divider(height: 16),
                _buildDetailRow('Manual Syncs', '$syncCount syncs'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Timeline Details Card
          _buildInfoCard(
            title: 'Timeline',
            child: Column(
              children: [
                _buildDetailRow('App Version', appVersion ?? 'Unknown'),
                const Divider(height: 24),
                _buildDetailRow(
                  'Registered',
                  registeredAt != null
                      ? DateFormat.yMMMMd().add_jm().format(registeredAt)
                      : 'Unknown',
                ),
                const Divider(height: 24),
                _buildDetailRow(
                  'Last Active',
                  lastActiveAt != null
                      ? DateFormat.yMMMMd().add_jm().format(lastActiveAt)
                      : 'Unknown',
                ),
                if (registeredAt != null) ...[
                  const Divider(height: 24),
                  _buildDetailRow(
                    'Days Active',
                    '${DateTime.now().difference(registeredAt).inDays} days',
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Customers Section
        Text(
          'Customers (${_customers.length})',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        if (_customers.isEmpty)
          _buildEmptyCard('No customers')
        else
          ...List.generate(_customers.take(10).length, (index) {
            final customer = _customers[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: const Icon(
                    FluentIcons.person_24_regular,
                    color: AppColors.primary,
                  ),
                ),
                title: Text(customer['name'] ?? 'Unknown'),
                subtitle: Text(customer['location'] ?? ''),
                trailing: customer['is_deleted'] == true
                    ? const Icon(
                        FluentIcons.delete_24_regular,
                        color: Colors.red,
                        size: 18,
                      )
                    : null,
              ),
            );
          }),
        if (_customers.length > 10)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              '+ ${_customers.length - 10} more customers',
              style: TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ),

        const SizedBox(height: 24),

        // Windows Section
        Text(
          'Windows (${_windows.length})',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        if (_windows.isEmpty)
          _buildEmptyCard('No windows')
        else
          ...List.generate(_windows.take(10).length, (index) {
            final window = _windows[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.purple.withValues(alpha: 0.1),
                  child: const Icon(
                    FluentIcons.window_24_regular,
                    color: Colors.purple,
                  ),
                ),
                title: Text(window['name'] ?? 'Window'),
                subtitle: Text('${window['width']} x ${window['height']}'),
                trailing: Text(
                  window['type'] ?? '',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
            );
          }),
        if (_windows.length > 10)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              '+ ${_windows.length - 10} more windows',
              style: TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }

  Widget _buildActivityTab() {
    if (_activityLogs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FluentIcons.history_24_regular,
              size: 48,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            const Text(
              'No activity logs',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _activityLogs.length,
      itemBuilder: (context, index) {
        final log = _activityLogs[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                FluentIcons.play_24_regular,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            title: Text(log.actionName),
            subtitle: Text(log.page),
            trailing: log.timestamp != null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        DateFormat.Hm().format(log.timestamp!),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        DateFormat.MMMd().format(log.timestamp!),
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  )
                : null,
          ),
        );
      },
    );
  }

  Widget _buildInfoCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: AppColors.textSecondary)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    final color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  FluentIcons.shield_24_regular,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Permission Controls',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Manage what this user can do in the app',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Customer Controls
          _buildControlSection('Customer Management', [
            _buildControlToggle(
              'canCreateCustomer',
              'Create Customers',
              'Allow creating new customers',
            ),
            _buildControlToggle(
              'canEditCustomer',
              'Edit Customers',
              'Allow editing customer details',
            ),
            _buildControlToggle(
              'canDeleteCustomer',
              'Delete Customers',
              'Allow deleting customers',
            ),
          ]),
          const SizedBox(height: 16),

          // Window Controls
          _buildControlSection('Window Management', [
            _buildControlToggle(
              'canCreateWindow',
              'Create Windows',
              'Allow creating new windows',
            ),
            _buildControlToggle(
              'canEditWindow',
              'Edit Windows',
              'Allow editing window details',
            ),
            _buildControlToggle(
              'canDeleteWindow',
              'Delete Windows',
              'Allow deleting windows',
            ),
          ]),
          const SizedBox(height: 16),

          // Feature Controls
          _buildControlSection('Features', [
            _buildControlToggle(
              'canExportData',
              'Export Data',
              'Allow exporting data to files',
            ),
            _buildControlToggle(
              'canPrint',
              'Print',
              'Allow printing documents',
            ),
            _buildControlToggle('canShare', 'Share', 'Allow sharing content'),
          ]),
          const SizedBox(height: 24),

          // Save Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isUpdating ? null : _saveControls,
              icon: _isUpdating
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(FluentIcons.save_24_regular),
              label: Text(_isUpdating ? 'Saving...' : 'Save Controls'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlSection(String title, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
          ),
          Container(height: 1, color: AppColors.border),
          ...children,
        ],
      ),
    );
  }

  Widget _buildControlToggle(String key, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _controls[key] ?? true,
            activeColor: AppColors.primary,
            onChanged: (value) {
              setState(() {
                _controls[key] = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Future<void> _saveControls() async {
    setState(() => _isUpdating = true);
    try {
      await ApiService().updateUser(widget.deviceId, controls: _controls);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Controls saved successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() => _isUpdating = false);
    }
  }

  Widget _buildEmptyCard(String message) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Center(
        child: Text(message, style: TextStyle(color: AppColors.textSecondary)),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return AppColors.success;
      case 'locked':
        return AppColors.error;
      case 'expired':
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }
}
