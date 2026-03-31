import 'package:equatable/equatable.dart';

import 'package:quiz/src/features/home/presentation/models/home_destination.dart';

sealed class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => const [];
}

final class HomeStarted extends HomeEvent {
  const HomeStarted();
}

final class HomeDestinationPressed extends HomeEvent {
  const HomeDestinationPressed(this.destination);

  final HomeDestination destination;

  @override
  List<Object?> get props => [destination];
}

final class HomeNavigationHandled extends HomeEvent {
  const HomeNavigationHandled();
}
