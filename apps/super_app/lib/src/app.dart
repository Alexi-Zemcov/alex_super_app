import 'package:app_theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:module_contracts/module_contracts.dart';
import 'package:provider/provider.dart';
import 'package:quiz/quiz.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_app/src/shell/dashboard_page.dart';

class SuperApp extends StatelessWidget {
  SuperApp({
    required this.sharedPreferences,
    required this.themeController,
    List<AppModuleDescriptor>? modules,
    super.key,
  }) : modules = modules ?? [quizModule];

  final SharedPreferences sharedPreferences;
  final AppThemeController themeController;
  final List<AppModuleDescriptor> modules;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AssetBundle>.value(value: rootBundle),
        Provider<SharedPreferences>.value(value: sharedPreferences),
        ChangeNotifierProvider<AppThemeController>.value(value: themeController),
      ],
      child: Consumer<AppThemeController>(
        builder: (context, controller, child) {
          return MaterialApp(
            title: 'Alex Super App',
            debugShowCheckedModeBanner: false,
            theme: controller.themeData,
            home: DashboardPage(modules: modules),
          );
        },
      ),
    );
  }
}
