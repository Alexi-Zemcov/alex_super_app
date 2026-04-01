import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:quiz/src/features/quiz/data/datasources/progress_local_data_source.dart';
import 'package:quiz/src/features/quiz/data/repositories/progress_repository_impl.dart';
import 'package:quiz/src/features/quiz/domain/entities/quiz_answer.dart';
import 'package:quiz/src/features/quiz/domain/entities/quiz_mode.dart';
import 'package:quiz/src/features/quiz/domain/entities/quiz_session.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'test_support.dart';

void main() {
  group('ProgressRepositoryImpl', () {
    late SharedPreferences sharedPreferences;
    late ProgressRepositoryImpl repository;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      sharedPreferences = await SharedPreferences.getInstance();
      repository = ProgressRepositoryImpl(
        localDataSource: SharedPreferencesProgressLocalDataSource(
          sharedPreferences: sharedPreferences,
        ),
      );
    });

    test('stores stats and favorites with web-compatible keys', () async {
      final question = buildQuestion(category: 'A', question: 'Q1');

      await repository.recordAnswer(
        QuizAnswer(
          questionKey: question.key,
          category: question.category,
          selectedIndex: 0,
          isCorrect: true,
        ),
      );
      await repository.toggleFavorite(question.key);

      final rawStats =
          jsonDecode(
                sharedPreferences.getString(
                  SharedPreferencesProgressLocalDataSource.storageKey,
                )!,
              )
              as Map<String, dynamic>;
      final rawFavorites =
          jsonDecode(
                sharedPreferences.getString(
                  SharedPreferencesProgressLocalDataSource.favoritesStorageKey,
                )!,
              )
              as List<dynamic>;

      expect(rawStats[question.key], {'correct': 1, 'total': 1});
      expect(rawFavorites, [question.key]);
    });

    test('saves and restores a partial ticket session', () async {
      final questions = [
        buildQuestion(category: 'A', question: 'Q1'),
        buildQuestion(category: 'A', question: 'Q2'),
      ];
      final session = QuizSession(
        mode: QuizMode.ticket,
        context: const {QuizSession.ticketIdContextKey: 1},
        currentQuestions: questions,
        answers: [
          QuizAnswer(
            questionKey: questions[0].key,
            category: questions[0].category,
            selectedIndex: 0,
            isCorrect: true,
          ),
          null,
        ],
        currentIndex: 0,
      );

      await repository.saveTicketSession(session);
      final restoredSession = await repository.loadTicketSession(1);

      expect(restoredSession, session);
    });

    test('clears stats only for the requested questions', () async {
      final firstQuestion = buildQuestion(category: 'A', question: 'Q1');
      final secondQuestion = buildQuestion(category: 'A', question: 'Q2');

      await repository.recordAnswer(
        QuizAnswer(
          questionKey: firstQuestion.key,
          category: firstQuestion.category,
          selectedIndex: 0,
          isCorrect: true,
        ),
      );
      await repository.recordAnswer(
        QuizAnswer(
          questionKey: secondQuestion.key,
          category: secondQuestion.category,
          selectedIndex: 1,
          isCorrect: false,
        ),
      );

      await repository.clearStatsForQuestions([firstQuestion.key]);

      final stats = await repository.getQuestionStats();
      expect(stats.containsKey(firstQuestion.key), isFalse);
      expect(stats.containsKey(secondQuestion.key), isTrue);
    });
  });
}
