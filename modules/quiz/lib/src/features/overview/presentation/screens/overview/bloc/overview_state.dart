import 'package:equatable/equatable.dart';
import 'package:quiz/src/navigation/quiz_flow_intent.dart';

sealed class OverviewState extends Equatable {
  const OverviewState();

  @override
  List<Object?> get props => const [];
}

final class OverviewInitial extends OverviewState {
  const OverviewInitial();
}

final class OverviewLoading extends OverviewState {
  const OverviewLoading();
}

final class OverviewLoaded extends OverviewState {
  const OverviewLoaded({required this.count, this.pendingNavigation});

  final int count;
  final QuizFlowIntent? pendingNavigation;

  bool get isEmpty => count == 0;

  OverviewLoaded copyWith({
    QuizFlowIntent? pendingNavigation,
    bool clearNavigation = false,
  }) {
    return OverviewLoaded(
      count: count,
      pendingNavigation: clearNavigation
          ? null
          : (pendingNavigation ?? this.pendingNavigation),
    );
  }

  @override
  List<Object?> get props => [count, pendingNavigation];
}

final class OverviewFailure extends OverviewState {
  const OverviewFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
