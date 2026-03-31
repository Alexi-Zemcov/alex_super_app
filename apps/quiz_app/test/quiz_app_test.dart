import 'package:app_theme/app_theme.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_app/src/app.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('starts on the quiz home screen and toggles theme', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();
    final themeController = AppThemeController();
    final assetBundle = _TestQuizAssetBundle();

    await tester.pumpWidget(
      QuizApp(
        sharedPreferences: sharedPreferences,
        themeController: themeController,
        assetBundle: assetBundle,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Flutter Quiz'), findsOneWidget);
    expect(find.text('Билеты'), findsWidgets);
    expect(find.text('Каталог модулей'), findsNothing);

    await tester.tap(find.text('🌕'));
    await tester.pump();

    expect(themeController.themePreference, ThemePreference.white);
  });
}

class _TestQuizAssetBundle extends CachingAssetBundle {
  static const _questionsKey = 'packages/quiz/assets/data/questions.json';
  static const _questionsJson = '''
[
  {
    "category": "Basics",
    "question": "What is Flutter?",
    "options": ["SDK", "IDE", "OS", "Database"],
    "correct": 0,
    "explanation": "Flutter is a UI SDK."
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
