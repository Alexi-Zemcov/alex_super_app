import 'package:app_theme/app_theme.dart';
import 'package:circle_of_fifths/circle_of_fifths.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scoped_di/scoped_di.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:circle_of_fifths_app/src/di/circle_of_fifths_app_scope_module.dart';

class CircleOfFifthsApp extends StatelessWidget {
  const CircleOfFifthsApp({
    required this.sharedPreferences,
    required this.themeController,
    super.key,
  });

  final SharedPreferences sharedPreferences;
  final AppThemeController themeController;

  @override
  Widget build(BuildContext context) {
    return FeatureScope(
      modules: [
        CircleOfFifthsAppScopeModule(
          sharedPreferences: sharedPreferences,
          themeController: themeController,
        ),
      ],
      child: Consumer<AppThemeController>(
        builder: (context, controller, child) {
          return MaterialApp(
            title: circleOfFifthsModule.title,
            debugShowCheckedModeBanner: false,
            theme: controller.themeData,
            home: Builder(builder: circleOfFifthsModule.rootPageBuilder),
          );
        },
      ),
    );
  }
}
