import '../entities/theme_preference.dart';
import '../repositories/theme_repository.dart';

class LoadTheme {
  const LoadTheme(this._themeRepository);

  final ThemeRepository _themeRepository;

  Future<ThemePreference> call() {
    return _themeRepository.loadTheme();
  }
}
