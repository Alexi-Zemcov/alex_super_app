import 'package:alex_super_app/features/quiz/data/datasources/progress_local_data_source.dart';
import 'package:alex_super_app/features/quiz/domain/entities/question_stats.dart';
import 'package:alex_super_app/features/quiz/domain/entities/quiz_question.dart';
import 'package:alex_super_app/features/quiz/domain/repositories/progress_repository.dart';

class ProgressRepositoryImpl implements ProgressRepository {
  ProgressRepositoryImpl({required ProgressLocalDataSource localDataSource})
    : _localDataSource = localDataSource;

  final ProgressLocalDataSource _localDataSource;

  @override
  Future<Map<QuestionKey, QuestionStats>> getQuestionStats() async {
    final rawStats = await _localDataSource.loadQuestionStats();
    return rawStats.map(
      (key, value) => MapEntry(key, QuestionStats.fromStorageMap(value)),
    );
  }
}
