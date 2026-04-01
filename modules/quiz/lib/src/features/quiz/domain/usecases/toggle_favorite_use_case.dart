import 'package:quiz/src/features/quiz/domain/entities/quiz_question.dart';
import 'package:quiz/src/features/quiz/domain/repositories/progress_repository.dart';

class ToggleFavoriteUseCase {
  const ToggleFavoriteUseCase({required ProgressRepository progressRepository})
    : _progressRepository = progressRepository;

  final ProgressRepository _progressRepository;

  Future<bool> call(QuestionKey questionKey) {
    return _progressRepository.toggleFavorite(questionKey);
  }
}
