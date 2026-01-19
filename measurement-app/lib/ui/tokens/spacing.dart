/// Design System: Spacing Tokens
///
/// A strict spacing scale for consistent layouts.
/// Use these values instead of arbitrary padding/margins.

abstract class Spacing {
  /// 4dp - Tight spacing (icons, inline elements)
  static const double xs = 4;

  /// 8dp - Small spacing (between related items)
  static const double sm = 8;

  /// 12dp - Medium-small (form field gaps)
  static const double md = 12;

  /// 16dp - Standard spacing (section padding)
  static const double lg = 16;

  /// 24dp - Large spacing (between sections)
  static const double xl = 24;

  /// 32dp - Extra large (screen margins, major separations)
  static const double xxl = 32;

  /// 48dp - Maximum spacing (hero sections)
  static const double xxxl = 48;

  // Common Edge Insets
  static const screenHorizontal = lg;
  static const screenVertical = xl;
  static const cardPadding = lg;
  static const listItemVertical = md;
}
