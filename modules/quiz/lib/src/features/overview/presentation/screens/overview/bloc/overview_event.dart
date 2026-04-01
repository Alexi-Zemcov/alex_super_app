import 'package:equatable/equatable.dart';

sealed class OverviewEvent extends Equatable {
  const OverviewEvent();

  @override
  List<Object?> get props => const [];
}

final class OverviewStarted extends OverviewEvent {
  const OverviewStarted();
}

final class OverviewStartPressed extends OverviewEvent {
  const OverviewStartPressed();
}

final class OverviewNavigationHandled extends OverviewEvent {
  const OverviewNavigationHandled();
}
