import '../entities/theme_preference.dart';
import 'set_theme.dart';

class CycleTheme {
  const CycleTheme({required SetTheme setTheme}) : _setTheme = setTheme;

  final SetTheme _setTheme;

  Future<ThemePreference> call(ThemePreference currentTheme) async {
    final nextTheme = currentTheme.next;
    await _setTheme(nextTheme);
    return nextTheme;
  }
}
