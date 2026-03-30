import 'package:alex_super_app/features/theme/domain/entities/theme_preference.dart';

abstract interface class ThemeRepository {
  Future<ThemePreference> loadTheme();

  Future<void> saveTheme(ThemePreference theme);
}
