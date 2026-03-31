import 'package:app_theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:quiz/quiz.dart';
import 'package:quiz_app/src/di/quiz_app_scope_module.dart';
import 'package:scoped_di/scoped_di.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuizApp extends StatelessWidget {
  QuizApp({
    required this.sharedPreferences,
    required this.themeController,
    AssetBundle? assetBundle,
    super.key,
  }) : assetBundle = assetBundle ?? rootBundle;

  final SharedPreferences sharedPreferences;
  final AppThemeController themeController;
  final AssetBundle assetBundle;

  @override
  Widget build(BuildContext context) {
    return FeatureScope(
      modules: [
        QuizAppScopeModule(
          sharedPreferences: sharedPreferences,
          themeController: themeController,
          assetBundle: assetBundle,
        ),
      ],
      child: Consumer<AppThemeController>(
        builder: (context, controller, child) {
          return MaterialApp(
            title: quizModule.title,
            debugShowCheckedModeBanner: false,
            theme: controller.themeData,
            home: Builder(builder: quizModule.rootPageBuilder),
          );
        },
      ),
    );
  }
}
