import 'package:alex_super_app/features/quiz/domain/entities/question_stats.dart';
import 'package:alex_super_app/features/quiz/domain/entities/quiz_question.dart';

abstract interface class ProgressRepository {
  Future<Map<QuestionKey, QuestionStats>> getQuestionStats();
}
