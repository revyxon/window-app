import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  static const String _textScaleKey = 'text_scale';
  static const String _displayedFormulaKey = 'displayed_formula';
  static const String _lCornerFormulaKey = 'l_corner_formula';
  static const String _actualFormulaKey = 'actual_formula';

  ThemeMode _themeMode = ThemeMode.system;
  double _textScale = 1.0;
  double _displayedFormula = 90903.0; // W × H ÷ this = displayed sqft
  String _lCornerFormula = 'A'; // 'A' or 'B'
  double _actualFormula = 92903.04;   // W × H ÷ this = actual sqft

  ThemeMode get themeMode => _themeMode;
  double get textScale => _textScale;
  double get displayedFormula => _displayedFormula;
  String get lCornerFormula => _lCornerFormula;
  double get actualFormula => _actualFormula;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    final themeIndex = prefs.getInt(_themeKey) ?? 0;
    _themeMode = ThemeMode.values[themeIndex];
    
    _textScale = prefs.getDouble(_textScaleKey) ?? 1.0;
    _displayedFormula = prefs.getDouble(_displayedFormulaKey) ?? 90903.0;
    _lCornerFormula = prefs.getString(_lCornerFormulaKey) ?? 'A';
    _actualFormula = prefs.getDouble(_actualFormulaKey) ?? 92903.04;
    
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, mode.index);
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    if (_themeMode == ThemeMode.dark) {
      await setThemeMode(ThemeMode.light);
    } else {
      await setThemeMode(ThemeMode.dark);
    }
  }

  Future<void> setTextScale(double scale) async {
    _textScale = scale.clamp(0.8, 1.4);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_textScaleKey, _textScale);
    notifyListeners();
  }

  Future<void> setDisplayedFormula(double value) async {
    _displayedFormula = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_displayedFormulaKey, value);
    notifyListeners();
  }

  Future<void> setLCornerFormula(String value) async {
    _lCornerFormula = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lCornerFormulaKey, value);
    notifyListeners();
  }

  Future<void> setActualFormula(double value) async {
    _actualFormula = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_actualFormulaKey, value);
    notifyListeners();
  }

  Future<void> resetToDefaults() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_themeKey);
    await prefs.remove(_textScaleKey);
    await prefs.remove(_displayedFormulaKey);
    await prefs.remove(_lCornerFormulaKey);
    await prefs.remove(_actualFormulaKey);
    
    _themeMode = ThemeMode.system;
    _textScale = 1.0;
    _displayedFormula = 90903.0;
    _lCornerFormula = 'A';
    _actualFormula = 92903.04;
    
    notifyListeners();
  }
}
