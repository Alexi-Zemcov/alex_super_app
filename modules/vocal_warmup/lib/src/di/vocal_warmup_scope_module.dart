import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:midi_playback/midi_playback.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:scoped_di/scoped_di.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vocal_warmup/src/features/warmup/data/datasources/warmup_settings_datasource.dart';
import 'package:vocal_warmup/src/features/warmup/data/repositories/warmup_settings_repository_impl.dart';
import 'package:vocal_warmup/src/features/warmup/domain/repositories/warmup_settings_repository.dart';
import 'package:vocal_warmup/src/features/warmup/domain/usecases/load_warmup_settings_usecase.dart';
import 'package:vocal_warmup/src/features/warmup/domain/usecases/save_warmup_settings_usecase.dart';

class VocalWarmupScopeModule extends ScopeModule {
  const VocalWarmupScopeModule();

  @override
  List<SingleChildWidget> get providers => [
    Provider<MidiPlaybackService>(
      create: (context) {
        final inheritedService = context.read<MidiPlaybackService?>();
        return inheritedService ?? FlutterMidiPlaybackService();
      },
      dispose: (_, service) {
        if (service is FlutterMidiPlaybackService) {
          unawaited(service.dispose());
        }
      },
    ),
    Provider<WarmupSettingsDatasource>(
      create: (context) =>
          WarmupSettingsDatasource(context.read<SharedPreferences>()),
    ),
    RepositoryProvider<WarmupSettingsRepository>(
      create: (context) => WarmupSettingsRepositoryImpl(
        context.read<WarmupSettingsDatasource>(),
      ),
    ),
    Provider<LoadWarmupSettingsUseCase>(
      create: (context) =>
          LoadWarmupSettingsUseCase(context.read<WarmupSettingsRepository>()),
    ),
    Provider<SaveWarmupSettingsUseCase>(
      create: (context) =>
          SaveWarmupSettingsUseCase(context.read<WarmupSettingsRepository>()),
    ),
  ];
}
