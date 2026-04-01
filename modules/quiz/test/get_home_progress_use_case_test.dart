import 'package:flutter_test/flutter_test.dart';
import 'package:quiz/src/features/home/domain/usecases/get_home_progress_use_case.dart';
import 'package:quiz/src/features/quiz/domain/entities/question_stats.dart';

import 'test_support.dart';

void main() {
  test(
    'counts progress only when there is at least one correct attempt',
    () async {
      final questions = [
        buildQuestion(category: 'A', question: 'Q1'),
        buildQuestion(category: 'A', question: 'Q2'),
        buildQuestion(category: 'B', question: 'Q3'),
      ];
      final questionRepository = InMemoryQuestionRepository(
        questions: questions,
      );
      final progressRepository = InMemoryProgressRepository(
        questionStats: {
          questions[0].key: const QuestionStats(
            correctAttempts: 1,
            totalAttempts: 1,
          ),
          questions[1].key: const QuestionStats(
            correctAttempts: 0,
            totalAttempts: 3,
          ),
        },
      );
      final useCase = GetHomeProgressUseCase(
        questionRepository: questionRepository,
        progressRepository: progressRepository,
      );

      final progress = await useCase();

      expect(progress.completedQuestions, 1);
      expect(progress.totalQuestions, 3);
      expect(progress.completedTickets, 0);
      expect(progress.totalTickets, 1);
      expect(progress.completedTopics, 0);
      expect(progress.totalTopics, 2);
    },
  );
}
