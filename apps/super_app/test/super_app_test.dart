import 'package:app_theme/app_theme.dart';
import 'package:circle_of_fifths/src/core/audio/audio_playback_service.dart';
import 'package:circle_of_fifths/src/features/circle/domain/entities/chord.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:module_contracts/module_contracts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_app/src/app.dart';

void main() {
  testWidgets('shows the module catalog, toggles theme, and opens a module', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();
    final themeController = AppThemeController();
    final fakeModule = AppModuleDescriptor(
      id: 'quiz',
      title: 'Quiz',
      description: 'Fake module for the dashboard test.',
      icon: Icons.quiz_rounded,
      entryLocation: '/quiz',
      rootRoute: GoRoute(
        path: '/quiz',
        builder: (context, state) {
          return const Scaffold(body: Center(child: Text('Fake module page')));
        },
      ),
    );

    await tester.pumpWidget(
      SuperApp(
        sharedPreferences: sharedPreferences,
        themeController: themeController,
        modules: [fakeModule],
      ),
    );

    expect(find.text('Quiz'), findsOneWidget);

    await tester.tap(find.text('🌕'));
    await tester.pumpAndSettle();
    expect(themeController.themePreference, ThemePreference.white);

    await tester.tap(find.text('Открыть'));
    await tester.pumpAndSettle();
    expect(find.text('Fake module page'), findsOneWidget);
  });

  testWidgets('starts directly on /quiz and renders the quiz home route', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();
    final themeController = AppThemeController();

    await tester.pumpWidget(
      SuperApp(
        sharedPreferences: sharedPreferences,
        themeController: themeController,
        assetBundle: _ThreeQuestionQuizAssetBundle(),
        initialLocation: '/quiz',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Flutter Quiz'), findsOneWidget);
    expect(find.text('Каталог модулей'), findsNothing);
  });

  testWidgets('starts directly on /quiz/topics and renders the topics route', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();
    final themeController = AppThemeController();

    await tester.pumpWidget(
      SuperApp(
        sharedPreferences: sharedPreferences,
        themeController: themeController,
        assetBundle: _ThreeQuestionQuizAssetBundle(),
        initialLocation: '/quiz/topics',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Вопросы по темам'), findsOneWidget);
    expect(find.text('Тренировка по темам'), findsOneWidget);
  });

  testWidgets(
    'starts directly on /circle/settings after module bootstrap finishes',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final sharedPreferences = await SharedPreferences.getInstance();
      final themeController = AppThemeController();

      await tester.pumpWidget(
        Provider<AudioPlaybackService>.value(
          value: _FakeAudioPlaybackService(),
          child: SuperApp(
            sharedPreferences: sharedPreferences,
            themeController: themeController,
            initialLocation: '/circle/settings',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);
    },
  );

  testWidgets('shows router-level 404 for unknown locations', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();
    final themeController = AppThemeController();

    await tester.pumpWidget(
      SuperApp(
        sharedPreferences: sharedPreferences,
        themeController: themeController,
        initialLocation: '/missing',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Маршрут не найден'), findsOneWidget);
    expect(find.text('Не удалось открыть /missing.'), findsOneWidget);
  });
}

class _ThreeQuestionQuizAssetBundle extends CachingAssetBundle {
  static const _questionsKey = 'packages/quiz/assets/data/questions.json';
  static const _questionsJson = '''
[
  {
    "category": "Basics",
    "question": "Question A",
    "options": ["A", "B", "C", "D"],
    "correct": 0,
    "explanation": "Explanation A"
  },
  {
    "category": "Layout",
    "question": "Question B",
    "options": ["A", "B", "C", "D"],
    "correct": 1,
    "explanation": "Explanation B"
  },
  {
    "category": "State",
    "question": "Question C",
    "options": ["A", "B", "C", "D"],
    "correct": 2,
    "explanation": "Explanation C"
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

class _FakeAudioPlaybackService implements AudioPlaybackService {
  @override
  bool get isMuted => false;

  @override
  double get masterVolume => 0.7;

  @override
  Future<void> dispose() async {}

  @override
  Future<void> initialize() async {}

  @override
  Future<void> playChord(Chord chord) async {}

  @override
  void setMasterVolume(double volume) {}

  @override
  void setMutedAndStopAll(bool value) {}

  @override
  Future<void> stopAll() async {}

  @override
  void stopChord(Chord chord) {}
}
