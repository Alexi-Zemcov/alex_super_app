import 'package:app_theme/app_theme.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('cycles through all supported themes', () {
    final controller = AppThemeController();

    expect(controller.themePreference, ThemePreference.dark);

    controller.cycleTheme();
    expect(controller.themePreference, ThemePreference.white);

    controller.cycleTheme();
    expect(controller.themePreference, ThemePreference.black);

    controller.cycleTheme();
    expect(controller.themePreference, ThemePreference.dark);
  });
}
