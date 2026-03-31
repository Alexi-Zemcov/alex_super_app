import 'package:app_theme/app_theme.dart';
import 'package:circle_of_fifths/src/core/audio/audio_playback_service.dart';
import 'package:circle_of_fifths/src/features/circle/domain/entities/chord.dart';
import 'package:circle_of_fifths_app/src/app.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets(
    'starts on the circle home screen and toggles theme from settings',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final sharedPreferences = await SharedPreferences.getInstance();
      final themeController = AppThemeController();

      await tester.pumpWidget(
        Provider<AudioPlaybackService>.value(
          value: _FakeAudioPlaybackService(),
          child: CircleOfFifthsApp(
            sharedPreferences: sharedPreferences,
            themeController: themeController,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Circle of Fifths'), findsOneWidget);
      expect(find.text('Каталог модулей'), findsNothing);

      await tester.tap(find.byTooltip('Settings'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('🌕'));
      await tester.pumpAndSettle();

      expect(themeController.themePreference, ThemePreference.white);
    },
  );
}

class _FakeAudioPlaybackService implements AudioPlaybackService {
  @override
  bool get isMuted => false;

  @override
  double get masterVolume => 0.7;

  @override
  Future<void> dispose() async {}

  @override
  Future<void> initialize() async {}

  @override
  Future<void> playChord(Chord chord) async {}

  @override
  void setMasterVolume(double volume) {}

  @override
  void setMutedAndStopAll(bool value) {}

  @override
  Future<void> stopAll() async {}

  @override
  void stopChord(Chord chord) {}
}
