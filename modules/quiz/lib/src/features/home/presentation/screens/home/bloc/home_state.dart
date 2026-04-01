import 'package:equatable/equatable.dart';
import 'package:quiz/src/features/home/domain/entities/home_progress.dart';
import 'package:quiz/src/features/home/presentation/screens/home/models/home_destination.dart';

sealed class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => const [];
}

final class HomeInitial extends HomeState {
  const HomeInitial();
}

final class HomeLoading extends HomeState {
  const HomeLoading();
}

final class HomeLoaded extends HomeState {
  const HomeLoaded({
    required this.progress,
    required this.destinations,
    this.pendingDestination,
  });

  final HomeProgress progress;
  final List<HomeDestination> destinations;
  final HomeDestination? pendingDestination;

  HomeLoaded withPendingDestination(HomeDestination destination) {
    return HomeLoaded(
      progress: progress,
      destinations: destinations,
      pendingDestination: destination,
    );
  }

  HomeLoaded clearPendingDestination() {
    return HomeLoaded(progress: progress, destinations: destinations);
  }

  @override
  List<Object?> get props => [progress, destinations, pendingDestination];
}

final class HomeFailure extends HomeState {
  const HomeFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
