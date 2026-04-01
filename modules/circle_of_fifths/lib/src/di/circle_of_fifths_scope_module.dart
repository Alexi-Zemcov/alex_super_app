import 'dart:async';

import 'package:circle_of_fifths/src/core/audio/audio_playback_service.dart';
import 'package:circle_of_fifths/src/core/audio/flutter_midi_audio_playback_service.dart';
import 'package:circle_of_fifths/src/features/circle/domain/usecases/usecases.dart';
import 'package:circle_of_fifths/src/features/settings/bloc/settings_bloc.dart';
import 'package:circle_of_fifths/src/features/settings/bloc/settings_event.dart';
import 'package:circle_of_fifths/src/features/settings/data/datasources/settings_datasource.dart';
import 'package:circle_of_fifths/src/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:circle_of_fifths/src/features/settings/domain/repositories/settings_repository.dart';
import 'package:circle_of_fifths/src/features/settings/domain/usecases/usecases.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:scoped_di/scoped_di.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CircleOfFifthsScopeModule extends ScopeModule {
  const CircleOfFifthsScopeModule();

  @override
  List<SingleChildWidget> get providers => [
    Provider<AudioPlaybackService>(
      create: (context) {
        final inheritedService = context.read<AudioPlaybackService?>();
        return inheritedService ?? FlutterMidiAudioPlaybackService();
      },
      dispose: (_, service) {
        if (service is FlutterMidiAudioPlaybackService) {
          unawaited(service.dispose());
        }
      },
    ),
    Provider<SettingsDatasource>(
      create: (context) =>
          SettingsDatasource(context.read<SharedPreferences>()),
    ),
    RepositoryProvider<SettingsRepository>(
      create: (context) =>
          SettingsRepositoryImpl(context.read<SettingsDatasource>()),
    ),
    Provider<LoadSettingsUseCase>(
      create: (context) =>
          LoadSettingsUseCase(context.read<SettingsRepository>()),
    ),
    Provider<SaveSettingsUseCase>(
      create: (context) =>
          SaveSettingsUseCase(context.read<SettingsRepository>()),
    ),
    Provider<SetMasterVolumeUseCase>(
      create: (context) =>
          SetMasterVolumeUseCase(context.read<AudioPlaybackService>()),
    ),
    Provider<ToggleMuteUseCase>(
      create: (context) =>
          ToggleMuteUseCase(context.read<AudioPlaybackService>()),
    ),
    Provider<ResetAudioUseCase>(
      create: (context) =>
          ResetAudioUseCase(context.read<AudioPlaybackService>()),
    ),
    BlocProvider<SettingsBloc>(
      create: (context) => SettingsBloc(
        loadSettingsUseCase: context.read<LoadSettingsUseCase>(),
        saveSettingsUseCase: context.read<SaveSettingsUseCase>(),
        setMasterVolumeUseCase: context.read<SetMasterVolumeUseCase>(),
        toggleMuteUseCase: context.read<ToggleMuteUseCase>(),
        resetAudioUseCase: context.read<ResetAudioUseCase>(),
      )..add(const LoadSettings()),
    ),
  ];
}
