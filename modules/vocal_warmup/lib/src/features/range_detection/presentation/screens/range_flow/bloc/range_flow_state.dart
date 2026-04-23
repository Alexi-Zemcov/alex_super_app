import 'package:equatable/equatable.dart';
import 'package:music_theory/music_theory.dart';
import 'package:vocal_warmup/src/features/range_detection/domain/entities/range_detection_target.dart';
import 'package:vocal_warmup/src/features/range_detection/domain/entities/vocal_range.dart';
import 'package:vocal_warmup/src/features/range_detection/domain/entities/voice_type.dart';

sealed class RangeFlowState extends Equatable {
  const RangeFlowState();

  @override
  List<Object?> get props => const [];
}

final class RangeFlowInitial extends RangeFlowState {
  const RangeFlowInitial();
}

final class RangeFlowLoading extends RangeFlowState {
  const RangeFlowLoading();
}

final class RangeFlowListening extends RangeFlowState {
  const RangeFlowListening({required this.target, this.lowestNote});

  final RangeDetectionTarget target;
  final ScientificNote? lowestNote;

  @override
  List<Object?> get props => [target, lowestNote];
}

final class RangeFlowResult extends RangeFlowState {
  const RangeFlowResult({required this.range, required this.voiceType});

  final VocalRange range;
  final VoiceType voiceType;

  @override
  List<Object?> get props => [range, voiceType];
}

final class RangeFlowExerciseSelection extends RangeFlowState {
  const RangeFlowExerciseSelection({required this.range});

  final VocalRange range;

  @override
  List<Object?> get props => [range];
}

final class RangeFlowFailure extends RangeFlowState {
  const RangeFlowFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
