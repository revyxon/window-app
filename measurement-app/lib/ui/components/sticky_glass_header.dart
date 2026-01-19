import 'dart:ui';
import 'package:flutter/material.dart';
import '../../ui/design_system.dart';

/// Premium Sticky Glass Header for SliverLists
class StickyGlassHeader extends SliverPersistentHeaderDelegate {
  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool enableBlur;
  final double expandedHeight;
  final double collapsedHeight;

  StickyGlassHeader({
    required this.title,
    this.leading,
    this.actions,
    this.enableBlur = true,
    this.expandedHeight = 120.0,
    this.collapsedHeight = 80.0,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Calculate progress (0.0 = fully expanded, 1.0 = fully collapsed)
    final progress = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);
    final inverseProgress = 1.0 - progress;

    return ClipRect(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Glass Background
          if (enableBlur)
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                color: theme.scaffoldBackgroundColor.withValues(
                  alpha: isDark ? 0.7 : 0.8,
                ),
              ),
            )
          else
            Container(
              color: theme.scaffoldBackgroundColor.withValues(alpha: 0.95),
            ),

          // Bottom Border (opacity based on scroll)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 1,
              color: theme.colorScheme.outline.withValues(
                alpha: 0.1 * progress,
              ),
            ),
          ),

          // Content
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Stack(
                children: [
                  // Leading Action (Back Button etc)
                  if (leading != null)
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: leading,
                      ),
                    ),

                  // Actions (Settings, Search etc)
                  if (actions != null)
                    Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: actions!,
                        ),
                      ),
                    ),

                  // Title Animation
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Transform.translate(
                      offset: Offset(
                        leading != null
                            ? 48.0 * inverseProgress
                            : 0, // Slide right when expanded if NO leading, but we want stable title
                        // Actually better: Slide up/down
                        20.0 * progress,
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(
                          // Move text based on expansion
                          top:
                              40.0 * inverseProgress +
                              (leading != null ? 0 : 0),
                          left: leading != null ? 48 : 0,
                        ),
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 32.0 - (12.0 * progress), // 32 -> 20
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                            letterSpacing: -0.5,
                            fontFamily:
                                theme.textTheme.headlineMedium?.fontFamily,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => expandedHeight;

  @override
  double get minExtent => collapsedHeight;

  @override
  bool shouldRebuild(covariant StickyGlassHeader oldDelegate) {
    return title != oldDelegate.title || enableBlur != oldDelegate.enableBlur;
  }
}
