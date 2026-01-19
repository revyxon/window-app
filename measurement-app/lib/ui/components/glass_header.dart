import 'dart:ui';
import 'package:flutter/material.dart';
import '../design_system.dart';

/// Premium Glassmorphic Header
///
/// Frosted glass effect header with blur and translucency.
/// Use for consistent screen headers across the app.
class GlassHeader extends StatelessWidget {
  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final Widget? bottom;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const GlassHeader({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.bottom,
    this.showBackButton = false,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? Colors.black.withValues(alpha: 0.7)
                : Colors.white.withValues(alpha: 0.8),
            border: Border(
              bottom: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.1),
                width: 0.5,
              ),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      if (showBackButton)
                        IconButton(
                          icon: Icon(
                            Icons.arrow_back_ios_rounded,
                            color: theme.colorScheme.onSurface,
                          ),
                          onPressed:
                              onBackPressed ??
                              () => Navigator.of(context).pop(),
                        )
                      else if (leading != null)
                        leading!,

                      if (showBackButton || leading != null)
                        const SizedBox(width: AppSpacing.sm),

                      Expanded(
                        child: Text(
                          title,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),

                      if (actions != null) ...actions!,
                    ],
                  ),
                ),
                if (bottom != null)
                  Padding(
                    padding: const EdgeInsets.only(
                      left: AppSpacing.lg,
                      right: AppSpacing.lg,
                      bottom: AppSpacing.md,
                    ),
                    child: bottom!,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Glassmorphic Sliver Header
///
/// For use in CustomScrollView with pinned glass effect.
class GlassSliverHeader extends StatelessWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? bottom;
  final double expandedHeight;

  const GlassSliverHeader({
    super.key,
    required this.title,
    this.actions,
    this.bottom,
    this.expandedHeight = 56,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SliverAppBar(
      pinned: true,
      floating: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      expandedHeight: bottom != null ? expandedHeight + 64 : expandedHeight,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.7)
                  : Colors.white.withValues(alpha: 0.85),
              border: Border(
                bottom: BorderSide(
                  color: theme.colorScheme.outline.withValues(alpha: 0.1),
                  width: 0.5,
                ),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: expandedHeight,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ),
                          if (actions != null) ...actions!,
                        ],
                      ),
                    ),
                  ),
                  if (bottom != null)
                    Padding(
                      padding: const EdgeInsets.only(
                        left: AppSpacing.lg,
                        right: AppSpacing.lg,
                        bottom: AppSpacing.md,
                      ),
                      child: bottom!,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
