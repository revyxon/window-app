import 'package:flutter/material.dart';
import '../tokens/spacing.dart';

/// A section container with optional header.
///
/// Use to group related content with consistent spacing.
class AppSection extends StatelessWidget {
  final String? title;
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;
  final bool showDivider;

  const AppSection({
    super.key,
    this.title,
    required this.children,
    this.padding,
    this.showDivider = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.only(
              left: Spacing.lg,
              right: Spacing.lg,
              top: Spacing.xl,
              bottom: Spacing.sm,
            ),
            child: Text(
              title!.toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        if (showDivider && title != null)
          Divider(height: 1, indent: Spacing.lg, endIndent: Spacing.lg),
        ...children,
      ],
    );
  }
}

/// A sliver version of AppSection for use in CustomScrollView.
class SliverAppSection extends StatelessWidget {
  final String? title;
  final List<Widget> children;

  const SliverAppSection({super.key, this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: AppSection(title: title, children: children),
    );
  }
}
