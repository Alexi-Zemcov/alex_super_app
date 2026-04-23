import 'package:vocal_warmup/src/features/range_detection/domain/entities/vocal_range.dart';
import 'package:vocal_warmup/src/features/range_detection/domain/repositories/vocal_range_repository.dart';

class LoadVocalRangeUseCase {
  const LoadVocalRangeUseCase(this._repository);

  final VocalRangeRepository _repository;

  Future<VocalRange?> call() => _repository.loadRange();
}
