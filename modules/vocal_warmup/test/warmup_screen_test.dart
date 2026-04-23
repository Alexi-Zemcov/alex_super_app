import 'dart:convert';

import 'package:app_theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:midi_playback/midi_playback.dart';
import 'package:music_theory/music_theory.dart';
import 'package:provider/provider.dart';
import 'package:scoped_di/scoped_di.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vocal_warmup/src/di/vocal_warmup_scope_module.dart';
import 'package:vocal_warmup/src/features/warmup/di/warmup_route_scope.dart';
import 'package:vocal_warmup/src/features/warmup/domain/entities/warmup_session_status.dart';
import 'package:vocal_warmup/src/features/warmup/presentation/screens/warmup/bloc/warmup_bloc.dart';
import 'package:vocal_warmup/src/features/warmup/presentation/screens/warmup/bloc/warmup_event.dart';
import 'package:vocal_warmup/src/features/warmup/presentation/screens/warmup/warmup_screen.dart';

void main() {
  testWidgets(
    'shows the first-launch voice dialog and previews the selection',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final sharedPreferences = await SharedPreferences.getInstance();
      final playbackService = _TestMidiPlaybackService(
        availability: PlaybackAvailability.supported,
      );

      await tester.pumpWidget(
        _WarmupHarness(
          sharedPreferences: sharedPreferences,
          playbackService: playbackService,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Выберите тип голоса'), findsOneWidget);

      await tester.tap(find.text('Baritone'));
      await tester.pumpAndSettle();

      expect(playbackService.playedNotes, contains(ScientificNote.parse('C3')));
    },
  );

  testWidgets('shows the unsupported banner and disables start', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'vocalWarmupSettings': jsonEncode({
        'voiceType': 'alto',
        'exercise': 'humming',
        'tempoBpm': 80,
        'stepsUp': 6,
        'stepsDown': 6,
      }),
    });
    final sharedPreferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      _WarmupHarness(
        sharedPreferences: sharedPreferences,
        playbackService: _TestMidiPlaybackService(
          availability: PlaybackAvailability.unsupported,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Audio playback is unavailable'),
      findsOneWidget,
    );
    final bloc = BlocProvider.of<WarmupBloc>(
      tester.element(find.byType(WarmupScreen)),
    );
    expect(bloc.state.canStart, isFalse);
  });

  testWidgets('locks controls while a session is playing', (tester) async {
    SharedPreferences.setMockInitialValues({
      'vocalWarmupSettings': jsonEncode({
        'voiceType': 'tenor',
        'exercise': 'humming',
        'tempoBpm': 80,
        'stepsUp': 6,
        'stepsDown': 6,
      }),
    });
    final sharedPreferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      _WarmupHarness(
        sharedPreferences: sharedPreferences,
        playbackService: _TestMidiPlaybackService(
          availability: PlaybackAvailability.supported,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final bloc = BlocProvider.of<WarmupBloc>(
      tester.element(find.byType(WarmupScreen)),
    );
    bloc.add(const WarmupStartPressed());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 20));

    expect(bloc.state.sessionStatus, WarmupSessionStatus.playing);
    expect(bloc.state.controlsLocked, isTrue);

    final settingsButton = tester.widget<IconButton>(find.byType(IconButton));
    expect(settingsButton.onPressed, isNull);
  });
}

class _WarmupHarness extends StatelessWidget {
  const _WarmupHarness({
    required this.sharedPreferences,
    required this.playbackService,
  });

  final SharedPreferences sharedPreferences;
  final MidiPlaybackService playbackService;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<SharedPreferences>.value(value: sharedPreferences),
        Provider<MidiPlaybackService>.value(value: playbackService),
      ],
      child: MaterialApp(
        theme: AppThemeFactory.fromPreference(ThemePreference.dark),
        home: const FeatureScope(
          modules: [VocalWarmupScopeModule()],
          child: WarmupRouteScope(),
        ),
      ),
    );
  }
}

class _TestMidiPlaybackService implements MidiPlaybackService {
  _TestMidiPlaybackService({required this.availability});

  @override
  final PlaybackAvailability availability;

  @override
  bool get isMuted => false;

  @override
  double get masterVolume => 0.7;

  final List<ScientificNote> playedNotes = [];

  @override
  Future<void> dispose() async {}

  @override
  Future<void> initialize() async {}

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
