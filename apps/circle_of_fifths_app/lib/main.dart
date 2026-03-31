import 'dart:async';

import 'package:app_theme/app_theme.dart';
import 'package:circle_of_fifths_app/src/app.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final sharedPreferences = await SharedPreferences.getInstance();
  final themeStore = SharedPreferencesThemeStore(
    sharedPreferences: sharedPreferences,
  );
  final themeController = AppThemeController(
    initialTheme: themeStore.loadTheme(),
  );

  themeController.addListener(() {
    unawaited(themeStore.saveTheme(themeController.themePreference));
  });

  runApp(
    CircleOfFifthsApp(
      sharedPreferences: sharedPreferences,
      themeController: themeController,
    ),
  );
}
