import 'package:equatable/equatable.dart';

import 'package:vocal_warmup/src/features/range_detection/domain/entities/vocal_range.dart';

sealed class RangeFlowEvent extends Equatable {
  const RangeFlowEvent();

  @override
  List<Object?> get props => const [];
}

final class RangeFlowStarted extends RangeFlowEvent {
  const RangeFlowStarted();
}

final class RangeFlowRestarted extends RangeFlowEvent {
  const RangeFlowRestarted();
}

final class RangeFlowContinuePressed extends RangeFlowEvent {
  const RangeFlowContinuePressed(this.selectedRange);

  final VocalRange selectedRange;

  @override
  List<Object?> get props => [selectedRange];
}
