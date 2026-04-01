import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quiz/src/features/quiz/domain/repositories/progress_repository.dart';
import 'package:quiz/src/features/quiz/domain/repositories/question_repository.dart';
import 'package:quiz/src/features/topics/presentation/screens/topics/bloc/topics_event.dart';
import 'package:quiz/src/features/topics/presentation/screens/topics/bloc/topics_state.dart';
import 'package:quiz/src/features/topics/presentation/screens/topics/models/topic_list_item.dart';
import 'package:quiz/src/navigation/quiz_flow_intent.dart';

class TopicsBloc extends Bloc<TopicsEvent, TopicsState> {
  TopicsBloc({
    required QuestionRepository questionRepository,
    required ProgressRepository progressRepository,
  }) : _questionRepository = questionRepository,
       _progressRepository = progressRepository,
       super(const TopicsInitial()) {
    on<TopicsStarted>(_onStarted);
    on<TopicPressed>(_onTopicPressed);
    on<TopicsNavigationHandled>(_onNavigationHandled);
  }

  final QuestionRepository _questionRepository;
  final ProgressRepository _progressRepository;

  Future<void> _onStarted(
    TopicsStarted event,
    Emitter<TopicsState> emit,
  ) async {
    emit(const TopicsLoading());

    try {
      final topics = await _questionRepository.getTopics();
      final stats = await _progressRepository.getQuestionStats();

      emit(
        TopicsLoaded(
          topics: List<TopicListItem>.unmodifiable(
            topics.map(
              (topic) => TopicListItem(
                id: topic.id,
                name: topic.name,
                questionCount: topic.questions.length,
                isCompleted: topic.questions.every(
                  (question) => stats[question.key]?.hasCorrectAttempt ?? false,
                ),
              ),
            ),
          ),
        ),
      );
    } catch (_) {
      emit(const TopicsFailure(message: 'Не удалось загрузить темы.'));
    }
  }

  void _onTopicPressed(TopicPressed event, Emitter<TopicsState> emit) {
    final currentState = state;
    if (currentState is! TopicsLoaded) {
      return;
    }

    emit(
      currentState.copyWith(
        pendingNavigation: QuizFlowIntent.topic(topicId: event.topicId),
      ),
    );
  }

  void _onNavigationHandled(
    TopicsNavigationHandled event,
    Emitter<TopicsState> emit,
  ) {
    final currentState = state;
    if (currentState is! TopicsLoaded ||
        currentState.pendingNavigation == null) {
      return;
    }

    emit(currentState.copyWith(clearNavigation: true));
  }
}
