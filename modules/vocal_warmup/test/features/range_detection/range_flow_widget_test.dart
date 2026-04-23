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
      final pitchService = _ControlledPitchDetectionService();
      final notePreviewService = _RecordingNotePreviewService();
      await _pumpRangeFlow(
        tester,
        pitchService: pitchService,
        notePreviewService: notePreviewService,
      );

      expect(find.textContaining('двигайтесь вниз'), findsOneWidget);

      pitchService.emitNote(RangeDetectionTarget.lowest, 'G3', elapsedMs: 0);
      await tester.pump();
      pitchService.emitNote(RangeDetectionTarget.lowest, 'F3', elapsedMs: 1000);
      await tester.pump();
      pitchService.emitNote(RangeDetectionTarget.lowest, 'E2', elapsedMs: 2000);
      await tester.pump();
      pitchService.emitNote(RangeDetectionTarget.lowest, 'E2', elapsedMs: 4000);
      await tester.pump();

      expect(find.textContaining('двигайтесь вниз'), findsOneWidget);

      pitchService.emitNote(RangeDetectionTarget.lowest, 'E2', elapsedMs: 5000);
      await tester.pump();
      await tester.pump();
      expect(find.textContaining('двигайтесь вверх'), findsOneWidget);

      pitchService.emitNote(RangeDetectionTarget.highest, 'G3', elapsedMs: 0);
      await tester.pump();
      pitchService.emitNote(
        RangeDetectionTarget.highest,
        'A3',
        elapsedMs: 1000,
      );
      await tester.pump();
      pitchService.emitNote(
        RangeDetectionTarget.highest,
        'C5',
        elapsedMs: 2000,
      );
      await tester.pump();
      pitchService.emitNote(
        RangeDetectionTarget.highest,
        'C5',
        elapsedMs: 5000,
      );
      await tester.pumpAndSettle();

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
    final pitchService = _ControlledPitchDetectionService();
    final notePreviewService = _RecordingNotePreviewService();
    await _pumpRangeFlow(
      tester,
      pitchService: pitchService,
      notePreviewService: notePreviewService,
    );

    await _completeDetectionFlow(tester, pitchService);

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

    await tester.tap(find.text('Продолжить'));
    await tester.pumpAndSettle();

    expect(find.text('Диапазон F2 - C5'), findsOneWidget);
  });

  testWidgets('restart returns to the first detection step', (tester) async {
    final pitchService = _ControlledPitchDetectionService();
    await _pumpRangeFlow(tester, pitchService: pitchService);

    await _completeDetectionFlow(tester, pitchService);

    await tester.ensureVisible(find.text('Заново'));
    await tester.tap(find.text('Заново'));
    await tester.pump();

    expect(find.textContaining('двигайтесь вниз'), findsOneWidget);
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

Future<void> _completeDetectionFlow(
  WidgetTester tester,
  _ControlledPitchDetectionService pitchService,
) async {
  pitchService.emitNote(RangeDetectionTarget.lowest, 'G3', elapsedMs: 0);
  pitchService.emitNote(RangeDetectionTarget.lowest, 'F3', elapsedMs: 1000);
  pitchService.emitNote(RangeDetectionTarget.lowest, 'E2', elapsedMs: 2000);
  pitchService.emitNote(RangeDetectionTarget.lowest, 'E2', elapsedMs: 5000);
  await tester.pump();
  await tester.pump();

  pitchService.emitNote(RangeDetectionTarget.highest, 'G3', elapsedMs: 0);
  pitchService.emitNote(RangeDetectionTarget.highest, 'A3', elapsedMs: 1000);
  pitchService.emitNote(RangeDetectionTarget.highest, 'C5', elapsedMs: 2000);
  pitchService.emitNote(RangeDetectionTarget.highest, 'C5', elapsedMs: 5000);
  await tester.pump();
  await tester.pumpAndSettle();
}

class _ControlledPitchDetectionService implements PitchDetectionService {
  final Map<RangeDetectionTarget, StreamController<DetectedPitchSample>?>
  _controllers = {
    RangeDetectionTarget.lowest: null,
    RangeDetectionTarget.highest: null,
  };
  final Map<RangeDetectionTarget, List<DetectedPitchSample>> _pendingSamples = {
    RangeDetectionTarget.lowest: <DetectedPitchSample>[],
    RangeDetectionTarget.highest: <DetectedPitchSample>[],
  };

  final Map<RangeDetectionTarget, DateTime> _baseTimes = {
    RangeDetectionTarget.lowest: DateTime.utc(2026, 4, 23, 0, 0, 0),
    RangeDetectionTarget.highest: DateTime.utc(2026, 4, 23, 0, 1, 0),
  };

  @override
  Future<void> prepareDetection() => Future<void>.value();

  @override
  Stream<DetectedPitchSample> observeDetectedPitches(
    RangeDetectionTarget target,
  ) {
    final controller = StreamController<DetectedPitchSample>();
    _controllers[target] = controller;
    for (final sample in _pendingSamples[target]!) {
      controller.add(sample);
    }
    _pendingSamples[target]!.clear();
    return controller.stream;
  }

  @override
  Future<void> stopDetection() async {
    for (final entry in _controllers.entries.toList()) {
      await entry.value?.close();
      _controllers[entry.key] = null;
    }
  }

  void emitNote(
    RangeDetectionTarget target,
    String noteLabel, {
    required int elapsedMs,
  }) {
    final controller = _controllers[target];
    if (controller == null) {
      _pendingSamples[target]!.add(
        DetectedPitchSample(
          note: ScientificNote.parse(noteLabel),
          timestamp: _baseTimes[target]!.add(Duration(milliseconds: elapsedMs)),
          isPitched: true,
        ),
      );
      return;
    }

    controller.add(
      DetectedPitchSample(
        note: ScientificNote.parse(noteLabel),
        timestamp: _baseTimes[target]!.add(Duration(milliseconds: elapsedMs)),
        isPitched: true,
      ),
    );
  }
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
