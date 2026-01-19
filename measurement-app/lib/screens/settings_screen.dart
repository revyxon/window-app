import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import '../db/database_helper.dart';
import '../providers/settings_provider.dart';
import '../providers/app_provider.dart';
import '../services/device_id_service.dart';
import '../services/sync_service.dart';
import '../ui/design_system.dart';
// Added import for AppCardStyle
import '../ui/components/app_icon.dart';
import '../ui/components/app_header.dart';
import '../ui/components/settings_section.dart';
import '../utils/haptics.dart';
import 'about_screen.dart';
import 'log_viewer_screen.dart';
import '../ui/dialogs/restore_dialog.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Map<String, dynamic> _dbStats = {};
  bool _isLoading = true;
  String _deviceId = '';
  String _versionString = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final stats = await DatabaseHelper.instance.getDatabaseStats();
    final deviceId = await DeviceIdService.instance.getDeviceId();
    final packageInfo = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _dbStats = stats;
        _deviceId = deviceId;
        _versionString = 'v${packageInfo.version}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              AppHeader(
                title: 'Settings',
                actions: [
                  IconButton(
                    icon: Icon(
                      Icons.info_outline_rounded,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AboutScreen()),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                ],
              ),
            ],
            body: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.xl,
              ),
              child: Column(
                children: [
                  // APPEARANCE
                  SettingsSection(
                    title: 'Appearance',
                    icon: AppIconType.sparkle, // Added icon
                    children: [
                      // Theme Mode
                      _SettingsTile(
                        icon: AppIconType.theme,
                        iconColor: theme.colorScheme.primary,
                        title: 'Theme Mode',
                        subtitle: _getThemeModeLabel(settings.themeMode),
                        onTap: () => _showThemeModeSheet(context, settings),
                      ),

                      // Accent Color
                      _SettingsTile(
                        icon: AppIconType.palette,
                        iconColor: settings.accentColor,
                        title: 'Accent Color',
                        subtitle: settings.accentColorName,
                        trailing: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: settings.accentColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: theme.colorScheme.outline.withValues(
                                alpha: 0.2,
                              ),
                            ),
                          ),
                        ),
                        onTap: () => _showAccentColorSheet(context, settings),
                      ),

                      // Surface Color
                      _SettingsTile(
                        icon: AppIconType.file,
                        iconColor: theme.colorScheme.onSurface,
                        title: 'Surface Color',
                        subtitle: _getSurfaceName(settings.surfaceVariant),
                        onTap: () => _showSurfaceColorSheet(context, settings),
                        trailing: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: AppSurfaces.getSurface(
                              settings.surfaceVariant,
                            ).background,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: theme.colorScheme.outline.withValues(
                                alpha: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Icon Pack
                      _SettingsTile(
                        icon: AppIconType.icons,
                        iconColor: Colors.purple,
                        title: 'Icon Pack',
                        subtitle: _getIconPackLabel(settings.iconPack),
                        onTap: () => _showIconPackSheet(context, settings),
                      ),
                    ],
                  ),

                  // TYPOGRAPHY
                  SettingsSection(
                    title: 'Typography',
                    icon: AppIconType.font,
                    children: [
                      _SettingsTile(
                        icon: AppIconType.font,
                        iconColor: Colors.teal,
                        title: 'Font Family',
                        subtitle: settings.fontFamilyDisplayName,
                        onTap: () => _showFontFamilySheet(context, settings),
                      ),
                      // Font Size Slider (Custom Tile)
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.md,
                                    ),
                                  ),
                                  child: const AppIcon(
                                    AppIconType.textSize,
                                    color: Colors.blue,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.lg),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Font Size',
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                      Text(
                                        '${(settings.fontSize * 100).toInt()}%',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: theme.colorScheme.primary,
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                trackHeight: 4,
                                thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 8,
                                ),
                                overlayShape: const RoundSliderOverlayShape(
                                  overlayRadius: 16,
                                ),
                              ),
                              child: Slider(
                                value: settings.fontSize,
                                min: 0.8,
                                max: 1.3,
                                divisions: 10,
                                onChanged: (v) {
                                  if (settings.hapticFeedback)
                                    Haptics.selection();
                                  settings.setFontSize(v);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // FEEDBACK
                  SettingsSection(
                    title: 'Behavior',
                    icon: AppIconType.settings,
                    children: [
                      // Haptic Feedback Switch (Custom Tile)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.md,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(
                                  AppRadius.md,
                                ),
                              ),
                              child: const Icon(
                                Icons.vibration_rounded,
                                color: Colors.orange,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.lg),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Haptic Feedback',
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    settings.hapticFeedback
                                        ? 'Enabled'
                                        : 'Disabled',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: settings.hapticFeedback,
                              onChanged: (v) {
                                if (v) Haptics.medium();
                                settings.setHapticFeedback(v);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // DATA
                  SettingsSection(
                    title: 'Data',
                    icon: AppIconType.database,
                    children: [
                      _SettingsTile(
                        icon: AppIconType.database,
                        iconColor: Colors.teal,
                        title: 'Database Stats',
                        subtitle: _isLoading
                            ? 'Loading...'
                            : '${_dbStats['customerCount'] ?? 0} customers • ${_dbStats['windowCount'] ?? 0} windows',
                      ),
                      _SettingsTile(
                        icon: AppIconType.download, // Restore Icon
                        iconColor: Colors.purple,
                        title: 'Restore Data',
                        subtitle: 'Download backup from cloud',
                        onTap: () => _showRestoreDialog(context),
                      ),
                      _SettingsTile(
                        icon: AppIconType.upload,
                        iconColor: Colors.green,
                        title: 'Force Resync',
                        subtitle: 'Re-upload all data to cloud',
                        onTap: () => _handleForceResync(context),
                      ),
                      _SettingsTile(
                        icon: AppIconType.delete,
                        iconColor: Colors.red,
                        title: 'Clear All Data',
                        subtitle: 'Delete everything permanently',
                        onTap: () => _showClearDataDialog(context),
                      ),
                    ],
                  ),

                  // ABOUT
                  SettingsSection(
                    title: 'About',
                    icon: AppIconType.info,
                    children: [
                      _SettingsTile(
                        icon: AppIconType.info,
                        iconColor: theme.colorScheme.onSurface.withValues(
                          alpha: 0.5,
                        ),
                        title: 'About App',
                        subtitle: _versionString.isNotEmpty
                            ? '$_versionString • Licenses & more'
                            : 'Version, licenses & more',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AboutScreen(),
                          ),
                        ),
                      ),
                      _SettingsTile(
                        icon: AppIconType.file,
                        iconColor: theme.colorScheme.onSurface.withValues(
                          alpha: 0.5,
                        ),
                        title: 'Logs',
                        subtitle: 'View application logs',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LogViewerScreen(),
                          ),
                        ),
                      ),
                      _SettingsTile(
                        icon: AppIconType.device,
                        iconColor: theme.colorScheme.onSurface.withValues(
                          alpha: 0.5,
                        ),
                        title: 'Device ID',
                        subtitle: _deviceId,
                      ),
                    ],
                  ),

                  const SizedBox(height: 80), // Bottom padding
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ========== HELPER METHODS ==========

  String _getThemeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  String _getIconPackLabel(IconPack pack) {
    switch (pack) {
      case IconPack.material:
        return 'Material Icons';
      case IconPack.fluent:
        return 'Fluent Icons';
      case IconPack.cupertino:
        return 'Cupertino Icons';
    }
  }

  // ========== BOTTOM SHEETS ==========

  void _showThemeModeSheet(BuildContext context, SettingsProvider settings) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Text(
                  'Theme Mode',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _SheetOption(
                icon: Icons.light_mode_rounded,
                title: 'Light',
                subtitle: 'Always use light theme',
                isSelected: settings.themeMode == ThemeMode.light,
                onTap: () {
                  settings.setThemeMode(ThemeMode.light);
                  Navigator.pop(context);
                },
              ),
              _SheetOption(
                icon: Icons.dark_mode_rounded,
                title: 'Dark',
                subtitle: 'Always use dark theme',
                isSelected: settings.themeMode == ThemeMode.dark,
                onTap: () {
                  settings.setThemeMode(ThemeMode.dark);
                  Navigator.pop(context);
                },
              ),
              _SheetOption(
                icon: Icons.settings_suggest_rounded,
                title: 'System',
                subtitle: 'Follow system settings',
                isSelected: settings.themeMode == ThemeMode.system,
                onTap: () {
                  settings.setThemeMode(ThemeMode.system);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAccentColorSheet(BuildContext context, SettingsProvider settings) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Accent Color',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Choose your preferred accent color',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: AppSpacing.lg,
                  crossAxisSpacing: AppSpacing.lg,
                  childAspectRatio: 1,
                ),
                itemCount: SettingsProvider.accentColors.length,
                itemBuilder: (context, i) {
                  final color = SettingsProvider.accentColors[i];
                  final name = SettingsProvider.accentColorNames[i];
                  final isSelected = i == settings.accentColorIndex;

                  return GestureDetector(
                    onTap: () {
                      if (settings.hapticFeedback) Haptics.selection();
                      settings.setAccentColor(i);
                      Navigator.pop(context);
                    },
                    child: Column(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.transparent,
                              width: 3,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: color.withValues(alpha: 0.5),
                                      blurRadius: 12,
                                      spreadRadius: 2,
                                    ),
                                  ]
                                : [
                                    BoxShadow(
                                      color: color.withValues(alpha: 0.3),
                                      blurRadius: 8,
                                    ),
                                  ],
                          ),
                          child: isSelected
                              ? const Icon(
                                  Icons.check_rounded,
                                  color: Colors.white,
                                  size: 28,
                                )
                              : null,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          name.split(' ').first,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: isSelected
                                ? color
                                : theme.colorScheme.onSurface.withValues(
                                    alpha: 0.6,
                                  ),
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  void _showIconPackSheet(BuildContext context, SettingsProvider settings) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Text(
                  'Icon Pack',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _SheetOption(
                icon: Icons.android_rounded,
                title: 'Material',
                subtitle: 'Google Material Design icons',
                isSelected: settings.iconPack == IconPack.material,
                onTap: () {
                  settings.setIconPack(IconPack.material);
                  Navigator.pop(context);
                },
              ),
              _SheetOption(
                icon: Icons.window_rounded,
                title: 'Fluent',
                subtitle: 'Microsoft Fluent UI icons',
                isSelected: settings.iconPack == IconPack.fluent,
                onTap: () {
                  settings.setIconPack(IconPack.fluent);
                  Navigator.pop(context);
                },
              ),
              _SheetOption(
                icon: Icons.apple_rounded,
                title: 'Cupertino',
                subtitle: 'Apple San Francisco icons',
                isSelected: settings.iconPack == IconPack.cupertino,
                onTap: () {
                  settings.setIconPack(IconPack.cupertino);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSurfaceColorSheet(BuildContext context, SettingsProvider settings) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Surface Color',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Choose your preferred background style',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: AppSpacing.lg,
                  crossAxisSpacing: AppSpacing.lg,
                  childAspectRatio: 1.2,
                ),
                itemCount: AppSurfaceVariant.values.length,
                itemBuilder: (context, i) {
                  final variant = AppSurfaceVariant.values[i];
                  final surfaceData = AppSurfaces.getSurface(variant);
                  final isSelected = settings.surfaceVariant == variant;

                  return GestureDetector(
                    onTap: () {
                      if (settings.hapticFeedback) Haptics.selection();
                      settings.setSurfaceVariant(variant);
                      Navigator.pop(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: surfaceData.background,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outline.withValues(
                                  alpha: 0.2,
                                ),
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          if (isSelected)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Icon(
                                Icons.check_circle_rounded,
                                color: theme.colorScheme.primary,
                                size: 20,
                              ),
                            ),
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  surfaceData.name,
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRestoreDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const RestoreDialog(),
    );
  }

  String _getSurfaceName(AppSurfaceVariant variant) {
    return AppSurfaces.getSurface(variant).name;
  }

  void _showFontFamilySheet(BuildContext context, SettingsProvider settings) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Text(
                  'Font Family',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: FontFamily.values.length,
                  itemBuilder: (context, i) {
                    final family = FontFamily.values[i];
                    final isSelected = settings.fontFamily == family;
                    String name;
                    switch (family) {
                      case FontFamily.inter:
                        name = 'Inter';
                      case FontFamily.roboto:
                        name = 'Roboto';
                      case FontFamily.poppins:
                        name = 'Poppins';
                      case FontFamily.nunito:
                        name = 'Nunito';
                      case FontFamily.lato:
                        name = 'Lato';
                      case FontFamily.openSans:
                        name = 'Open Sans';
                      case FontFamily.montserrat:
                        name = 'Montserrat';
                      case FontFamily.raleway:
                        name = 'Raleway';
                      case FontFamily.sourceSans:
                        name = 'Source Sans';
                      case FontFamily.ubuntu:
                        name = 'Ubuntu';
                    }
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl,
                        vertical: AppSpacing.xs,
                      ),
                      title: Text(
                        name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: isSelected ? theme.colorScheme.primary : null,
                        ),
                      ),
                      subtitle: Text(
                        'The quick brown fox jumps over the lazy dog',
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.5,
                          ),
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(
                              Icons.check_circle_rounded,
                              color: theme.colorScheme.primary,
                            )
                          : null,
                      onTap: () {
                        if (settings.hapticFeedback) Haptics.selection();
                        settings.setFontFamily(family);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_rounded, color: Colors.red),
            SizedBox(width: 12),
            Text('Clear All Data?'),
          ],
        ),
        content: const Text(
          'This action cannot be undone. All data will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await SyncService().clearCloudData();
              await DatabaseHelper.instance.clearAllData();
              if (mounted) {
                await Provider.of<AppProvider>(
                  context,
                  listen: false,
                ).loadCustomers();
                _loadData();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All data cleared'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _handleForceResync(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Force Resync?'),
        content: const Text('This will re-upload all local data to the cloud.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Resync'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await DatabaseHelper.instance.markAllAsUnsynced();
      SyncService().syncData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Resync started'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}

// ============================================================================
// WIDGETS
// ============================================================================

class _SettingsTile extends StatelessWidget {
  final AppIconType icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Using InkWell directly since SettingsSection provides the Card container
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: AppIcon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: AppSpacing.md),
              trailing!,
            ] else if (onTap != null) ...[
              const SizedBox(width: AppSpacing.md),
              Icon(
                Icons.chevron_right_rounded,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                size: 20,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SheetOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _SheetOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xs,
      ),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color:
              (isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface)
                  .withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Icon(
          icon,
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ),
      title: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          color: isSelected ? theme.colorScheme.primary : null,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle_rounded, color: theme.colorScheme.primary)
          : null,
      onTap: onTap,
    );
  }
}
