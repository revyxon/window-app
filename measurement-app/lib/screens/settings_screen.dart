import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import '../db/database_helper.dart';
import '../providers/settings_provider.dart';
import '../providers/app_provider.dart';
import '../services/device_id_service.dart';
import '../services/sync_service.dart';
import '../utils/app_colors.dart';
import '../widgets/glass_container.dart';
import 'about_screen.dart';
import 'log_viewer_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Map<String, dynamic> _dbStats = {};
  bool _isLoading = true;
  String _deviceId = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final stats = await DatabaseHelper.instance.getDatabaseStats();
    final deviceId = await DeviceIdService.instance.getDeviceId();
    setState(() {
      _dbStats = stats;
      _deviceId = deviceId;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Device Card
              _buildDeviceCard(),
              const SizedBox(height: 20),

              // Appearance
              _buildSectionTitle('Appearance'),
              const SizedBox(height: 10),
              GlassContainer(
                padding: const EdgeInsets.all(4),
                child: Column(
                  children: [
                    _buildSwitchTile(
                      icon: FluentIcons.dark_theme_24_regular,
                      title: 'Dark Mode',
                      subtitle: settings.isDarkMode ? 'On' : 'Off',
                      value: settings.isDarkMode,
                      onChanged: (v) => settings.setThemeMode(
                        v ? ThemeMode.dark : ThemeMode.light,
                      ),
                    ),
                    _buildDivider(),
                    _buildSliderTile(
                      icon: FluentIcons.text_font_size_24_regular,
                      title: 'Text Size',
                      value: settings.textScale,
                      label: _getTextSizeLabel(settings.textScale),
                      onChanged: (v) => settings.setTextScale(v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Calculation
              _buildSectionTitle('Calculation'),
              const SizedBox(height: 10),
              GlassContainer(
                padding: const EdgeInsets.all(4),
                child: Column(
                  children: [
                    _buildTile(
                      icon: FluentIcons.calculator_24_regular,
                      title: 'Displayed Formula',
                      subtitle:
                          'W × H ÷ ${settings.displayedFormula.toStringAsFixed(0)}',
                      onTap: () => _showFormulaDialog(context, settings, true),
                    ),
                    _buildDivider(),
                    _buildTile(
                      icon: FluentIcons.calculator_24_regular,
                      title: 'Actual Formula',
                      subtitle:
                          'W × H ÷ ${settings.actualFormula.toStringAsFixed(2)}',
                      onTap: () => _showFormulaDialog(context, settings, false),
                    ),
                    _buildDivider(),
                    _buildInfoRow(
                      icon: FluentIcons.arrow_trending_24_regular,
                      title: 'Customer Bonus',
                      value:
                          '${((settings.displayedFormula / settings.actualFormula - 1) * -100).toStringAsFixed(1)}%',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Data
              _buildSectionTitle('Data'),
              const SizedBox(height: 10),
              GlassContainer(
                padding: const EdgeInsets.all(4),
                child: Column(
                  children: [
                    _buildInfoRow(
                      icon: FluentIcons.database_24_regular,
                      title: 'Database',
                      value: _isLoading
                          ? '...'
                          : '${_dbStats['customerCount'] ?? 0} customers, ${_dbStats['windowCount'] ?? 0} windows',
                    ),
                    _buildDivider(),
                    _buildTile(
                      icon: FluentIcons.arrow_sync_24_regular,
                      title: 'Force Full Resync',
                      subtitle: 'Re-upload all data',
                      onTap: () => _handleForceResync(context),
                    ),
                    _buildDivider(),
                    _buildTile(
                      icon: FluentIcons.delete_24_regular,
                      title: 'Clear All Data',
                      subtitle: 'Delete everything',
                      iconColor: Colors.red,
                      onTap: () => _showClearDataDialog(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // About
              _buildSectionTitle('About'),
              const SizedBox(height: 10),
              GlassContainer(
                padding: const EdgeInsets.all(4),
                child: Column(
                  children: [
                    _buildTile(
                      icon: FluentIcons.info_24_regular,
                      title: 'About Window Manager',
                      subtitle: 'Version 2.0.0',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AboutScreen()),
                      ),
                    ),
                    _buildDivider(),
                    _buildTile(
                      icon: FluentIcons.arrow_reset_24_regular,
                      title: 'Reset Settings',
                      subtitle: 'Restore defaults',
                      onTap: () => _showResetDialog(context, settings),
                    ),
                    _buildDivider(),
                    _buildTile(
                      icon: FluentIcons.code_24_regular,
                      title: 'View Logs',
                      subtitle: 'Debug & diagnostics',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LogViewerScreen(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDeviceCard() {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              FluentIcons.phone_24_filled,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'This Device',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  _isLoading
                      ? 'Loading...'
                      : 'ID: ${_deviceId.length > 12 ? '${_deviceId.substring(0, 12)}...' : _deviceId}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.success.withAlpha(25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  FluentIcons.cloud_checkmark_24_filled,
                  color: AppColors.success,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  'Synced',
                  style: TextStyle(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, color: AppColors.border, indent: 56);
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    Color? iconColor,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (iconColor ?? AppColors.primary).withAlpha(25),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor ?? AppColors.primary, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
      ),
      trailing: onTap != null
          ? Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20)
          : null,
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withAlpha(25),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppColors.primary,
      ),
    );
  }

  Widget _buildSliderTile({
    required IconData icon,
    required String title,
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(25),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 4,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 7,
                    ),
                  ),
                  child: Slider(
                    value: value,
                    min: 0.8,
                    max: 1.4,
                    divisions: 6,
                    activeColor: AppColors.primary,
                    inactiveColor: AppColors.border,
                    onChanged: onChanged,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withAlpha(25),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
      trailing: Text(
        value,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }

  String _getTextSizeLabel(double scale) {
    if (scale <= 0.85) return 'Small';
    if (scale <= 0.95) return 'Medium';
    if (scale <= 1.05) return 'Default';
    if (scale <= 1.2) return 'Large';
    return 'XL';
  }

  void _showFormulaDialog(
    BuildContext context,
    SettingsProvider settings,
    bool isDisplayed,
  ) {
    final controller = TextEditingController(
      text: isDisplayed
          ? settings.displayedFormula.toStringAsFixed(0)
          : settings.actualFormula.toStringAsFixed(2),
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(isDisplayed ? 'Displayed Formula' : 'Actual Formula'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Divisor (W × H ÷ ?)',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final v = double.tryParse(controller.text);
              if (v != null && v > 0) {
                isDisplayed
                    ? settings.setDisplayedFormula(v)
                    : settings.setActualFormula(v);
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(FluentIcons.warning_24_filled, color: Colors.red),
            SizedBox(width: 8),
            Text('Clear All?'),
          ],
        ),
        content: const Text(
          'This will delete ALL customers and windows permanently!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Clearing cloud and local data...'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }

              try {
                // 1. Clear Cloud
                await SyncService().clearCloudData();

                // 2. Clear Local
                await DatabaseHelper.instance.clearAllData();
                await Provider.of<AppProvider>(
                  context,
                  listen: false,
                ).loadCustomers();
                await _loadData();

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('All data cleared permanently'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to clear data: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context, SettingsProvider settings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Reset Settings?'),
        content: const Text('Restore all settings to defaults.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await settings.resetToDefaults();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Settings reset'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _handleForceResync(BuildContext context) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Force Full Resync?'),
            content: const Text(
              'This will mark all local data as "unsynced" and attempt to re-upload everything to Firebase. Use this if data is missing from the cloud.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Resync'),
              ),
            ],
          ),
        ) ??
        false;

    if (confirmed && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Starting full resync...'),
          duration: Duration(seconds: 1),
        ),
      );

      try {
        await DatabaseHelper.instance.markAllAsUnsynced();
        await SyncService().syncData();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Resync initiated successfully'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Resync error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
