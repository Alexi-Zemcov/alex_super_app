import 'package:app_theme/app_theme.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz/quiz_assets.dart';
import 'package:quiz_app/src/app.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('starts on the quiz home screen and toggles theme', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();
    final themeController = AppThemeController();
    final assetBundle = _SingleQuestionQuizAssetBundle();

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

  testWidgets('redirects / to /quiz', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();
    final themeController = AppThemeController();

    await tester.pumpWidget(
      QuizApp(
        sharedPreferences: sharedPreferences,
        themeController: themeController,
        assetBundle: _SingleQuestionQuizAssetBundle(),
        initialLocation: '/',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Flutter Quiz'), findsOneWidget);
  });

  testWidgets('opens ticket flow from /quiz/tickets/1', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();
    final themeController = AppThemeController();

    await tester.pumpWidget(
      QuizApp(
        sharedPreferences: sharedPreferences,
        themeController: themeController,
        assetBundle: _SingleQuestionQuizAssetBundle(),
        initialLocation: '/quiz/tickets/1',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Question Ticket'), findsOneWidget);
  });

  testWidgets('opens topic flow from /quiz/topics/3', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();
    final themeController = AppThemeController();

    await tester.pumpWidget(
      QuizApp(
        sharedPreferences: sharedPreferences,
        themeController: themeController,
        assetBundle: _ThreeQuestionQuizAssetBundle(),
        initialLocation: '/quiz/topics/3',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Question Topic 3'), findsOneWidget);
  });

  testWidgets('opens errors overview from /quiz/errors', (tester) async {
    SharedPreferences.setMockInitialValues({
      'flutterQuizStats': '{"Errors|Question Error":{"correct":0,"total":1}}',
    });
    final sharedPreferences = await SharedPreferences.getInstance();
    final themeController = AppThemeController();

    await tester.pumpWidget(
      QuizApp(
        sharedPreferences: sharedPreferences,
        themeController: themeController,
        assetBundle: _ErrorsQuizAssetBundle(),
        initialLocation: '/quiz/errors',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Работа над ошибками'), findsOneWidget);
  });

  testWidgets('opens errors flow from /quiz/errors/run', (tester) async {
    SharedPreferences.setMockInitialValues({
      'flutterQuizStats': '{"Errors|Question Error":{"correct":0,"total":1}}',
    });
    final sharedPreferences = await SharedPreferences.getInstance();
    final themeController = AppThemeController();

    await tester.pumpWidget(
      QuizApp(
        sharedPreferences: sharedPreferences,
        themeController: themeController,
        assetBundle: _ErrorsQuizAssetBundle(),
        initialLocation: '/quiz/errors/run',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Question Error'), findsOneWidget);
  });

  testWidgets('opens blitz flow from /quiz/blitz', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();
    final themeController = AppThemeController();

    await tester.pumpWidget(
      QuizApp(
        sharedPreferences: sharedPreferences,
        themeController: themeController,
        assetBundle: _SingleQuestionQuizAssetBundle(),
        initialLocation: '/quiz/blitz',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Question Ticket'), findsOneWidget);
  });
}

class _SingleQuestionQuizAssetBundle extends CachingAssetBundle {
  static const _questionsKey = QuizPackageAssets.questions;
  static const _questionsJson = '''
[
  {
    "category": "Ticket",
    "question": "Question Ticket",
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

class _ThreeQuestionQuizAssetBundle extends CachingAssetBundle {
  static const _questionsKey = QuizPackageAssets.questions;
  static const _questionsJson = '''
[
  {
    "category": "Topic 1",
    "question": "Question Topic 1",
    "options": ["A", "B", "C", "D"],
    "correct": 0,
    "explanation": "Explanation 1"
  },
  {
    "category": "Topic 2",
    "question": "Question Topic 2",
    "options": ["A", "B", "C", "D"],
    "correct": 1,
    "explanation": "Explanation 2"
  },
  {
    "category": "Topic 3",
    "question": "Question Topic 3",
    "options": ["A", "B", "C", "D"],
    "correct": 2,
    "explanation": "Explanation 3"
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

class _ErrorsQuizAssetBundle extends CachingAssetBundle {
  static const _questionsKey = QuizPackageAssets.questions;
  static const _questionsJson = '''
[
  {
    "category": "Errors",
    "question": "Question Error",
    "options": ["A", "B", "C", "D"],
    "correct": 0,
    "explanation": "Explanation Error"
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
