import 'package:alex_super_app/features/theme/domain/entities/theme_preference.dart';
import 'package:alex_super_app/features/theme/domain/repositories/theme_repository.dart';

class SetThemeUseCase {
  const SetThemeUseCase(this._themeRepository);

  final ThemeRepository _themeRepository;

  Future<void> call(ThemePreference theme) {
    return _themeRepository.saveTheme(theme);
  }
}
