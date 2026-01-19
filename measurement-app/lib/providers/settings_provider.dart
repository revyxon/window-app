import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../ui/design_system.dart';
import '../utils/app_enums.dart';

class SettingsProvider with ChangeNotifier {
  // Keys
  static const _themeKey = 'theme_mode';
  static const _iconPackKey = 'icon_pack';
  static const _fontFamilyKey = 'font_family';
  static const _fontSizeKey = 'font_size';
  static const _accentColorKey = 'accent_color';
  static const _hapticFeedbackKey = 'haptic_feedback';
  static const _displayedFormulaKey = 'displayed_formula';
  static const _actualFormulaKey = 'actual_formula';
  static const _lCornerFormulaKey = 'l_corner_formula';
  static const _surfaceVariantKey = 'surface_variant';

  // State
  ThemeMode _themeMode = ThemeMode.system;
  IconPack _iconPack = IconPack.material;
  FontFamily _fontFamily = FontFamily.inter;
  double _fontSize = 1.0;
  int _accentColorIndex = 0;
  AppSurfaceVariant _surfaceVariant = AppSurfaceVariant.softWhite;
  bool _hapticFeedback = true;
  double _displayedFormula = 90903.0;
  double _actualFormula = 92903.04;
  String _lCornerFormula = 'A';

  // Getters
  ThemeMode get themeMode => _themeMode;
  IconPack get iconPack => _iconPack;
  FontFamily get fontFamily => _fontFamily;
  double get fontSize => _fontSize;
  int get accentColorIndex => _accentColorIndex;
  AppSurfaceVariant get surfaceVariant => _surfaceVariant;
  bool get hapticFeedback => _hapticFeedback;
  double get displayedFormula => _displayedFormula;
  double get actualFormula => _actualFormula;
  String get lCornerFormula => _lCornerFormula;

  bool get isDarkMode => _themeMode == ThemeMode.dark;
  double get fontSizeMultiplier => _fontSize;

  String get fontFamilyDisplayName {
    switch (_fontFamily) {
      case FontFamily.inter:
        return 'Inter';
      case FontFamily.roboto:
        return 'Roboto';
      case FontFamily.poppins:
        return 'Poppins';
      case FontFamily.nunito:
        return 'Nunito';
      case FontFamily.lato:
        return 'Lato';
      case FontFamily.openSans:
        return 'Open Sans';
      case FontFamily.montserrat:
        return 'Montserrat';
      case FontFamily.raleway:
        return 'Raleway';
      case FontFamily.sourceSans:
        return 'Source Sans';
      case FontFamily.ubuntu:
        return 'Ubuntu';
    }
  }

  String get fontFamilyName {
    switch (_fontFamily) {
      case FontFamily.inter:
        return 'Inter';
      case FontFamily.roboto:
        return 'Roboto';
      case FontFamily.poppins:
        return 'Poppins';
      case FontFamily.nunito:
        return 'Nunito';
      case FontFamily.lato:
        return 'Lato';
      case FontFamily.openSans:
        return 'Open Sans';
      case FontFamily.montserrat:
        return 'Montserrat';
      case FontFamily.raleway:
        return 'Raleway';
      case FontFamily.sourceSans:
        return 'Source Sans Pro';
      case FontFamily.ubuntu:
        return 'Ubuntu';
    }
  }

  // Material 3 accent colors (19 Premium Colors)
  // Material 3 accent colors (24 Premium Colors)
  static final List<AppThemeData> accentThemes = [
    AppPalettes.oceanBlue,
    AppPalettes.navy,
    AppPalettes.midnightBlue,
    AppPalettes.teal,
    AppPalettes.slate,
    AppPalettes.emerald,
    AppPalettes.forestGreen,
    AppPalettes.oliveGreen,
    AppPalettes.sage,
    AppPalettes.moss,
    AppPalettes.sunsetGold,
    AppPalettes.goldenBrass,
    AppPalettes.coffeeBrown,
    AppPalettes.deepOrange,
    AppPalettes.burntCopper,
    AppPalettes.terracotta,
    AppPalettes.graphite,
    AppPalettes.steelGray,
    AppPalettes.carbonBlack,
    AppPalettes.charcoal,
    AppPalettes.frostSilver,
    AppPalettes.champagne,
    AppPalettes.sandstone,
    AppPalettes.desertSand,
  ];

