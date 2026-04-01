import 'package:equatable/equatable.dart';

sealed class QuizFlowEvent extends Equatable {
  const QuizFlowEvent();

  @override
  List<Object?> get props => const [];
}

final class QuizFlowStarted extends QuizFlowEvent {
  const QuizFlowStarted();
}

final class QuizAnswerSelected extends QuizFlowEvent {
  const QuizAnswerSelected(this.selectedIndex);

  final int selectedIndex;

  @override
  List<Object?> get props => [selectedIndex];
}

final class QuizQuestionRequested extends QuizFlowEvent {
  const QuizQuestionRequested(this.index);

  final int index;

  @override
  List<Object?> get props => [index];
}

final class QuizNextPressed extends QuizFlowEvent {
  const QuizNextPressed();
}

final class QuizFavoriteToggled extends QuizFlowEvent {
  const QuizFavoriteToggled();
}

final class QuizRetryPressed extends QuizFlowEvent {
  const QuizRetryPressed();
}

final class QuizTimerTicked extends QuizFlowEvent {
  const QuizTimerTicked();
}
