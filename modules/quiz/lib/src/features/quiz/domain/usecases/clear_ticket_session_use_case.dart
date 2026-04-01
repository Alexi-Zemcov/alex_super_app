import 'package:quiz/src/features/quiz/domain/repositories/progress_repository.dart';

class ClearTicketSessionUseCase {
  const ClearTicketSessionUseCase({
    required ProgressRepository progressRepository,
  }) : _progressRepository = progressRepository;

  final ProgressRepository _progressRepository;

  Future<void> call() {
    return _progressRepository.clearTicketSession();
  }
}
