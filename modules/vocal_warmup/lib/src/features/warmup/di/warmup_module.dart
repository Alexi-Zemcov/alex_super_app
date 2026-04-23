import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:midi_playback/midi_playback.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:scoped_di/scoped_di.dart';
import 'package:vocal_warmup/src/features/warmup/domain/services/warmup_sequence_planner.dart';
import 'package:vocal_warmup/src/features/warmup/domain/services/warmup_session_runner.dart';
import 'package:vocal_warmup/src/features/warmup/domain/usecases/load_warmup_settings_usecase.dart';
import 'package:vocal_warmup/src/features/warmup/domain/usecases/save_warmup_settings_usecase.dart';
import 'package:vocal_warmup/src/features/warmup/presentation/screens/warmup/bloc/warmup_bloc.dart';
import 'package:vocal_warmup/src/features/warmup/presentation/screens/warmup/bloc/warmup_event.dart';

class WarmupModule extends ScopeModule {
  const WarmupModule();

  @override
  List<SingleChildWidget> get providers => [
    Provider<WarmupSequencePlanner>(create: (_) => WarmupSequencePlanner()),
    Provider<WarmupSessionRunner>(
      create: (context) =>
          WarmupSessionRunner(context.read<MidiPlaybackService>()),
      dispose: (_, runner) {
        unawaited(runner.dispose());
      },
    ),
    BlocProvider<WarmupBloc>(
      create: (context) => WarmupBloc(
        playbackService: context.read<MidiPlaybackService>(),
        loadSettingsUseCase: context.read<LoadWarmupSettingsUseCase>(),
        saveSettingsUseCase: context.read<SaveWarmupSettingsUseCase>(),
        sequencePlanner: context.read<WarmupSequencePlanner>(),
        sessionRunner: context.read<WarmupSessionRunner>(),
      )..add(const WarmupInitialized()),
    ),
  ];
}
