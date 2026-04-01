import 'package:app_theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:quiz/quiz.dart';
import 'package:scoped_di/scoped_di.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('reloads home progress after returning from a child route', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();
    final themeController = AppThemeController();

    await tester.pumpWidget(
      _QuizTestApp(
        sharedPreferences: sharedPreferences,
        themeController: themeController,
        assetBundle: _TestQuizAssetBundle(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('0 / 2'), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.byType(GridView),
        matching: find.text('Билеты'),
      ),
    );
    await tester.pumpAndSettle();

    await sharedPreferences.setString(
      'flutterQuizStats',
      '{"Core|Question 1":{"correct":1,"total":1}}',
    );

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('1 / 2'), findsOneWidget);
  });
}

class _QuizTestApp extends StatelessWidget {
  const _QuizTestApp({
    required this.sharedPreferences,
    required this.themeController,
    required this.assetBundle,
  });

  final SharedPreferences sharedPreferences;
  final AppThemeController themeController;
  final AssetBundle assetBundle;

  @override
  Widget build(BuildContext context) {
    return FeatureScope(
      modules: [
        _QuizTestScopeModule(
          sharedPreferences: sharedPreferences,
          themeController: themeController,
          assetBundle: assetBundle,
        ),
      ],
      child: Consumer<AppThemeController>(
        builder: (context, controller, child) {
          return MaterialApp(
            theme: controller.themeData,
            home: Builder(builder: quizModule.rootPageBuilder),
          );
        },
      ),
    );
  }
}

class _QuizTestScopeModule extends ScopeModule {
  _QuizTestScopeModule({
    required this.sharedPreferences,
    required this.themeController,
    required this.assetBundle,
  });

  final SharedPreferences sharedPreferences;
  final AppThemeController themeController;
  final AssetBundle assetBundle;

  @override
  List<SingleChildWidget> get providers => [
    Provider<AssetBundle>.value(value: assetBundle),
    Provider<SharedPreferences>.value(value: sharedPreferences),
    ChangeNotifierProvider<AppThemeController>.value(value: themeController),
  ];
}

class _TestQuizAssetBundle extends CachingAssetBundle {
  static const _questionsKey = 'packages/quiz/assets/data/questions.json';
  static const _questionsJson = '''
[
  {
    "category": "Core",
    "question": "Question 1",
    "options": ["A", "B", "C", "D"],
    "correct": 0,
    "explanation": "Explanation 1"
  },
  {
    "category": "Core",
    "question": "Question 2",
    "options": ["A", "B", "C", "D"],
    "correct": 1,
    "explanation": "Explanation 2"
  }
]
''';

  @override
  Future<ByteData> load(String key) {
    throw StateError('Unexpected asset request: $key');
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    if (key == _questionsKey) {
      return _questionsJson;
    }

    throw StateError('Unexpected asset request: $key');
  }
}
