import 'package:circle_of_fifths/src/core/audio/audio_playback_service.dart';
import 'package:circle_of_fifths/src/features/circle/domain/usecases/play_chord_usecase.dart';
import 'package:circle_of_fifths/src/features/circle/domain/usecases/reset_audio_usecase.dart';
import 'package:circle_of_fifths/src/features/circle/domain/usecases/stop_chord_usecase.dart';
import 'package:circle_of_fifths/src/features/circle/presentation/screens/circle/bloc/circle_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:scoped_di/scoped_di.dart';

class CircleModule extends ScopeModule {
  const CircleModule();

  @override
  List<SingleChildWidget> get providers => [
    Provider<PlayChordUseCase>(
      create: (context) =>
          PlayChordUseCase(context.read<AudioPlaybackService>()),
    ),
    Provider<StopChordUseCase>(
      create: (context) =>
          StopChordUseCase(context.read<AudioPlaybackService>()),
    ),
    BlocProvider<CircleBloc>(
      create: (context) => CircleBloc(
        playChordUseCase: context.read<PlayChordUseCase>(),
        stopChordUseCase: context.read<StopChordUseCase>(),
        resetAudioUseCase: context.read<ResetAudioUseCase>(),
      ),
    ),
  ];
}
