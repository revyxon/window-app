import 'package:flutter/material.dart';

/// Design System: Color Tokens
///
/// Semantic color definitions that adapt to theme.
/// Use these via Theme.of(context) when possible.

abstract class AppColors {
  // Brand
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryLight = Color(0xFF3B82F6);

  // Semantic
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);

  // Light Theme
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFF9FAFB);
  static const Color lightBorder = Color(0xFFE5E7EB);
  static const Color lightTextPrimary = Color(0xFF1F2937);
  static const Color lightTextSecondary = Color(0xFF6B7280);

  // Dark Theme (OLED-friendly)
  static const Color darkBackground = Color(0xFF000000);
  static const Color darkSurface = Color(0xFF1C1C1E);
  static const Color darkBorder = Color(0xFF38383A);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFF8E8E93);
}
