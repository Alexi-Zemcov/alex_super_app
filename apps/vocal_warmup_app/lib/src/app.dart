import 'package:app_theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:scoped_di/scoped_di.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vocal_warmup/vocal_warmup.dart';
import 'package:vocal_warmup_app/src/di/vocal_warmup_app_scope_module.dart';
import 'package:vocal_warmup_app/src/navigation/vocal_warmup_app_router.dart';

class VocalWarmupApp extends StatelessWidget {
  VocalWarmupApp({
    required this.sharedPreferences,
    required this.themeController,
    this.initialLocation,
    super.key,
  }) : _router = buildVocalWarmupAppRouter(initialLocation: initialLocation);

  final SharedPreferences sharedPreferences;
  final AppThemeController themeController;
  final String? initialLocation;
  final GoRouter _router;

  @override
  Widget build(BuildContext context) {
    return FeatureScope(
      modules: [
        VocalWarmupAppScopeModule(
          sharedPreferences: sharedPreferences,
          themeController: themeController,
        ),
      ],
      child: Consumer<AppThemeController>(
        builder: (context, controller, child) {
          return MaterialApp.router(
            title: vocalWarmupModule.title,
            debugShowCheckedModeBanner: false,
            theme: controller.themeData,
            routerConfig: _router,
          );
        },
      ),
    );
  }
}
