import 'package:flutter/material.dart';
import 'app_icon.dart';
import '../design_system.dart';

class AppHeader extends StatelessWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final AppIconType? icon;

  const AppHeader({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SliverAppBar(
      toolbarHeight: 56, // Balanced height
      titleSpacing: NavigationToolbar.kMiddleSpacing, // Default 16px spacing
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            AppIcon(icon!, size: 24, color: theme.colorScheme.primary),
            const SizedBox(width: AppSpacing.sm),
          ],
          Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
      centerTitle: centerTitle,
      pinned: true,
      floating: false,
      scrolledUnderElevation: 0,
      backgroundColor: theme.scaffoldBackgroundColor,
      surfaceTintColor: Colors.transparent,
      leading: leading,
      actions: actions,
    );
  }
}
