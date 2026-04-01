import 'package:app_theme/app_theme.dart';
import 'package:circle_of_fifths/circle_of_fifths.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:module_contracts/module_contracts.dart';
import 'package:provider/provider.dart';
import 'package:quiz/quiz.dart';
import 'package:scoped_di/scoped_di.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_app/src/di/super_app_scope_module.dart';
import 'package:super_app/src/navigation/super_app_router.dart';

class SuperApp extends StatelessWidget {
  SuperApp({
    required this.sharedPreferences,
    required this.themeController,
    this.assetBundle,
    this.initialLocation,
    List<AppModuleDescriptor>? modules,
    super.key,
  }) : modules = modules ?? [quizModule, circleOfFifthsModule],
       _router = buildSuperAppRouter(
         moduleRoutes: (modules ?? [quizModule, circleOfFifthsModule])
             .map((module) => module.rootRoute)
             .toList(growable: false),
         initialLocation: initialLocation,
       );

  final SharedPreferences sharedPreferences;
  final AppThemeController themeController;
  final AssetBundle? assetBundle;
  final String? initialLocation;
  final List<AppModuleDescriptor> modules;
  final GoRouter _router;

  @override
  Widget build(BuildContext context) {
    return FeatureScope(
      modules: [
        SuperAppScopeModule(
          sharedPreferences: sharedPreferences,
          themeController: themeController,
          assetBundle: assetBundle,
        ),
      ],
      child: Provider<List<AppModuleDescriptor>>.value(
        value: modules,
        child: Consumer<AppThemeController>(
          builder: (context, controller, child) {
            return MaterialApp.router(
              title: 'Alex Super App',
              debugShowCheckedModeBanner: false,
              theme: controller.themeData,
              routerConfig: _router,
            );
          },
        ),
      ),
    );
  }
}
