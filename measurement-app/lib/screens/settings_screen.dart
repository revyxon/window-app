import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import '../db/database_helper.dart';
import '../providers/settings_provider.dart';
import '../providers/app_provider.dart';
import '../services/device_id_service.dart';
import '../services/sync_service.dart';
import '../utils/app_colors.dart';
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
    if (mounted) {
      setState(() {
        _dbStats = stats;
        _deviceId = deviceId;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scaffoldColor = Theme.of(context).scaffoldBackgroundColor;
    final appBarColor =
        Theme.of(context).appBarTheme.backgroundColor ?? scaffoldColor;
    final titleColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;

    return Scaffold(
      backgroundColor: scaffoldColor,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 24,
            color: titleColor,
          ),
        ),
        centerTitle: false,
        backgroundColor: appBarColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              _buildSectionHeader('APPEARANCE'),
              _buildCard(
                children: [
                  _buildSettingItem(
                    icon: FluentIcons.dark_theme_24_regular,
                    iconColor: Colors.purple,
                    title: 'Theme',
                    subtitle: settings.isDarkMode ? 'Dark mode' : 'Light mode',
                    trailing: Switch.adaptive(
                      value: settings.isDarkMode,
                      activeTrackColor: AppColors.primary,
                      onChanged: (v) => settings.setThemeMode(
                        v ? ThemeMode.dark : ThemeMode.light,
                      ),
                    ),
                  ),
                  _buildDivider(),
                  _buildSettingItem(
                    icon: FluentIcons.text_font_size_24_regular,
                    iconColor: Colors.blue,
                    title: 'Text Size',
                    subtitle: _getTextSizeLabel(settings.textScale),
                    trailing: SizedBox(
                      width: 120,
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 4,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 6,
                          ),
                          overlayShape: SliderComponentShape.noOverlay,
                        ),
                        child: Slider(
                          value: settings.textScale,
                          min: 0.8,
                          max: 1.4,
                          divisions: 6,
                          activeColor: AppColors.primary,
                          onChanged: (v) => settings.setTextScale(v),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              _buildSectionHeader('CALCULATION'),
              _buildCard(
                children: [
                  _buildSettingItem(
                    icon: FluentIcons.calculator_24_regular,
                    iconColor: Colors.orange,
                    title: 'Displayed Formula',
                    subtitle:
                        'W × H ÷ ${settings.displayedFormula.toStringAsFixed(0)}',
                    onTap: () => _showFormulaDialog(context, settings, true),
                  ),
                  _buildDivider(),
                  _buildSettingItem(
                    icon: FluentIcons.math_formula_24_regular,
                    iconColor: Colors.orange,
                    title: 'Actual Formula',
                    subtitle:
                        'W × H ÷ ${settings.actualFormula.toStringAsFixed(2)}',
                    onTap: () => _showFormulaDialog(context, settings, false),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              _buildSectionHeader('DATA'),
              _buildCard(
                children: [
                  _buildSettingItem(
                    icon: FluentIcons.database_24_regular,
                    iconColor: Colors.teal,
                    title: 'Database Stats',
                    subtitle: _isLoading
                        ? 'Loading...'
                        : '${_dbStats['customerCount'] ?? 0} customers, ${_dbStats['windowCount'] ?? 0} windows',
                    onTap: () {}, // Just display
                  ),
                  _buildDivider(),
                  _buildSettingItem(
                    icon: FluentIcons.arrow_upload_24_regular,
                    iconColor: Colors.green,
                    title: 'Force Resync',
                    subtitle: 'Re-upload all data to cloud',
                    onTap: () => _handleForceResync(context),
                  ),
                  _buildDivider(),
                  _buildSettingItem(
                    icon: FluentIcons.delete_24_regular,
                    iconColor: Colors.red,
                    title: 'Clear All Data',
                    subtitle: 'Delete everything permanently',
                    onTap: () => _showClearDataDialog(context),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              _buildSectionHeader('ABOUT'),
              _buildCard(
                children: [
                  _buildSettingItem(
                    icon: FluentIcons.info_24_regular,
                    iconColor: Colors.grey,
                    title: 'About App',
                    subtitle: 'Version 2.0.0 • Tap to learn more',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AboutScreen()),
                    ),
                  ),
                  _buildDivider(),
                  _buildSettingItem(
                    icon: FluentIcons.code_24_regular,
                    iconColor: Colors.grey,
                    title: 'Logs',
                    subtitle: 'View application logs',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LogViewerScreen(),
                      ),
                    ),
                  ),
                  _buildDivider(),
                  _buildSettingItem(
                    icon: FluentIcons.phone_24_regular,
                    iconColor: Colors.blueGrey,
                    title: 'Device ID',
                    subtitle: _deviceId,
                    onTap: () {}, // Just display
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark
        ? const Color(0xFF1C1C1E)
        : Colors.white; // iOS Dark surface or White

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(
              isDark ? 77 : 13,
            ), // 0.3 = 77, 0.05 = 13
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : const Color(0xFF1F2937);
    final subtitleColor = isDark ? Colors.grey.shade400 : Colors.grey.shade500;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withAlpha(26), // 0.1 opacity = 26 alpha
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: subtitleColor,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null)
                trailing
              else if (onTap != null)
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: Colors.grey.shade400,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Divider(
      height: 1,
      thickness: 1,
      indent: 68,
      endIndent: 0,
      color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF3F4F6),
    );
  }

  String _getTextSizeLabel(double scale) {
    if (scale <= 0.85) return 'Small';
    if (scale <= 0.95) return 'Medium';
    if (scale <= 1.05) return 'Default';
    if (scale <= 1.2) return 'Large';
    return 'Extra Large';
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
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(isDisplayed ? 'Displayed Formula' : 'Actual Formula'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Divisor (W × H ÷ ?)',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
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
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(FluentIcons.warning_24_filled, color: Colors.red),
            SizedBox(width: 8),
            Text('Clear All Data?'),
          ],
        ),
        content: const Text(
          'This action cannot be undone. All customers, measurements, and logs will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await SyncService().clearCloudData();
                await DatabaseHelper.instance.clearAllData();
                await Provider.of<AppProvider>(
                  context,
                  listen: false,
                ).loadCustomers();
                _loadData(); // refresh local stats
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('All data cleared'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _handleForceResync(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Force Resync?'),
        content: const Text('This will re-upload all local data to the cloud.'),
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
    );

    if (confirmed == true && mounted) {
      await DatabaseHelper.instance.markAllAsUnsynced();
      SyncService().syncData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Resync started'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
}
