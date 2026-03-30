import '../entities/theme_preference.dart';
import '../repositories/theme_repository.dart';

class SetTheme {
  const SetTheme(this._themeRepository);

  final ThemeRepository _themeRepository;

  Future<void> call(ThemePreference theme) {
    return _themeRepository.saveTheme(theme);
  }
}
