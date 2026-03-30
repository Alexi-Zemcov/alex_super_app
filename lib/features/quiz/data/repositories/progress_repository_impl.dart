import '../../domain/entities/question_stats.dart';
import '../../domain/entities/quiz_question.dart';
import '../../domain/repositories/progress_repository.dart';
import '../datasources/progress_local_data_source.dart';

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
