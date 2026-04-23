import 'package:flutter_test/flutter_test.dart';
import 'package:midi_playback/midi_playback.dart';
import 'package:music_theory/music_theory.dart';
import 'package:pitch_detection/pitch_detection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vocal_warmup/src/features/range_detection/data/datasources/vocal_range_storage_datasource.dart';
import 'package:vocal_warmup/src/features/range_detection/data/repositories/shared_preferences_vocal_range_repository.dart';
import 'package:vocal_warmup/src/features/range_detection/data/services/fake_pitch_detection_service.dart';
import 'package:vocal_warmup/src/features/range_detection/data/services/midi_note_preview_service.dart';
import 'package:vocal_warmup/src/features/range_detection/data/services/native_vocal_pitch_detection_service.dart';
import 'package:vocal_warmup/src/features/range_detection/domain/entities/range_detection_target.dart';
import 'package:vocal_warmup/src/features/range_detection/domain/entities/vocal_range.dart';
import 'package:vocal_warmup/src/features/range_detection/domain/services/voice_classifier.dart';

void main() {
  group('VocalRangeRepository', () {
    test('returns null when no range is stored', () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final repository = SharedPreferencesVocalRangeRepository(
        SharedPreferencesVocalRangeStorageDataSource(preferences),
      );

      expect(await repository.loadRange(), isNull);
    });

    test('saves, loads, and overwrites the vocal range', () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final repository = SharedPreferencesVocalRangeRepository(
        SharedPreferencesVocalRangeStorageDataSource(preferences),
      );
      final firstRange = VocalRange(
        lowestNote: ScientificNote.parse('E2'),
        highestNote: ScientificNote.parse('C5'),
        detectedAt: DateTime.utc(2026, 4, 23),
      );
      final secondRange = VocalRange(
        lowestNote: ScientificNote.parse('F2'),
        highestNote: ScientificNote.parse('D5'),
        detectedAt: DateTime.utc(2026, 4, 24),
      );

      await repository.saveRange(firstRange);
      expect(await repository.loadRange(), firstRange);

      await repository.saveRange(secondRange);
      expect(await repository.loadRange(), secondRange);
    });
  });

  group('FakePitchDetectionService', () {
    test(
      'emits deterministic samples ending with the expected extreme notes',
      () async {
        const service = FakePitchDetectionService(delay: Duration.zero);

        final lowestSamples = await service
            .observeDetectedPitches(RangeDetectionTarget.lowest)
            .toList();
        final highestSamples = await service
            .observeDetectedPitches(RangeDetectionTarget.highest)
            .toList();

        expect(lowestSamples.last.note, ScientificNote.parse('E2'));
        expect(highestSamples.last.note, ScientificNote.parse('C5'));
      },
    );
  });

  group('NativeVocalPitchDetectionService', () {
    test('maps pitch frames to nearest scientific notes', () async {
      final platform = _NativePitchDetectionPlatformFake()
        ..frameStream = Stream<PitchFrame>.fromIterable([
          _pitchFrame(82.0),
          _pitchFrame(82.2),
        ]);
      final service = NativeVocalPitchDetectionService(
        client: PitchDetectionClient(platform: platform),
      );

      final samples = await service
          .observeDetectedPitches(RangeDetectionTarget.lowest)
          .toList();

      expect(samples.first.note, ScientificNote.parse('E2'));
    });
  });

  group('MidiNotePreviewService', () {
    test('does nothing when playback is unsupported', () async {
      final midiPlayback = _FakeMidiPlaybackService(
        availability: PlaybackAvailability.unsupported,
      );
      final service = MidiNotePreviewService(midiPlayback);

      await service.previewNote(ScientificNote.parse('C4'));

      expect(midiPlayback.initializeCalls, 0);
      expect(midiPlayback.playedNotes, isEmpty);
    });
  });

  group('SimpleVoiceClassifier', () {
    test('classifies E2-C5 as dramatic tenor', () {
      const classifier = SimpleVoiceClassifier();
      final voiceType = classifier.classify(
        VocalRange(
          lowestNote: ScientificNote.parse('E2'),
          highestNote: ScientificNote.parse('C5'),
          detectedAt: DateTime.utc(2026, 4, 23),
        ),
      );

      expect(voiceType.title, 'Тенор');
      expect(voiceType.description, 'Драматический');
    });
  });
}

class _NativePitchDetectionPlatformFake extends PitchDetectionPlatform {
  Stream<PitchFrame> frameStream = const Stream<PitchFrame>.empty();
  MicrophonePermissionStatus permissionStatus =
      MicrophonePermissionStatus.granted;

  @override
  Stream<PitchFrame> pitchFrames() => frameStream;

  @override
  Future<MicrophonePermissionStatus> requestMicrophonePermission() async {
    return permissionStatus;
  }

  @override
  Future<void> startDetection(PitchDetectionConfig config) async {}

  @override
  Future<void> stop() async {}
}

class _FakeMidiPlaybackService implements MidiPlaybackService {
  _FakeMidiPlaybackService({required this.availability});

  @override
  final PlaybackAvailability availability;

  int initializeCalls = 0;
  final List<ScientificNote> playedNotes = [];

  @override
  bool get isMuted => false;

  @override
  double get masterVolume => 0.7;

  @override
  Future<void> dispose() async {}

  @override
  Future<void> initialize() async {
    initializeCalls += 1;
  }

  @override
  Future<void> playChord(Chord chord, {int octave = 4}) async {}

  @override
  Future<void> playNote(ScientificNote note) async {
    playedNotes.add(note);
  }

  @override
  void setMasterVolume(double volume) {}

  @override
  void setMutedAndStopAll(bool value) {}

  @override
  Future<void> stopAll() async {}

  @override
  void stopChord(Chord chord, {int octave = 4}) {}

  @override
  void stopNote(ScientificNote note) {}
}

PitchFrame _pitchFrame(double frequencyHz) {
  return PitchFrame(
    frequencyHz: frequencyHz,
    amplitude: 0.02,
    confidence: 0.8,
    isPitched: true,
    timestamp: DateTime.fromMillisecondsSinceEpoch(1000),
  );
}
