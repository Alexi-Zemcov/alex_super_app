import 'package:equatable/equatable.dart';
import 'package:quiz/src/features/topics/presentation/screens/topics/models/topic_list_item.dart';
import 'package:quiz/src/navigation/quiz_flow_intent.dart';

sealed class TopicsState extends Equatable {
  const TopicsState();

  @override
  List<Object?> get props => const [];
}

final class TopicsInitial extends TopicsState {
  const TopicsInitial();
}

final class TopicsLoading extends TopicsState {
  const TopicsLoading();
}

final class TopicsLoaded extends TopicsState {
  const TopicsLoaded({required this.topics, this.pendingNavigation});

  final List<TopicListItem> topics;
  final QuizFlowIntent? pendingNavigation;

  TopicsLoaded copyWith({
    QuizFlowIntent? pendingNavigation,
    bool clearNavigation = false,
  }) {
    return TopicsLoaded(
      topics: topics,
      pendingNavigation: clearNavigation
          ? null
          : (pendingNavigation ?? this.pendingNavigation),
    );
  }

  @override
  List<Object?> get props => [topics, pendingNavigation];
}

final class TopicsFailure extends TopicsState {
  const TopicsFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
