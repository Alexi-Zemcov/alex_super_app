import '../entities/theme_preference.dart';

abstract interface class ThemeRepository {
  Future<ThemePreference> loadTheme();

  Future<void> saveTheme(ThemePreference theme);
}
