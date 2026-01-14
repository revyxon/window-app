import 'package:flutter/material.dart';
import '../utils/animation_constants.dart';
import '../utils/haptics.dart';

/// Reusable animated press button with scale-down micro-animation
class AnimatedPressButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final double pressScale;
  final bool enableHaptics;
  final EdgeInsetsGeometry? padding;
  final BoxDecoration? decoration;

  const AnimatedPressButton({
    super.key,
    required this.child,
    this.onPressed,
    this.pressScale = 0.95,
    this.enableHaptics = true,
    this.padding,
    this.decoration,
  });

  @override
  State<AnimatedPressButton> createState() => _AnimatedPressButtonState();
}

class _AnimatedPressButtonState extends State<AnimatedPressButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onPressed != null
          ? (_) => setState(() => _isPressed = true)
          : null,
      onTapUp: widget.onPressed != null
          ? (_) => setState(() => _isPressed = false)
          : null,
      onTapCancel: widget.onPressed != null
          ? () => setState(() => _isPressed = false)
          : null,
      onTap: () {
        if (widget.enableHaptics) Haptics.light();
        widget.onPressed?.call();
      },
      child: AnimatedScale(
        scale: _isPressed ? widget.pressScale : 1.0,
        duration: AnimationDurations.ultraFast,
        curve: AnimationCurves.snappy,
        child: Container(
          padding: widget.padding,
          decoration: widget.decoration,
          child: widget.child,
        ),
      ),
    );
  }
}
