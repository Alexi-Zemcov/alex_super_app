import 'package:app_theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:quiz/quiz.dart';
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
    return MultiProvider(
      providers: [
        Provider<AssetBundle>.value(value: assetBundle),
        Provider<SharedPreferences>.value(value: sharedPreferences),
        ChangeNotifierProvider<AppThemeController>.value(value: themeController),
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
