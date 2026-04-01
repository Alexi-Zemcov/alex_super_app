import 'package:equatable/equatable.dart';
import 'package:quiz/src/features/quiz/domain/entities/quiz_question.dart';
import 'package:quiz/src/features/quiz/domain/entities/quiz_result.dart';
import 'package:quiz/src/features/quiz/domain/entities/quiz_session.dart';

sealed class QuizFlowState extends Equatable {
  const QuizFlowState();

  @override
  List<Object?> get props => const [];
}

final class QuizFlowLoading extends QuizFlowState {
  const QuizFlowLoading();
}

final class QuizFlowFailure extends QuizFlowState {
  const QuizFlowFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

final class QuizFlowActive extends QuizFlowState {
  const QuizFlowActive({
    required this.session,
    required this.favorites,
    this.remainingSeconds,
  });

  final QuizSession session;
  final Set<QuestionKey> favorites;
  final int? remainingSeconds;

  QuizFlowActive copyWith({
    QuizSession? session,
    Set<QuestionKey>? favorites,
    int? remainingSeconds,
    bool clearTimer = false,
  }) {
    return QuizFlowActive(
      session: session ?? this.session,
      favorites: favorites ?? this.favorites,
      remainingSeconds: clearTimer
          ? null
          : (remainingSeconds ?? this.remainingSeconds),
    );
  }

  @override
  List<Object?> get props => [session, favorites, remainingSeconds];
}

final class QuizFlowResults extends QuizFlowState {
  const QuizFlowResults({required this.session, required this.result});

  final QuizSession session;
  final QuizResult result;

  @override
  List<Object?> get props => [session, result];
}
