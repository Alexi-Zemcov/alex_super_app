import 'package:circle_of_fifths/src/features/circle/domain/domain.dart';
import 'package:equatable/equatable.dart';

/// Base sealed class for circle feature states.
sealed class CircleState extends Equatable {
  const CircleState();

  @override
  List<Object?> get props => [];
}

/// Initial state when the app starts.
final class CircleStateInitial extends CircleState {
  const CircleStateInitial();

  @override
  List<Object?> get props => [];
}

/// State when the circle screen is ready with current settings.
final class CircleStateReady extends CircleState {
  const CircleStateReady({
    this.currentKey = MusicKey.cMajor,
    this.isLocked = false,
    this.hasSustain = true,
    this.lastPlayedChord,
  });

  /// The currently selected musical key.
  final MusicKey currentKey;

  /// Whether the key selection is locked.
  final bool isLocked;

  /// Chord sounds with sustain.
  final bool hasSustain;

  /// The most recently played chord.
  final Chord? lastPlayedChord;

  /// Creates a copy of this state with the given fields replaced.
  CircleStateReady copyWith({
    MusicKey? currentKey,
    bool? isLocked,
    bool? hasSustain,
    Chord? lastPlayedChord,
  }) {
    return CircleStateReady(
      currentKey: currentKey ?? this.currentKey,
      isLocked: isLocked ?? this.isLocked,
      hasSustain: hasSustain ?? this.hasSustain,
      lastPlayedChord: lastPlayedChord ?? this.lastPlayedChord,
    );
  }

  @override
  List<Object?> get props => [
    currentKey,
    isLocked,
    hasSustain,
    lastPlayedChord,
  ];
}
