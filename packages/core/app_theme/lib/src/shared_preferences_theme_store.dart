import 'package:app_theme/src/parse_theme_preference.dart';
import 'package:app_theme/src/theme_preference.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesThemeStore {
  SharedPreferencesThemeStore({required SharedPreferences sharedPreferences})
    : _sharedPreferences = sharedPreferences;

  static const storageKey = 'flutterQuizTheme';

  final SharedPreferences _sharedPreferences;

  ThemePreference loadTheme() {
    final rawTheme = _sharedPreferences.getString(storageKey);
    return parseThemePreference(rawTheme);
  }

  Future<void> saveTheme(ThemePreference themePreference) {
    return _sharedPreferences.setString(
      storageKey,
      themePreference.storageValue,
    );
  }
}
