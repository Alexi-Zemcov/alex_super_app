import 'package:music_theory/music_theory.dart';
import 'package:vocal_warmup/src/features/range_detection/domain/entities/vocal_range.dart';

abstract interface class NotePreviewService {
  Future<void> previewNote(ScientificNote note);

  Future<void> previewRange(VocalRange range);

  Future<void> stop();

  Future<void> dispose();
}
