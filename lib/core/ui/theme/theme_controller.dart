import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode { system, light, dark }

class ThemeController extends ChangeNotifier {
  static const _themePrefKey = 'appThemeMode';
  AppThemeMode _themeMode = AppThemeMode.system;

  AppThemeMode get themeMode => _themeMode;

  /// Flutter의 ThemeMode 변환
  ThemeMode get flutterThemeMode {
    switch (_themeMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  ThemeController() {
    _loadThemeFromPrefs();
  }

  /// 테마 변경
  void setTheme(AppThemeMode mode) {
    _themeMode = mode;
    _saveThemeToPrefs();
    notifyListeners();
  }

  Future<void> _loadThemeFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final modeIndex = prefs.getInt(_themePrefKey);
    if (modeIndex != null) {
      _themeMode = AppThemeMode.values[modeIndex];
      notifyListeners();
    }
  }

  Future<void> _saveThemeToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themePrefKey, _themeMode.index);
  }

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final modeIndex = prefs.getInt(_themePrefKey);
    if (modeIndex != null) {
      _themeMode = AppThemeMode.values[modeIndex];
    } else {
      _themeMode = AppThemeMode.system; // 기본값
    }
  }
}

final ThemeController themeController = ThemeController();
