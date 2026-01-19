import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/settings_provider.dart';
import '../utils/app_enums.dart';
import 'design_system.dart';

/// Premium Theme Generator
class AppTheme {
  /// Generate Light Theme
  static ThemeData lightTheme(SettingsProvider settings) {
    final primaryColor = settings.accentColor;
    final fontMultiplier = settings.fontSizeMultiplier;
    final surfaceData = AppSurfaces.getSurface(settings.surfaceVariant);

    final background = surfaceData.background;
    final surface = surfaceData.surface;
    final surfaceVariant = surfaceData.surfaceVariant;
    const onSurface = Color(0xFF1A1A1A);
    const onSurfaceVariant = Color(0xFF6B7280);
    const outline = Color(0xFFE5E7EB);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        onPrimary: Colors.white,
        primaryContainer: primaryColor.withValues(alpha: 0.1),
        onPrimaryContainer: primaryColor,
        secondary: primaryColor,
        onSecondary: Colors.white,
        surface: surface,
        onSurface: onSurface,
        surfaceContainerHighest: surfaceVariant,
        outline: outline,
        error: const Color(0xFFDC2626),
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: background,
      fontFamily: _getFontFamily(settings.fontFamily),
      textTheme: _buildTextTheme(onSurface, onSurfaceVariant, fontMultiplier),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: outline.withValues(alpha: 0.08)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        elevation: 0,
        height: 72,
        indicatorColor: primaryColor.withValues(alpha: 0.12),
        surfaceTintColor: Colors.transparent,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        elevation: 8,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl),
          ),
        ),
        showDragHandle: true,
        dragHandleColor: outline,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: primaryColor,
        inactiveTrackColor: primaryColor.withValues(alpha: 0.2),
        thumbColor: primaryColor,
        overlayColor: primaryColor.withValues(alpha: 0.1),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primaryColor;
          return null;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected))
            return primaryColor.withValues(alpha: 0.5);
          return null;
        }),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  /// Generate Dark Theme
  static ThemeData darkTheme(SettingsProvider settings) {
    final primaryColor = settings.accentColor;
    final fontMultiplier = settings.fontSizeMultiplier;

    const background = Color(0xFF000000);
    const surface = Color(0xFF121212);
    const surfaceVariant = Color(0xFF1E1E1E);
    const surfaceElevated = Color(0xFF2A2A2A);
    const onSurface = Color(0xFFF5F5F5);
    const onSurfaceVariant = Color(0xFF9CA3AF);
    const outline = Color(0xFF374151);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        onPrimary: Colors.white,
        primaryContainer: primaryColor.withValues(alpha: 0.2),
        onPrimaryContainer: primaryColor,
        secondary: primaryColor,
        onSecondary: Colors.white,
        surface: surface,
        onSurface: onSurface,
        surfaceContainerHighest: surfaceVariant,
        outline: outline,
        error: const Color(0xFFEF4444),
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: background,
      fontFamily: _getFontFamily(settings.fontFamily),
      textTheme: _buildTextTheme(onSurface, onSurfaceVariant, fontMultiplier),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: outline.withValues(alpha: 0.15)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        elevation: 0,
        height: 72,
        indicatorColor: primaryColor.withValues(alpha: 0.2),
        surfaceTintColor: Colors.transparent,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceElevated,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surfaceElevated,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl),
          ),
        ),
        showDragHandle: true,
        dragHandleColor: outline,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: primaryColor,
        inactiveTrackColor: primaryColor.withValues(alpha: 0.3),
        thumbColor: primaryColor,
        overlayColor: primaryColor.withValues(alpha: 0.2),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primaryColor;
          return null;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected))
            return primaryColor.withValues(alpha: 0.5);
          return null;
        }),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  static String? _getFontFamily(FontFamily family) {
    switch (family) {
      case FontFamily.inter:
        return GoogleFonts.inter().fontFamily;
      case FontFamily.roboto:
        return GoogleFonts.roboto().fontFamily;
      case FontFamily.poppins:
        return GoogleFonts.poppins().fontFamily;
      case FontFamily.nunito:
        return GoogleFonts.nunito().fontFamily;
      case FontFamily.lato:
        return GoogleFonts.lato().fontFamily;
      case FontFamily.openSans:
        return GoogleFonts.openSans().fontFamily;
      case FontFamily.montserrat:
        return GoogleFonts.montserrat().fontFamily;
      case FontFamily.raleway:
        return GoogleFonts.raleway().fontFamily;
      case FontFamily.sourceSans:
        return GoogleFonts.sourceSans3().fontFamily;
      case FontFamily.ubuntu:
        return GoogleFonts.ubuntu().fontFamily;
    }
  }

  static TextTheme _buildTextTheme(
    Color primary,
    Color secondary,
    double multiplier,
  ) {
    return TextTheme(
      displayLarge: AppTypography.displayLarge.copyWith(
        color: primary,
        fontSize: 32 * multiplier,
      ),
      displayMedium: AppTypography.displayMedium.copyWith(
        color: primary,
        fontSize: 28 * multiplier,
      ),
      headlineLarge: AppTypography.headlineLarge.copyWith(
        color: primary,
        fontSize: 24 * multiplier,
      ),
      headlineMedium: AppTypography.headlineMedium.copyWith(
        color: primary,
        fontSize: 20 * multiplier,
      ),
      headlineSmall: AppTypography.headlineSmall.copyWith(
        color: primary,
        fontSize: 18 * multiplier,
      ),
      titleLarge: AppTypography.titleLarge.copyWith(
        color: primary,
        fontSize: 16 * multiplier,
      ),
      titleMedium: AppTypography.titleMedium.copyWith(
        color: primary,
        fontSize: 14 * multiplier,
      ),
      titleSmall: AppTypography.titleSmall.copyWith(
        color: primary,
        fontSize: 13 * multiplier,
      ),
      bodyLarge: AppTypography.bodyLarge.copyWith(
        color: primary,
        fontSize: 16 * multiplier,
      ),
      bodyMedium: AppTypography.bodyMedium.copyWith(
        color: secondary,
        fontSize: 14 * multiplier,
      ),
      bodySmall: AppTypography.bodySmall.copyWith(
        color: secondary,
        fontSize: 12 * multiplier,
      ),
      labelLarge: AppTypography.labelLarge.copyWith(
        color: primary,
        fontSize: 14 * multiplier,
      ),
      labelMedium: AppTypography.labelMedium.copyWith(
        color: secondary,
        fontSize: 12 * multiplier,
      ),
      labelSmall: AppTypography.labelSmall.copyWith(
        color: secondary,
        fontSize: 11 * multiplier,
      ),
    );
  }
}
