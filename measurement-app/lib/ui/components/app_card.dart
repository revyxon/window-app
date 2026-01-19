import 'package:flutter/material.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final BorderSide? border;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onPressed,
    this.backgroundColor,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Premium Card Style (matching _analysisCard design)
    final cardContent = Container(
      padding: padding ?? const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color:
            backgroundColor ??
            (isDark ? theme.colorScheme.surface : Colors.white),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color:
              border?.color ??
              theme.colorScheme.outlineVariant.withValues(
                alpha: isDark ? 0.15 : 0.08,
              ),
          width: border?.width ?? 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );

    if (onPressed != null) {
      return GestureDetector(onTap: onPressed, child: cardContent);
    }

    return cardContent;
  }
}
