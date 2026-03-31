import 'package:quiz/src/features/quiz/domain/entities/question_stats.dart';
import 'package:quiz/src/features/quiz/domain/entities/quiz_question.dart';

abstract interface class ProgressRepository {
  Future<Map<QuestionKey, QuestionStats>> getQuestionStats();
}
