import 'package:alex_super_app/features/theme/domain/entities/theme_preference.dart';
import 'package:alex_super_app/features/theme/domain/repositories/theme_repository.dart';

class LoadThemeUseCase {
  const LoadThemeUseCase(this._themeRepository);

  final ThemeRepository _themeRepository;

  Future<ThemePreference> call() {
    return _themeRepository.loadTheme();
  }
}
