import 'package:app_theme/src/app_theme_factory.dart';
import 'package:app_theme/src/theme_preference.dart';
import 'package:flutter/material.dart';

class AppThemeController extends ChangeNotifier {
  AppThemeController({ThemePreference initialTheme = ThemePreference.dark})
    : _themePreference = initialTheme;

  ThemePreference _themePreference;

  ThemePreference get themePreference => _themePreference;

  ThemeData get themeData => AppThemeFactory.fromPreference(_themePreference);

  void setTheme(ThemePreference themePreference) {
    if (_themePreference == themePreference) {
      return;
    }

    _themePreference = themePreference;
    notifyListeners();
  }

  void cycleTheme() {
    setTheme(_themePreference.next);
  }
}
