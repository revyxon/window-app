import 'package:flutter/material.dart';
import '../utils/animation_constants.dart';
import '../utils/haptics.dart';

/// Reusable animated press button with scale-down micro-animation
/// Premium feel with 80ms ultra-fast feedback
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

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  void _handleTap() {
    if (widget.enableHaptics) {
      Haptics.light();
    }
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onPressed != null ? _handleTapDown : null,
      onTapUp: widget.onPressed != null ? _handleTapUp : null,
      onTapCancel: widget.onPressed != null ? _handleTapCancel : null,
      onTap: widget.onPressed != null ? _handleTap : null,
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

/// Animated FAB with scale feedback
class AnimatedFAB extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final Color? backgroundColor;
  final double elevation;

  const AnimatedFAB({
    super.key,
    this.onPressed,
    required this.child,
    this.backgroundColor,
    this.elevation = 4,
  });

  @override
  State<AnimatedFAB> createState() => _AnimatedFABState();
}

class _AnimatedFABState extends State<AnimatedFAB> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        Haptics.medium();
        widget.onPressed?.call();
      },
      child: AnimatedScale(
        scale: _isPressed ? 0.92 : 1.0,
        duration: AnimationDurations.ultraFast,
        curve: AnimationCurves.snappy,
        child: FloatingActionButton(
          onPressed: null, // Handled by GestureDetector
          backgroundColor: widget.backgroundColor,
          elevation: widget.elevation,
          child: widget.child,
        ),
      ),
    );
  }
}
