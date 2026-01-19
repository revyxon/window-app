import 'package:flutter/material.dart';
import '../tokens/spacing.dart';
import '../tokens/durations.dart';

/// Primary action button with loading state.
///
/// Features:
/// - Full-width option
/// - Loading state with spinner
/// - Disabled state
/// - 48dp minimum touch target
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final ButtonStyle? style;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final button = FilledButton(
      onPressed: isLoading ? null : onPressed,
      style: style,
      child: AnimatedSwitcher(
        duration: AppDurations.fast,
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: Spacing.sm),
                  ],
                  Text(label),
                ],
              ),
      ),
    );

    if (isFullWidth) {
      return SizedBox(width: double.infinity, height: 48, child: button);
    }

    return button;
  }
}

/// Secondary/outline button variant.
class AppOutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isFullWidth;
  final IconData? icon;

  const AppOutlineButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isFullWidth = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final button = OutlinedButton(
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20),
            const SizedBox(width: Spacing.sm),
          ],
          Text(label),
        ],
      ),
    );

    if (isFullWidth) {
      return SizedBox(width: double.infinity, height: 48, child: button);
    }

    return button;
  }
}

/// Text-only button for tertiary actions.
class AppTextButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  const AppTextButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20),
            const SizedBox(width: Spacing.sm),
          ],
          Text(label),
        ],
      ),
    );
  }
}
