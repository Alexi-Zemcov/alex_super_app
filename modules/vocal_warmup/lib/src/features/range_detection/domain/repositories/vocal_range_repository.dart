import 'package:vocal_warmup/src/features/range_detection/domain/entities/vocal_range.dart';

abstract interface class VocalRangeRepository {
  Future<VocalRange?> loadRange();

  Future<void> saveRange(VocalRange range);
}
