import 'package:music_theory/music_theory.dart';
import 'package:vocal_warmup/src/features/range_detection/data/datasources/vocal_range_storage_datasource.dart';
import 'package:vocal_warmup/src/features/range_detection/domain/entities/vocal_range.dart';
import 'package:vocal_warmup/src/features/range_detection/domain/repositories/vocal_range_repository.dart';

class SharedPreferencesVocalRangeRepository implements VocalRangeRepository {
  const SharedPreferencesVocalRangeRepository(this._dataSource);

  static const _lowestNoteKey = 'lowestNote';
  static const _highestNoteKey = 'highestNote';
  static const _detectedAtKey = 'detectedAt';

  final VocalRangeStorageDataSource _dataSource;

  @override
  Future<VocalRange?> loadRange() async {
    final json = await _dataSource.loadRange();
    if (json == null) {
      return null;
    }

    try {
      final lowestNote = json[_lowestNoteKey] as String?;
      final highestNote = json[_highestNoteKey] as String?;
      final detectedAt = json[_detectedAtKey] as String?;
      if (lowestNote == null || highestNote == null || detectedAt == null) {
        return null;
      }

      return VocalRange(
        lowestNote: ScientificNote.parse(lowestNote),
        highestNote: ScientificNote.parse(highestNote),
        detectedAt: DateTime.parse(detectedAt),
      );
    } on FormatException {
      return null;
    }
  }

  @override
  Future<void> saveRange(VocalRange range) {
    return _dataSource.saveRange({
      _lowestNoteKey: range.lowestNote.label(),
      _highestNoteKey: range.highestNote.label(),
      _detectedAtKey: range.detectedAt.toIso8601String(),
    });
  }
}
