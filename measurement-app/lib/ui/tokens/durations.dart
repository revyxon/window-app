import 'package:flutter/animation.dart';

/// Design System: Animation Duration Tokens
///
/// Standardized animation timings for consistent motion.
/// All animations should feel instant but smooth.

abstract class AppDurations {
  /// 0ms - No animation (instant state changes)
  static const Duration instant = Duration.zero;

  /// 100ms - Ultra fast (touch feedback, ripples)
  static const Duration feedback = Duration(milliseconds: 100);

  /// 150ms - Fast (micro-interactions, focus changes)
  static const Duration fast = Duration(milliseconds: 150);

  /// 200ms - Normal (page transitions, reveals)
  static const Duration normal = Duration(milliseconds: 200);

  /// 300ms - Slow (complex animations, modals)
  static const Duration slow = Duration(milliseconds: 300);
}

/// Standard animation curves (prefixed to avoid Flutter conflict)
abstract class AppCurves {
  /// Default curve for most animations (Material 3 standard)
  static const Cubic standard = Cubic(0.2, 0.0, 0.0, 1.0);

  /// For elements entering the screen
  static const Cubic enter = Cubic(0.0, 0.0, 0.0, 1.0);

  /// For elements leaving the screen
  static const Cubic exit = Cubic(0.4, 0.0, 1.0, 1.0);
}
