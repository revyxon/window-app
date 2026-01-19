import 'package:flutter/material.dart';
import '../tokens/spacing.dart';

/// A content-first list row with consistent styling.
///
/// Use instead of ListTile for more control over layout.
/// Provides immediate touch feedback with InkWell.
class AppListRow extends StatelessWidget {
  final Widget? leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsetsGeometry? padding;
  final bool dense;

  const AppListRow({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.padding,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final verticalPadding = dense ? Spacing.sm : Spacing.md;

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Padding(
        padding:
            padding ??
            EdgeInsets.symmetric(
              horizontal: Spacing.lg,
              vertical: verticalPadding,
            ),
        child: Row(
          children: [
            if (leading != null) ...[
              leading!,
              const SizedBox(width: Spacing.lg),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: Spacing.xs),
                    Text(
                      subtitle!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: Spacing.md),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}

/// A tappable card-style row for elevated list items.
class AppCardRow extends StatelessWidget {
  final Widget? leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;

  const AppCardRow({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          margin ??
          const EdgeInsets.symmetric(
            horizontal: Spacing.lg,
            vertical: Spacing.sm,
          ),
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: AppListRow(
          leading: leading,
          title: title,
          subtitle: subtitle,
          trailing: trailing,
          onTap: onTap,
        ),
      ),
    );
  }
}
