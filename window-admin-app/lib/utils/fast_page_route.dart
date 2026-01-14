import 'package:flutter/material.dart';
import 'animation_constants.dart';

/// Ultra-fast page route with premium slide + fade transition
/// Duration: 150ms (Feather Light)
class FastPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  FastPageRoute({required this.page})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionDuration: AnimationDurations.normal,
        reverseTransitionDuration: AnimationDurations.normal,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Slide from right with fade
          const begin = Offset(0.15, 0.0); // Subtle slide
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
