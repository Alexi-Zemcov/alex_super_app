import 'package:alex_super_app/features/theme/domain/entities/theme_preference.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract interface class ThemeLocalDataSource {
  Future<ThemePreference> loadTheme();

  Future<void> saveTheme(ThemePreference theme);
}

class SharedPreferencesThemeLocalDataSource implements ThemeLocalDataSource {
  SharedPreferencesThemeLocalDataSource({
    required SharedPreferences sharedPreferences,
  }) : _sharedPreferences = sharedPreferences;

  static const storageKey = 'flutterQuizTheme';

  final SharedPreferences _sharedPreferences;

  @override
  Future<ThemePreference> loadTheme() async {
    final rawTheme = _sharedPreferences.getString(storageKey);
    return parseThemePreference(rawTheme);
  }

  @override
  Future<void> saveTheme(ThemePreference theme) async {
    await _sharedPreferences.setString(storageKey, theme.storageValue);
  }
}
