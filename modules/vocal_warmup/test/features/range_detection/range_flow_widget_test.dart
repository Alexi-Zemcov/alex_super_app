import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_theory/music_theory.dart';
import 'package:provider/provider.dart';
import 'package:scoped_di/scoped_di.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vocal_warmup/src/di/vocal_warmup_scope_module.dart';
import 'package:vocal_warmup/src/features/range_detection/di/range_flow_route_scope.dart';
import 'package:vocal_warmup/src/features/range_detection/domain/entities/range_detection_target.dart';
import 'package:vocal_warmup/src/features/range_detection/domain/services/pitch_detection_service.dart';

void main() {
  testWidgets('detects low and high notes, then opens exercise selection', (
    tester,
  ) async {
    final pitchService = _ControlledPitchDetectionService();
    await _pumpRangeFlow(tester, pitchService: pitchService);

    expect(find.text('Спойте самую низкую комфортную ноту'), findsOneWidget);

    pitchService.completeNext(RangeDetectionTarget.lowest, 'E2');
    await tester.pump();
    expect(
      find.text('Теперь спойте самую высокую комфортную ноту'),
      findsOneWidget,
    );

    pitchService.completeNext(RangeDetectionTarget.highest, 'C5');
    await tester.pumpAndSettle();
    expect(find.text('Ваш диапазон'), findsOneWidget);
    expect(find.text('E2'), findsOneWidget);
    expect(find.text('82 Гц'), findsOneWidget);
    expect(find.text('C5'), findsOneWidget);
    expect(find.text('523 Гц'), findsOneWidget);
    expect(find.text('Тенор'), findsOneWidget);

    await tester.ensureVisible(find.text('Продолжить'));
    await tester.tap(find.text('Продолжить'));
    await tester.pumpAndSettle();
    expect(find.text('Распевка'), findsOneWidget);
    expect(find.text('Выберите тип упражнения'), findsOneWidget);
    expect(find.text('Мычание'), findsOneWidget);
    expect(find.text('Тра-та-та'), findsOneWidget);
  });

  testWidgets('restart returns to the first detection step', (tester) async {
    final pitchService = _ControlledPitchDetectionService();
    await _pumpRangeFlow(tester, pitchService: pitchService);

    pitchService.completeNext(RangeDetectionTarget.lowest, 'E2');
    await tester.pump();
    pitchService.completeNext(RangeDetectionTarget.highest, 'C5');
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Заново'));
    await tester.tap(find.text('Заново'));
    await tester.pump();

    expect(find.text('Спойте самую низкую комфортную ноту'), findsOneWidget);
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
}

Future<void> _pumpRangeFlow(
  WidgetTester tester, {
  Map<String, Object> initialValues = const {},
  PitchDetectionService? pitchService,
}) async {
  SharedPreferences.setMockInitialValues(initialValues);
  final preferences = await SharedPreferences.getInstance();

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        Provider<SharedPreferences>.value(value: preferences),
        if (pitchService != null)
          Provider<PitchDetectionService>.value(value: pitchService),
      ],
      child: const FeatureScope(
        modules: [VocalWarmupScopeModule()],
        child: MaterialApp(home: RangeFlowRouteScope()),
      ),
    ),
  );
  await tester.pump();
}

class _ControlledPitchDetectionService implements PitchDetectionService {
  final Map<RangeDetectionTarget, List<Completer<ScientificNote>>> _pending = {
    RangeDetectionTarget.lowest: [],
    RangeDetectionTarget.highest: [],
  };

  @override
  Future<ScientificNote> detectStableNote(RangeDetectionTarget target) {
    final completer = Completer<ScientificNote>();
    _pending[target]!.add(completer);
    return completer.future;
  }

  void completeNext(RangeDetectionTarget target, String noteLabel) {
    final pending = _pending[target]!;
    if (pending.isEmpty) {
      throw StateError('No pending detection for $target.');
    }

    pending.removeAt(0).complete(ScientificNote.parse(noteLabel));
  }
}
