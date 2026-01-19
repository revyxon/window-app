import 'package:flutter/material.dart';

/// Premium Color Palettes
/// Top 20 Global Premium Picks
enum AppThemeVariant {
  oceanBlue,
  navy,
  midnightBlue,
  teal,
  slate,
  emerald,
  forestGreen,
  oliveGreen,
  sage,
  moss,
  sunsetGold,
  goldenBrass,
  coffeeBrown,
  deepOrange,
  burntCopper,
  terracotta,
  graphite,
  steelGray,
  carbonBlack,
  charcoal,
  frostSilver,
  champagne,
  sandstone,
  desertSand,
}

/// Centralized Theme Configuration
class AppThemeData {
  final String name;
  final Color primary;
  final Color secondary;
  final Color accent;

  const AppThemeData({
    required this.name,
    required this.primary,
    required this.secondary,
    required this.accent,
  });
}

/// Premium Theme Palettes
abstract class AppPalettes {
  // Premium Colors (24 Total)
  // 1. Blues & Teals
  static const oceanBlue = AppThemeData(
    name: 'Ocean Blue',
    primary: Color(0xFF0077B6),
    secondary: Color(0xFF0096C7),
    accent: Color(0xFF00B4D8),
  );
  static const navy = AppThemeData(
    name: 'Navy',
    primary: Color(0xFF1E3A8A),
    secondary: Color(0xFF1E40AF),
    accent: Color(0xFF2563EB),
  );
  static const midnightBlue = AppThemeData(
    name: 'Midnight Blue',
    primary: Color(0xFF0F172A),
    secondary: Color(0xFF1E293B),
    accent: Color(0xFF334155),
  );
  static const teal = AppThemeData(
    name: 'Teal',
    primary: Color(0xFF0D9488),
    secondary: Color(0xFF14B8A6),
    accent: Color(0xFF2DD4BF),
  );
  static const slate = AppThemeData(
    name: 'Slate',
    primary: Color(0xFF475569),
    secondary: Color(0xFF64748B),
    accent: Color(0xFF94A3B8),
  );

  // 2. Greens & Earths
  static const emerald = AppThemeData(
    name: 'Emerald',
    primary: Color(0xFF059669),
    secondary: Color(0xFF10B981),
    accent: Color(0xFF34D399),
  );
  static const forestGreen = AppThemeData(
    name: 'Forest Green',
    primary: Color(0xFF14532D),
    secondary: Color(0xFF166534),
    accent: Color(0xFF15803D),
  );
  static const oliveGreen = AppThemeData(
    name: 'Olive Green',
    primary: Color(0xFF656D4A),
    secondary: Color(0xFFA4AC86),
    accent: Color(0xFFC2C5AA),
  );
  static const sage = AppThemeData(
    name: 'Sage',
    primary: Color(0xFF576F5E),
    secondary: Color(0xFF839C8A),
    accent: Color(0xFFA7C2AF),
  );
  static const moss = AppThemeData(
    name: 'Moss',
    primary: Color(0xFF4A5D23),
    secondary: Color(0xFF67822D),
    accent: Color(0xFF849942),
  );

  // 3. Warm Tones (Golds, Browns, Oranges)
  static const sunsetGold = AppThemeData(
    name: 'Sunset Gold',
    primary: Color(0xFFF48C06),
    secondary: Color(0xFFFAA307),
    accent: Color(0xFFFFBA08),
  );
  static const goldenBrass = AppThemeData(
    name: 'Golden Brass',
    primary: Color(0xFFB45309),
    secondary: Color(0xFFD97706),
    accent: Color(0xFFF59E0B),
  );
  static const coffeeBrown = AppThemeData(
    name: 'Coffee Brown',
    primary: Color(0xFF78350F),
    secondary: Color(0xFF92400E),
    accent: Color(0xFFB45309),
  );
  static const deepOrange = AppThemeData(
    name: 'Deep Orange',
    primary: Color(0xFFEA580C),
    secondary: Color(0xFFF97316),
    accent: Color(0xFFFB923C),
  );
  static const burntCopper = AppThemeData(
    name: 'Burnt Copper',
    primary: Color(0xFF9A3412),
    secondary: Color(0xFFC2410C),
    accent: Color(0xFFEA580C),
  );
  static const terracotta = AppThemeData(
    name: 'Terracotta',
    primary: Color(0xFF9F3E24),
    secondary: Color(0xFFC6583E),
    accent: Color(0xFFE57A5F),
  );

