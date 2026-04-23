import 'package:equatable/equatable.dart';

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
  const RangeFlowContinuePressed();
}