  static List<Color> get accentColors =>
      accentThemes.map((e) => e.primary).toList();
  static List<String> get accentColorNames =>
      accentThemes.map((e) => e.name).toList();

  Color get accentColor =>
      accentThemes[_accentColorIndex.clamp(0, accentThemes.length - 1)].primary;
  String get accentColorName =>
      accentThemes[_accentColorIndex.clamp(0, accentThemes.length - 1)].name;

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    final themeIndex = prefs.getInt(_themeKey) ?? 2;
    _themeMode =
        ThemeMode.values[themeIndex.clamp(0, ThemeMode.values.length - 1)];

    final iconPackIndex = prefs.getInt(_iconPackKey) ?? 0;
    _iconPack =
        IconPack.values[iconPackIndex.clamp(0, IconPack.values.length - 1)];

    final fontFamilyIndex = prefs.getInt(_fontFamilyKey) ?? 0;
    _fontFamily = FontFamily
        .values[fontFamilyIndex.clamp(0, FontFamily.values.length - 1)];

    _fontSize = prefs.getDouble(_fontSizeKey) ?? 1.0;
    _accentColorIndex = prefs.getInt(_accentColorKey) ?? 0;

    final surfaceIndex =
        prefs.getInt(_surfaceVariantKey) ?? 1; // Default Soft White
    _surfaceVariant = AppSurfaceVariant
        .values[surfaceIndex.clamp(0, AppSurfaceVariant.values.length - 1)];

    _hapticFeedback = prefs.getBool(_hapticFeedbackKey) ?? true;
    _displayedFormula = prefs.getDouble(_displayedFormulaKey) ?? 90903.0;
    _actualFormula = prefs.getDouble(_actualFormulaKey) ?? 92903.04;
    _lCornerFormula = prefs.getString(_lCornerFormulaKey) ?? 'A';

    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, mode.index);
    notifyListeners();
  }

  Future<void> setIconPack(IconPack pack) async {
    _iconPack = pack;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_iconPackKey, pack.index);
    notifyListeners();
  }

  Future<void> setFontFamily(FontFamily family) async {
    _fontFamily = family;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_fontFamilyKey, family.index);
    notifyListeners();
  }

  Future<void> setFontSize(double size) async {
    _fontSize = size;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontSizeKey, size);
    notifyListeners();
  }

  Future<void> setAccentColor(int index) async {
    _accentColorIndex = index;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_accentColorKey, index);
    notifyListeners();
  }

  Future<void> setSurfaceVariant(AppSurfaceVariant variant) async {
    _surfaceVariant = variant;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_surfaceVariantKey, variant.index);
    notifyListeners();
  }

  Future<void> setHapticFeedback(bool enabled) async {
    _hapticFeedback = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hapticFeedbackKey, enabled);
    notifyListeners();
  }

  Future<void> setFormulas(
    double displayed,
    double actual,
    String lCorner,
  ) async {
    _displayedFormula = displayed;
    _actualFormula = actual;
    _lCornerFormula = lCorner;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_displayedFormulaKey, displayed);
    await prefs.setDouble(_actualFormulaKey, actual);
    await prefs.setString(_lCornerFormulaKey, lCorner);
    notifyListeners();
  }

  Future<void> resetToDefaults() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    _themeMode = ThemeMode.system;
    _iconPack = IconPack.material;
    _fontFamily = FontFamily.inter;
    _fontSize = 1.0;
    _accentColorIndex = 0;
    _surfaceVariant = AppSurfaceVariant.softWhite;
    _hapticFeedback = true;
    _displayedFormula = 90903.0;
    _actualFormula = 92903.04;
    _lCornerFormula = 'A';

    notifyListeners();
  }
}
