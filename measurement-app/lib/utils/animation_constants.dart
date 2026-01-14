import 'package:flutter/material.dart';

/// Centralized animation constants for ultra-fast, premium UX
class AnimationDurations {
  /// Ultra-fast - for micro-interactions (button press feedback)
  static const Duration ultraFast = Duration(milliseconds: 50);

  /// Fast - for quick transitions (press scale, toggle states)
  static const Duration fast = Duration(milliseconds: 100);

  /// Normal - for page transitions (navigation)
  static const Duration normal = Duration(milliseconds: 150);

  /// Medium - for more elaborate animations
  static const Duration medium = Duration(milliseconds: 200);

  /// Slow - for emphasized animations (rare use)
  static const Duration slow = Duration(milliseconds: 300);
}

/// Premium animation curves for snappy feel
class AnimationCurves {
  /// Snappy - primary curve for most interactions
  static const Curve snappy = Curves.easeOutCubic;

  /// Smooth - for bidirectional animations
  static const Curve smooth = Curves.easeInOutCubic;

  /// Decelerate - for elements entering view
  static const Curve decelerate = Curves.decelerate;

  /// Fast out slow in - for emphasis
  static const Curve emphasis = Curves.fastOutSlowIn;
}
