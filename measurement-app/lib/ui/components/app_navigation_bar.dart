import 'package:flutter/material.dart';
import 'app_icon.dart';

/// Premium Material 3 Navigation Bar
///
/// Uses filled Material 3 NavigationBar style with AppIcon support.
/// Automatically adapts to selected icon pack.
class AppNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      backgroundColor: theme.colorScheme.surface,
      elevation: 0,
      height: 72,
      indicatorColor: theme.colorScheme.primary.withValues(alpha: 0.12),
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      destinations: [
        NavigationDestination(
          icon: AppIcon(
            AppIconType.home,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          selectedIcon: AppIcon(
            AppIconType.home,
            color: theme.colorScheme.primary,
          ),
          label: 'Measure',
        ),
        NavigationDestination(
          icon: AppIcon(
            AppIconType.enquiry,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          selectedIcon: AppIcon(
            AppIconType.enquiry,
            color: theme.colorScheme.primary,
          ),
          label: 'Enquiry',
        ),
        NavigationDestination(
          icon: AppIcon(
            AppIconType.agreement,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          selectedIcon: AppIcon(
            AppIconType.agreement,
            color: theme.colorScheme.primary,
          ),
          label: 'Agreement',
        ),
        NavigationDestination(
          icon: AppIcon(
            AppIconType.settings,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          selectedIcon: AppIcon(
            AppIconType.settings,
            color: theme.colorScheme.primary,
          ),
          label: 'Settings',
        ),
      ],
    );
  }
}
