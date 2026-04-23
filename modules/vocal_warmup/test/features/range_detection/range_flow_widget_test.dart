import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_theory/music_theory.dart';
import 'package:pitch_detection/pitch_detection.dart';
import 'package:provider/provider.dart';
import 'package:scoped_di/scoped_di.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vocal_warmup/src/di/vocal_warmup_scope_module.dart';
import 'package:vocal_warmup/src/features/range_detection/di/range_flow_route_scope.dart';
import 'package:vocal_warmup/src/features/range_detection/domain/entities/detected_pitch_sample.dart';
import 'package:vocal_warmup/src/features/range_detection/domain/entities/range_detection_target.dart';
import 'package:vocal_warmup/src/features/range_detection/domain/entities/vocal_range.dart';
import 'package:vocal_warmup/src/features/range_detection/domain/services/note_preview_service.dart';
import 'package:vocal_warmup/src/features/range_detection/domain/services/pitch_detection_service.dart';

void main() {
  testWidgets(
    'requires directional hold before moving from low note to high note',
    (tester) async {
      final pitchService = _ScriptedPitchDetectionService();
      final notePreviewService = _RecordingNotePreviewService();
      await _pumpRangeFlow(
        tester,
        pitchService: pitchService,
        notePreviewService: notePreviewService,
      );

      expect(find.textContaining('двигайтесь вниз'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 450));
      expect(find.textContaining('двигайтесь вниз'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 200));
      expect(find.textContaining('двигайтесь вверх'), findsOneWidget);

      await tester.pumpAndSettle(const Duration(milliseconds: 800));

      expect(find.text('Ваш диапазон'), findsOneWidget);
      expect(find.text('E2'), findsOneWidget);
      expect(find.text('C5'), findsOneWidget);
      expect(find.text('Тенор'), findsOneWidget);
      expect(
        notePreviewService.previewedRanges.single.lowestNote,
        ScientificNote.parse('E2'),
      );
      expect(
        notePreviewService.previewedRanges.single.highestNote,
        ScientificNote.parse('C5'),
      );

      await tester.ensureVisible(find.text('Продолжить'));
      await tester.tap(find.text('Продолжить'));
      await tester.pumpAndSettle();
      expect(find.text('Распевка'), findsOneWidget);
      expect(find.text('Выберите тип упражнения'), findsOneWidget);
      expect(find.text('Диапазон E2 - C5'), findsOneWidget);
    },
  );

  testWidgets('allows adjusting the detected range from the result screen', (
    tester,
  ) async {
    final pitchService = _ScriptedPitchDetectionService();
    final notePreviewService = _RecordingNotePreviewService();
    await _pumpRangeFlow(
      tester,
      pitchService: pitchService,
      notePreviewService: notePreviewService,
    );

    await tester.pumpAndSettle(const Duration(milliseconds: 1600));

    await tester.tap(find.byKey(const Key('rangeFlow.lowestEndpoint')));
    await tester.pumpAndSettle();

    final picker = tester.widget<CupertinoPicker>(
      find.byKey(const Key('rangeFlow.lowestPicker')),
    );
    picker.onSelectedItemChanged!(17);
    await tester.pump();

    expect(find.text('F2'), findsWidgets);
    expect(notePreviewService.previewedNotes.last, ScientificNote.parse('F2'));

    await tester.tap(find.text('Готово'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Продолжить'));
    await tester.tap(find.text('Продолжить'));
    await tester.pumpAndSettle();

    expect(find.text('Диапазон F2 - C5'), findsOneWidget);
  });

  testWidgets('restart returns to the first detection step', (tester) async {
    final pitchService = _ScriptedPitchDetectionService();
    await _pumpRangeFlow(
      tester,
      pitchService: pitchService,
      notePreviewService: _RecordingNotePreviewService(),
    );

    await tester.pumpAndSettle(const Duration(milliseconds: 1600));

    await tester.ensureVisible(find.text('Заново'));
    await tester.tap(find.text('Заново'));
    await tester.pump();

    expect(find.textContaining('двигайтесь вниз'), findsOneWidget);
    await tester.pumpAndSettle(const Duration(milliseconds: 1600));
  });

  testWidgets('opens exercise selection when a range is already stored', (
    tester,
  ) async {
    await _pumpRangeFlow(
      tester,
      initialValues: {
        'vocalWarmupRange':
            '{"lowestNote":"E2","highestNote":"C5",'
            '"detectedAt":"2026-04-23T00:00:00.000Z"}',
      },
    );
    await tester.pumpAndSettle();

    expect(find.text('Распевка'), findsOneWidget);
    expect(find.text('Выберите тип упражнения'), findsOneWidget);
    expect(find.text('Диапазон E2 - C5'), findsOneWidget);
  });

  testWidgets('shows microphone error when permission is denied', (
    tester,
  ) async {
    await _pumpRangeFlow(
      tester,
      pitchService: _FailingPitchDetectionService(
        PitchDetectionException.permissionDenied(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Нужен доступ к микрофону.'), findsOneWidget);
    expect(find.text('Повторить'), findsOneWidget);
  });
}

Future<void> _pumpRangeFlow(
  WidgetTester tester, {
  Map<String, Object> initialValues = const {},
  PitchDetectionService? pitchService,
  NotePreviewService? notePreviewService,
}) async {
  SharedPreferences.setMockInitialValues(initialValues);
  final preferences = await SharedPreferences.getInstance();

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        Provider<SharedPreferences>.value(value: preferences),
        if (pitchService != null)
          Provider<PitchDetectionService>.value(value: pitchService),
        if (notePreviewService != null)
          Provider<NotePreviewService>.value(value: notePreviewService),
      ],
      child: const FeatureScope(
        modules: [VocalWarmupScopeModule()],
        child: MaterialApp(home: RangeFlowRouteScope()),
      ),
    ),
  );
  await tester.pump();
}

class _ScriptedPitchDetectionService implements PitchDetectionService {
  @override
  Future<void> prepareDetection() => Future<void>.value();

  @override
  Stream<DetectedPitchSample> observeDetectedPitches(
    RangeDetectionTarget target,
  ) async* {
    final baseTime = target == RangeDetectionTarget.lowest
        ? DateTime.utc(2026, 4, 23, 0, 0, 0)
        : DateTime.utc(2026, 4, 23, 0, 1, 0);
    final script = target == RangeDetectionTarget.lowest
        ? _lowestScript
        : _highestScript;

    for (final step in script) {
      await Future<void>.delayed(Duration(milliseconds: step.delayMs));
      yield DetectedPitchSample(
        note: ScientificNote.parse(step.noteLabel),
        timestamp: baseTime.add(Duration(milliseconds: step.timestampMs)),
        isPitched: true,
      );
    }
  }

  @override
  Future<void> stopDetection() => Future<void>.value();
}

const _lowestScript = [
  _PitchScriptStep(noteLabel: 'G3', delayMs: 0, timestampMs: 0),
  _PitchScriptStep(noteLabel: 'F3', delayMs: 100, timestampMs: 1000),
  _PitchScriptStep(noteLabel: 'E2', delayMs: 100, timestampMs: 2000),
  _PitchScriptStep(noteLabel: 'E2', delayMs: 200, timestampMs: 4000),
  _PitchScriptStep(noteLabel: 'E2', delayMs: 100, timestampMs: 5000),
];

const _highestScript = [
  _PitchScriptStep(noteLabel: 'G3', delayMs: 0, timestampMs: 0),
  _PitchScriptStep(noteLabel: 'A3', delayMs: 100, timestampMs: 1000),
  _PitchScriptStep(noteLabel: 'C5', delayMs: 100, timestampMs: 2000),
  _PitchScriptStep(noteLabel: 'C5', delayMs: 200, timestampMs: 4000),
  _PitchScriptStep(noteLabel: 'C5', delayMs: 100, timestampMs: 5000),
];

class _PitchScriptStep {
  const _PitchScriptStep({
    required this.noteLabel,
    required this.delayMs,
    required this.timestampMs,
  });

  final String noteLabel;
  final int delayMs;
  final int timestampMs;
}

class _RecordingNotePreviewService implements NotePreviewService {
  final List<ScientificNote> previewedNotes = [];
  final List<VocalRange> previewedRanges = [];

  @override
  Future<void> dispose() async {}

  @override
  Future<void> previewNote(ScientificNote note) async {
    previewedNotes.add(note);
  }

  @override
  Future<void> previewRange(VocalRange range) async {
    previewedRanges.add(range);
  }

  @override
  Future<void> stop() async {}
}

class _FailingPitchDetectionService implements PitchDetectionService {
  const _FailingPitchDetectionService(this.error);

  final Exception error;

  @override
  Future<void> prepareDetection() {
    return Future<void>.error(error);
  }

  @override
  Stream<DetectedPitchSample> observeDetectedPitches(
    RangeDetectionTarget target,
  ) {
    return Stream<DetectedPitchSample>.error(error);
  }

  @override
  Future<void> stopDetection() async {}
}
