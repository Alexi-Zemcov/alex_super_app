import 'package:equatable/equatable.dart';

sealed class TopicsEvent extends Equatable {
  const TopicsEvent();

  @override
  List<Object?> get props => const [];
}

final class TopicsStarted extends TopicsEvent {
  const TopicsStarted();
}

final class TopicPressed extends TopicsEvent {
  const TopicPressed(this.topicId);

  final int topicId;

  @override
  List<Object?> get props => [topicId];
}

final class TopicsNavigationHandled extends TopicsEvent {
  const TopicsNavigationHandled();
}
