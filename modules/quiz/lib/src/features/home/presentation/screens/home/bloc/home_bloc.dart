import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quiz/src/features/home/domain/usecases/get_home_progress_use_case.dart';
import 'package:quiz/src/features/home/presentation/screens/home/bloc/home_event.dart';
import 'package:quiz/src/features/home/presentation/screens/home/bloc/home_state.dart';
import 'package:quiz/src/features/home/presentation/screens/home/models/home_destination.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({required GetHomeProgressUseCase getHomeProgress})
    : _getHomeProgress = getHomeProgress,
      super(const HomeInitial()) {
    on<HomeStarted>(_onStarted);
    on<HomeDestinationPressed>(_onDestinationPressed);
    on<HomeNavigationHandled>(_onNavigationHandled);
  }

  static const _destinations = HomeDestination.values;

  final GetHomeProgressUseCase _getHomeProgress;

  Future<void> _onStarted(HomeStarted event, Emitter<HomeState> emit) async {
    emit(const HomeLoading());

    try {
      final progress = await _getHomeProgress();
      emit(
        HomeLoaded(
          progress: progress,
          destinations: List<HomeDestination>.unmodifiable(_destinations),
        ),
      );
    } catch (_) {
      emit(const HomeFailure(message: 'Не удалось загрузить главный экран.'));
    }
  }

  void _onDestinationPressed(
    HomeDestinationPressed event,
    Emitter<HomeState> emit,
  ) {
    final currentState = state;
    if (currentState is! HomeLoaded) {
      return;
    }

    emit(currentState.withPendingDestination(event.destination));
  }

  void _onNavigationHandled(
    HomeNavigationHandled event,
    Emitter<HomeState> emit,
  ) {
    final currentState = state;
    if (currentState is! HomeLoaded) {
      return;
    }

    if (currentState.pendingDestination == null) {
      return;
    }

    emit(currentState.clearPendingDestination());
  }
}
