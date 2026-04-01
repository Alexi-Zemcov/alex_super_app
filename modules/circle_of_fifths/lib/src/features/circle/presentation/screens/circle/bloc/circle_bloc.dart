import 'dart:async';

import 'package:circle_of_fifths/src/features/circle/domain/usecases/usecases.dart';
import 'package:circle_of_fifths/src/features/circle/presentation/screens/circle/bloc/circle_event.dart';
import 'package:circle_of_fifths/src/features/circle/presentation/screens/circle/bloc/circle_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// BLoC for managing the circle screen state.
class CircleBloc extends Bloc<CircleEvent, CircleState> {
  final PlayChordUseCase _playChordUseCase;
  final StopChordUseCase _stopChordUseCase;
  final ResetAudioUseCase _resetAudioUseCase;

  CircleBloc({
    required PlayChordUseCase playChordUseCase,
    required StopChordUseCase stopChordUseCase,
    required ResetAudioUseCase resetAudioUseCase,
  }) : _playChordUseCase = playChordUseCase,
       _stopChordUseCase = stopChordUseCase,
       _resetAudioUseCase = resetAudioUseCase,
       super(const CircleStateReady()) {
    on<SelectCircleKey>(_onKeySelected);
    on<ToggleCircleLock>(_onLockToggled);
    on<ToggleSustain>(_onSustainToggled);
    on<CircleReset>(_onReset);
    on<PlayChord>(_onChordPlayed);
    on<StopChord>(_onChordStopped);
  }

  void _onKeySelected(SelectCircleKey event, Emitter<CircleState> emit) {
    final currentState = state;
    if (currentState is! CircleStateReady) {
      emit(CircleStateReady(currentKey: event.key));
      return;
    }

    if (currentState.isLocked) return;

    if (currentState.currentKey != event.key) {
      emit(currentState.copyWith(currentKey: event.key));
    }
  }

  void _onLockToggled(ToggleCircleLock event, Emitter<CircleState> emit) {
    final currentState = state;
    if (currentState is! CircleStateReady) {
      emit(const CircleStateReady(isLocked: true));
      return;
    }

    emit(currentState.copyWith(isLocked: !currentState.isLocked));
  }

  void _onSustainToggled(ToggleSustain event, Emitter<CircleState> emit) {
    final currentState = state;
    if (currentState is! CircleStateReady) {
      emit(const CircleStateReady(hasSustain: true));
      return;
    }

    emit(currentState.copyWith(hasSustain: !currentState.hasSustain));
  }

  void _onReset(CircleReset event, Emitter<CircleState> emit) {
    _resetAudioUseCase();
    emit(const CircleStateReady());
  }

  void _onChordPlayed(PlayChord event, Emitter<CircleState> emit) {
    unawaited(_playChordUseCase(event.chord));

    final currentState = state;
    if (currentState is CircleStateReady) {
      emit(currentState.copyWith(lastPlayedChord: event.chord));
    }
  }

  void _onChordStopped(StopChord event, Emitter<CircleState> emit) {
    _stopChordUseCase(event.chord);
  }
}
