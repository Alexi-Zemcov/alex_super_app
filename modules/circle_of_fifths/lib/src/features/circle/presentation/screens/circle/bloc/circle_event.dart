import 'package:circle_of_fifths/src/features/circle/domain/domain.dart';
import 'package:equatable/equatable.dart';

/// Events for the CircleBloc.
sealed class CircleEvent extends Equatable {
  const CircleEvent();

  @override
  List<Object?> get props => [];
}

/// Event to select a new musical key.
final class SelectCircleKey extends CircleEvent {
  const SelectCircleKey(this.key);

  final MusicKey key;

  @override
  List<Object?> get props => [key];
}

/// Event to toggle the lock state.
final class ToggleCircleLock extends CircleEvent {
  const ToggleCircleLock();
}

/// Event to toggle the sustain state.
final class ToggleSustain extends CircleEvent {
  const ToggleSustain();
}

/// Event to reset to default state.
final class CircleReset extends CircleEvent {
  const CircleReset();
}

/// Event to play a chord.
final class PlayChord extends CircleEvent {
  const PlayChord(this.chord);

  final Chord chord;

  @override
  List<Object?> get props => [chord];
}

/// Event to stop a chord.
final class StopChord extends CircleEvent {
  const StopChord(this.chord);

  final Chord chord;

  @override
  List<Object?> get props => [chord];
}
