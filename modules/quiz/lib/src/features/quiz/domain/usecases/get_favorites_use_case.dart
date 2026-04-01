import 'package:quiz/src/features/quiz/domain/entities/quiz_question.dart';
import 'package:quiz/src/features/quiz/domain/repositories/progress_repository.dart';

class GetFavoritesUseCase {
  const GetFavoritesUseCase({required ProgressRepository progressRepository})
    : _progressRepository = progressRepository;

  final ProgressRepository _progressRepository;

  Future<Set<QuestionKey>> call() {
    return _progressRepository.getFavorites();
  }
}
