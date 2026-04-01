import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:quiz/src/features/quiz/domain/entities/question_stats.dart';
import 'package:quiz/src/features/quiz/domain/entities/quiz_answer.dart';
import 'package:quiz/src/features/quiz/domain/entities/quiz_mode.dart';
import 'package:quiz/src/features/quiz/domain/entities/quiz_question.dart';
import 'package:quiz/src/features/quiz/domain/entities/quiz_session.dart';
import 'package:quiz/src/features/quiz/domain/entities/quiz_start_behavior.dart';
import 'package:quiz/src/features/quiz/domain/entities/quiz_start_request.dart';
import 'package:quiz/src/features/quiz/domain/services/quiz_question_randomizer.dart';
import 'package:quiz/src/features/quiz/domain/services/quiz_session_navigator.dart';
import 'package:quiz/src/features/quiz/domain/usecases/start_quiz_flow_use_case.dart';

import 'test_support.dart';

void main() {
  group('StartQuizFlowUseCase', () {
    late List<QuizQuestion> questions;
    late InMemoryQuestionRepository questionRepository;
    late InMemoryProgressRepository progressRepository;
    late StartQuizFlowUseCase useCase;

    setUp(() {
      questions = [
        buildQuestion(category: 'A', question: 'Q1'),
        buildQuestion(category: 'A', question: 'Q2'),
      ];
      questionRepository = InMemoryQuestionRepository(questions: questions);
      progressRepository = InMemoryProgressRepository(
        questionStats: {
          questions[0].key: const QuestionStats(
            correctAttempts: 1,
            totalAttempts: 1,
          ),
        },
      );
      useCase = StartQuizFlowUseCase(
        questionRepository: questionRepository,
        progressRepository: progressRepository,
        questionRandomizer: QuizQuestionRandomizer(random: Random(0)),
        sessionNavigator: const QuizSessionNavigator(),
      );
    });

    test('resumes a saved partial ticket session', () async {
      progressRepository.ticketSession = QuizSession(
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

      final session = await useCase(
        const QuizStartRequest(
          mode: QuizMode.ticket,
          ticketId: 1,
          startBehavior: QuizStartBehavior.resume,
        ),
      );

      expect(session.currentIndex, 1);
      expect(session.answers.whereType<QuizAnswer>(), hasLength(1));
    });

    test('restartWithReset clears ticket session and ticket stats', () async {
      final session = await useCase(
        const QuizStartRequest(
          mode: QuizMode.ticket,
          ticketId: 1,
          startBehavior: QuizStartBehavior.restartWithReset,
        ),
      );

      expect(progressRepository.clearTicketSessionCalls, 1);
      expect(progressRepository.clearedStatsBatches.single, [
        questions[0].key,
        questions[1].key,
      ]);
      expect(progressRepository.questionStats, isEmpty);
      expect(session.answers, everyElement(isNull));
    });

    test('fresh ticket start keeps accumulated stats intact', () async {
      await useCase(const QuizStartRequest(mode: QuizMode.ticket, ticketId: 1));

      expect(progressRepository.clearTicketSessionCalls, 0);
      expect(progressRepository.questionStats.keys, contains(questions[0].key));
    });
  });
}
