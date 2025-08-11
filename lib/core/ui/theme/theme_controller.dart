import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode { light, dark }

class ThemeController extends ChangeNotifier {
  static const _themePrefKey = 'appThemeMode';
  AppThemeMode _themeMode = AppThemeMode.light;

  AppThemeMode get themeMode => _themeMode;

  ThemeMode get flutterThemeMode =>
      _themeMode == AppThemeMode.light ? ThemeMode.light : ThemeMode.dark;

  ThemeController() {
    _loadThemeFromPrefs();
  }

  void toggleTheme() {
    _themeMode =
    _themeMode == AppThemeMode.light ? AppThemeMode.dark : AppThemeMode.light;
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
}

// 전역 인스턴스 (main.dart 등에서 import 후 사용)
final ThemeController themeController = ThemeController();