  // 4. Neutrals & Metals
  static const graphite = AppThemeData(
    name: 'Graphite',
    primary: Color(0xFF374151),
    secondary: Color(0xFF4B5563),
    accent: Color(0xFF6B7280),
  );
  static const steelGray = AppThemeData(
    name: 'Steel Gray',
    primary: Color(0xFF475569),
    secondary: Color(0xFF64748B),
    accent: Color(0xFF94A3B8),
  );
  static const carbonBlack = AppThemeData(
    name: 'Carbon Black',
    primary: Color(0xFF111827),
    secondary: Color(0xFF1F2937),
    accent: Color(0xFF374151),
  );
  static const charcoal = AppThemeData(
    name: 'Charcoal',
    primary: Color(0xFF334155),
    secondary: Color(0xFF475569),
    accent: Color(0xFF64748B),
  );
  static const frostSilver = AppThemeData(
    name: 'Frost Silver',
    primary: Color(0xFF94A3B8),
    secondary: Color(0xFFCBD5E1),
    accent: Color(0xFFE2E8F0),
  );
  static const champagne = AppThemeData(
    name: 'Champagne',
    primary: Color(0xFF8A817C),
    secondary: Color(0xFFBCB8B1),
    accent: Color(0xFFF4F3EE),
  );
  static const sandstone = AppThemeData(
    name: 'Sandstone',
    primary: Color(0xFFA8A29E),
    secondary: Color(0xFFD6D3D1),
    accent: Color(0xFFE7E5E4),
  );
  static const desertSand = AppThemeData(
    name: 'Desert Sand',
    primary: Color(0xFFD4A373),
    secondary: Color(0xFFFAEDCD),
    accent: Color(0xFFFEFAE0),
  );

  // 5. Reds (Professional)
  static const rosewood = AppThemeData(
    name: 'Rosewood',
    primary: Color(0xFF9F1239),
    secondary: Color(0xFFBE123C),
    accent: Color(0xFFE11D48),
  );

  static AppThemeData getTheme(AppThemeVariant variant) {
    switch (variant) {
      case AppThemeVariant.oceanBlue:
        return oceanBlue;
      case AppThemeVariant.navy:
        return navy;
      case AppThemeVariant.midnightBlue:
        return midnightBlue;
      case AppThemeVariant.teal:
        return teal;
      case AppThemeVariant.slate:
        return slate;
      case AppThemeVariant.emerald:
        return emerald;
      case AppThemeVariant.forestGreen:
        return forestGreen;
      case AppThemeVariant.oliveGreen:
        return oliveGreen;
      case AppThemeVariant.sage:
        return sage;
      case AppThemeVariant.moss:
        return moss;
      case AppThemeVariant.sunsetGold:
        return sunsetGold;
      case AppThemeVariant.goldenBrass:
        return goldenBrass;
      case AppThemeVariant.coffeeBrown:
        return coffeeBrown;
      case AppThemeVariant.deepOrange:
        return deepOrange;
      case AppThemeVariant.burntCopper:
        return burntCopper;
      case AppThemeVariant.terracotta:
        return terracotta;
      case AppThemeVariant.graphite:
        return graphite;
      case AppThemeVariant.steelGray:
        return steelGray;
      case AppThemeVariant.carbonBlack:
        return carbonBlack;
      case AppThemeVariant.charcoal:
        return charcoal;
      case AppThemeVariant.frostSilver:
        return frostSilver;
      case AppThemeVariant.champagne:
        return champagne;
      case AppThemeVariant.sandstone:
        return sandstone;
      case AppThemeVariant.desertSand:
        return desertSand;
    }
  }
}

/// Neutral Surface Colors (10 Variants)
enum AppSurfaceVariant {
  pureWhite,
  softWhite,
  warmWhite,
  coolWhite,
  alabaster,
  mistGray,
  softGray,
  warmGray,
  coolGray,
  pearl,
}

class AppSurfaceData {
  final String name;
  final Color background; // Scaffold
  final Color surface; // Card/Sheet
  final Color surfaceVariant; // Input/Secondary

  const AppSurfaceData({
    required this.name,
    required this.background,
    required this.surface,
    required this.surfaceVariant,
  });
}

abstract class AppSurfaces {
  // 1. Pure White (Standard)
  static const pureWhite = AppSurfaceData(
    name: 'Pure White',
    background: Color(0xFFFFFFFF),
    surface: Color(0xFFF9FAFB),
    surfaceVariant: Color(0xFFF3F4F6),
  );

