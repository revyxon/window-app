import 'package:flutter/material.dart';
import '../../ui/design_system.dart';
import '../../ui/components/app_icon.dart';
import 'app_card.dart';

/// Grouped Settings Section (M3 Outlined Style)
class SettingsSection extends StatelessWidget {
  final String? title;
  final AppIconType? icon; // Added icon support
  final List<Widget> children;
  final EdgeInsetsGeometry? margin;

  const SettingsSection({
    super.key,
    this.title,
    this.icon,
    required this.children,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: margin ?? const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              child: Row(
                children: [
                  if (icon != null) ...[
                    AppIcon(icon!, size: 16, color: theme.colorScheme.primary),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Text(
                    title!.toUpperCase(),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
          ],

          // Container Card
          AppCard(
            padding: EdgeInsets.zero, // Children handle their own padding
            child: Column(
              children: [
                for (int i = 0; i < children.length; i++) ...[
                  children[i],
                  if (i < children.length - 1)
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: theme.colorScheme.outlineVariant.withValues(
                        alpha: 0.2,
                      ),
                      indent: AppSpacing.lg,
                      endIndent: AppSpacing.lg,
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
