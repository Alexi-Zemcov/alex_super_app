import 'package:app_theme/app_theme.dart';
import 'package:circle_of_fifths/circle_of_fifths.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:scoped_di/scoped_di.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:circle_of_fifths_app/src/di/circle_of_fifths_app_scope_module.dart';
import 'package:circle_of_fifths_app/src/navigation/circle_of_fifths_app_router.dart';

class CircleOfFifthsApp extends StatelessWidget {
  CircleOfFifthsApp({
    required this.sharedPreferences,
    required this.themeController,
    this.initialLocation,
    super.key,
  }) : _router = buildCircleOfFifthsAppRouter(initialLocation: initialLocation);

  final SharedPreferences sharedPreferences;
  final AppThemeController themeController;
  final String? initialLocation;
  final GoRouter _router;

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
          return MaterialApp.router(
            title: circleOfFifthsModule.title,
            debugShowCheckedModeBanner: false,
            theme: controller.themeData,
            routerConfig: _router,
          );
        },
      ),
    );
  }
}
