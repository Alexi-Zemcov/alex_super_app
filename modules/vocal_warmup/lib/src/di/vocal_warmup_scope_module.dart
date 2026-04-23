import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:midi_playback/midi_playback.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:scoped_di/scoped_di.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vocal_warmup/src/features/range_detection/data/datasources/vocal_range_storage_datasource.dart';
import 'package:vocal_warmup/src/features/range_detection/data/repositories/shared_preferences_vocal_range_repository.dart';
import 'package:vocal_warmup/src/features/range_detection/data/services/fake_pitch_detection_service.dart';
import 'package:vocal_warmup/src/features/range_detection/data/services/midi_note_preview_service.dart';
import 'package:vocal_warmup/src/features/range_detection/data/services/native_vocal_pitch_detection_service.dart';
import 'package:vocal_warmup/src/features/range_detection/domain/repositories/vocal_range_repository.dart';
import 'package:vocal_warmup/src/features/range_detection/domain/services/note_preview_service.dart';
import 'package:vocal_warmup/src/features/range_detection/domain/services/pitch_detection_service.dart';
import 'package:vocal_warmup/src/features/range_detection/domain/services/voice_classifier.dart';

class VocalWarmupScopeModule extends ScopeModule {
  const VocalWarmupScopeModule();

  @override
  List<SingleChildWidget> get providers => [
    Provider<PitchDetectionService>(
      create: (context) {
        final override = context.read<PitchDetectionService?>();
        if (override != null) {
          return override;
        }
        if (NativeVocalPitchDetectionService.isSupportedPlatform) {
          return NativeVocalPitchDetectionService();
        }
        return const FakePitchDetectionService();
      },
    ),
    Provider<MidiPlaybackService>(
      create: (_) => FlutterMidiPlaybackService(),
      dispose: (_, service) {
        unawaited(service.dispose());
      },
    ),
    Provider<NotePreviewService>(
      create: (context) {
        final override = context.read<NotePreviewService?>();
        if (override != null) {
          return override;
        }
        return MidiNotePreviewService(context.read<MidiPlaybackService>());
      },
      dispose: (_, service) {
        unawaited(service.dispose());
      },
    ),
    Provider<VocalRangeStorageDataSource>(
      create: (context) => SharedPreferencesVocalRangeStorageDataSource(
        context.read<SharedPreferences>(),
      ),
    ),
    RepositoryProvider<VocalRangeRepository>(
      create: (context) => SharedPreferencesVocalRangeRepository(
        context.read<VocalRangeStorageDataSource>(),
      ),
    ),
    Provider<VoiceClassifier>(create: (_) => const SimpleVoiceClassifier()),
  ];
}
