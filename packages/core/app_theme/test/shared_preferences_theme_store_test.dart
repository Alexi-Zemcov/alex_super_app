import 'package:app_theme/app_theme.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('loads dark by default', () async {
    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();
    final store = SharedPreferencesThemeStore(
      sharedPreferences: sharedPreferences,
    );

    expect(store.loadTheme(), ThemePreference.dark);
  });

  test('saves and loads the selected theme', () async {
    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();
    final store = SharedPreferencesThemeStore(
      sharedPreferences: sharedPreferences,
    );

    await store.saveTheme(ThemePreference.black);

    expect(store.loadTheme(), ThemePreference.black);
  });
}
