import 'package:quiz/src/features/quiz/domain/entities/quiz_answer.dart';
import 'package:quiz/src/features/quiz/domain/entities/quiz_result.dart';
import 'package:quiz/src/features/quiz/domain/entities/quiz_session.dart';

class QuizResultBuilder {
  const QuizResultBuilder();

  QuizResult build(QuizSession session) {
    final answers = session.answers.whereType<QuizAnswer>().toList(
      growable: false,
    );
    final correctCount = answers.where((answer) => answer.isCorrect).length;
    final categories = <String, _CategoryAccumulator>{};

    for (final answer in answers) {
      final accumulator = categories.putIfAbsent(
        answer.category,
        _CategoryAccumulator.new,
      );
      accumulator.totalCount += 1;
      if (answer.isCorrect) {
        accumulator.correctCount += 1;
      }
    }

    return QuizResult(
      correctCount: correctCount,
      totalCount: answers.length,
      categoryResults: List<QuizCategoryResult>.unmodifiable(
        categories.entries.map(
          (entry) => QuizCategoryResult(
            category: entry.key,
            correctCount: entry.value.correctCount,
            totalCount: entry.value.totalCount,
          ),
        ),
      ),
    );
  }
}

class _CategoryAccumulator {
  int correctCount = 0;
  int totalCount = 0;
}
