import 'package:app_theme/app_theme.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:midi_playback/midi_playback.dart';
import 'package:music_theory/music_theory.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vocal_warmup_app/src/app.dart';

void main() {
  testWidgets('starts on the warmup screen and asks for voice type', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();
    final themeController = AppThemeController();

    await tester.pumpWidget(
      Provider<MidiPlaybackService>.value(
        value: _FakeMidiPlaybackService(),
        child: VocalWarmupApp(
          sharedPreferences: sharedPreferences,
          themeController: themeController,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Распевка'), findsOneWidget);
    expect(find.text('Выберите тип голоса'), findsOneWidget);

    await tester.tap(find.text('Baritone'));
    await tester.pumpAndSettle();

    expect(find.text('Baritone'), findsWidgets);
  });

  testWidgets('opens /vocal-warmup directly after bootstrap', (tester) async {
    SharedPreferences.setMockInitialValues({
      'vocalWarmupSettings':
          '{"voiceType":"tenor","exercise":"humming","tempoBpm":80,"stepsUp":6,"stepsDown":6}',
    });
    final sharedPreferences = await SharedPreferences.getInstance();
    final themeController = AppThemeController();

    await tester.pumpWidget(
      Provider<MidiPlaybackService>.value(
        value: _FakeMidiPlaybackService(),
        child: VocalWarmupApp(
          sharedPreferences: sharedPreferences,
          themeController: themeController,
          initialLocation: '/vocal-warmup',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Распевка'), findsOneWidget);
    expect(find.text('Tenor'), findsWidgets);
  });
}

class _FakeMidiPlaybackService implements MidiPlaybackService {
  @override
  PlaybackAvailability get availability => PlaybackAvailability.supported;

  @override
  double get masterVolume => 0.7;

  @override
  bool get isMuted => false;

  @override
  Future<void> dispose() async {}

  @override
  Future<void> initialize() async {}

  @override
  Future<void> playChord(Chord chord, {int octave = 4}) async {}

  @override
  Future<void> playNote(ScientificNote note) async {}

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