  // 2. Soft White (Slightly dimmed)
  static const softWhite = AppSurfaceData(
    name: 'Soft White',
    background: Color(0xFFFCFCFC), // Very subtle off-white
    surface: Color(0xFFFFFFFF),
    surfaceVariant: Color(0xFFF5F5F5),
  );

  // 3. Warm White (Yellow tint)
  static const warmWhite = AppSurfaceData(
    name: 'Warm White',
    background: Color(0xFFFAF9F6), // Off-white
    surface: Color(0xFFFFFFFF),
    surfaceVariant: Color(0xFFF2F0EB),
  );

  // 4. Cool White (Blue tint)
  static const coolWhite = AppSurfaceData(
    name: 'Cool White',
    background: Color(0xFFF8FAFC), // Alice blue hint
    surface: Color(0xFFFFFFFF),
    surfaceVariant: Color(0xFFF1F5F9),
  );

  // 5. Alabaster (Earthy white)
  static const alabaster = AppSurfaceData(
    name: 'Alabaster',
    background: Color(0xFFFDFBF7), // Warm earthy white
    surface: Color(0xFFFFFFFF),
    surfaceVariant: Color(0xFFF5F2EB),
  );

  // 6. Mist Gray (Very light gray)
  static const mistGray = AppSurfaceData(
    name: 'Mist',
    background: Color(0xFFF3F4F6),
    surface: Color(0xFFFFFFFF),
    surfaceVariant: Color(0xFFE5E7EB),
  );

  // 7. Soft Gray (Neutral)
  static const softGray = AppSurfaceData(
    name: 'Soft Gray',
    background: Color(0xFFF2F2F2),
    surface: Color(0xFFFEFEFE),
    surfaceVariant: Color(0xFFEBEBEB),
  );

  // 8. Warm Gray (Beige tint)
  static const warmGray = AppSurfaceData(
    name: 'Warm Gray',
    background: Color(0xFFF5F5F4), // Stone
    surface: Color(0xFFFAFAFA),
    surfaceVariant: Color(0xFFE7E5E4),
  );

  // 9. Cool Gray (Blue-gray tint)
  static const coolGray = AppSurfaceData(
    name: 'Cool Gray',
    background: Color(0xFFF1F5F9), // Slate 100
    surface: Color(0xFFFFFFFF),
    surfaceVariant: Color(0xFFE2E8F0),
  );

  // 10. Pearl (Bright & Clean)
  static const pearl = AppSurfaceData(
    name: 'Pearl',
    background: Color(0xFFFBFCFD),
    surface: Color(0xFFFFFFFF),
    surfaceVariant: Color(0xFFEEF2F6),
  );

  static AppSurfaceData getSurface(AppSurfaceVariant variant) {
    switch (variant) {
      case AppSurfaceVariant.pureWhite:
        return pureWhite;
      case AppSurfaceVariant.softWhite:
        return softWhite;
      case AppSurfaceVariant.warmWhite:
        return warmWhite;
      case AppSurfaceVariant.coolWhite:
        return coolWhite;
      case AppSurfaceVariant.alabaster:
        return alabaster;
      case AppSurfaceVariant.mistGray:
        return mistGray;
      case AppSurfaceVariant.softGray:
        return softGray;
      case AppSurfaceVariant.warmGray:
        return warmGray;
      case AppSurfaceVariant.coolGray:
        return coolGray;
      case AppSurfaceVariant.pearl:
        return pearl;
    }
  }
}

/// Premium Typography Scale
abstract class AppTypography {
  static const String fontFamily = 'Inter';

  // Display
  static const TextStyle displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    height: 1.25,
  );

  // Headlines
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    height: 1.3,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.35,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
    height: 1.4,
  );

  // Titles
  static const TextStyle titleLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.4,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.4,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.4,
  );

  // Body
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.2,
    height: 1.5,
  );

  // Labels
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.4,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
    height: 1.4,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.4,
  );
}

/// Premium Spacing Scale
abstract class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  // Screen padding
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: md,
  );

  // Card padding
  static const EdgeInsets cardPadding = EdgeInsets.all(lg);

  // List item padding
  static const EdgeInsets listItemPadding = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: md,
  );
}

/// Premium Border Radius
abstract class AppRadius {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double full = 999;
}

/// Premium Elevation
abstract class AppElevation {
  static const double none = 0;
  static const double xs = 1;
  static const double sm = 2;
  static const double md = 4;
  static const double lg = 8;
  static const double xl = 16;
}
