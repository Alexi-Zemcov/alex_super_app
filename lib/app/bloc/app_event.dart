import 'package:equatable/equatable.dart';

sealed class AppEvent extends Equatable {
  const AppEvent();

  @override
  List<Object?> get props => const [];
}

final class AppStarted extends AppEvent {
  const AppStarted();
}

final class AppThemeCycleRequested extends AppEvent {
  const AppThemeCycleRequested();
}
