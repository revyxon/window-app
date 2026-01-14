import 'package:flutter/material.dart';
import 'animation_constants.dart';

/// Ultra-fast page route with premium slide + fade transition
/// Duration: 180ms (vs Flutter default 300ms)
/// Curve: easeOutCubic for natural, snappy feel
class FastPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  FastPageRoute({required this.page})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionDuration: AnimationDurations.normal,
        reverseTransitionDuration: AnimationDurations.normal,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Slide from right with fade
          const begin = Offset(0.15, 0.0); // Subtle slide (15% vs typical 100%)
          const end = Offset.zero;

          final slideTween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: AnimationCurves.snappy));

          final fadeTween = Tween(
            begin: 0.0,
            end: 1.0,
          ).chain(CurveTween(curve: AnimationCurves.decelerate));

          return SlideTransition(
            position: animation.drive(slideTween),
            child: FadeTransition(
              opacity: animation.drive(fadeTween),
              child: child,
            ),
          );
        },
      );
}

/// Even faster route for modals and overlays
class UltraFastPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  UltraFastPageRoute({required this.page})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionDuration: AnimationDurations.fast,
        reverseTransitionDuration: AnimationDurations.fast,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Pure fade for ultra-speed
          final fadeTween = Tween(
            begin: 0.0,
            end: 1.0,
          ).chain(CurveTween(curve: AnimationCurves.snappy));

          return FadeTransition(
            opacity: animation.drive(fadeTween),
            child: child,
          );
        },
      );
}
