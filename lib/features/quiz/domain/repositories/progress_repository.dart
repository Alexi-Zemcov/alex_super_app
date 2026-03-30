import '../entities/question_stats.dart';
import '../entities/quiz_question.dart';

abstract interface class ProgressRepository {
  Future<Map<QuestionKey, QuestionStats>> getQuestionStats();
}
