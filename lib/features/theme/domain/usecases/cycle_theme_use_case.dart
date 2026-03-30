import 'package:alex_super_app/features/theme/domain/entities/theme_preference.dart';
import 'package:alex_super_app/features/theme/domain/usecases/set_theme_use_case.dart';

class CycleThemeUseCase {
  const CycleThemeUseCase({required SetThemeUseCase setTheme}) : _setTheme = setTheme;

  final SetThemeUseCase _setTheme;

  Future<ThemePreference> call(ThemePreference currentTheme) async {
    final nextTheme = currentTheme.next;
    await _setTheme(nextTheme);
    return nextTheme;
  }
}
