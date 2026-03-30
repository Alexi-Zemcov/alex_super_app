import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/theme/domain/entities/theme_preference.dart';
import '../../features/theme/domain/usecases/cycle_theme.dart';
import '../../features/theme/domain/usecases/load_theme.dart';
import 'app_event.dart';
import 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc({required LoadTheme loadTheme, required CycleTheme cycleTheme})
    : _loadTheme = loadTheme,
      _cycleTheme = cycleTheme,
      super(const AppState(themePreference: ThemePreference.dark)) {
    on<AppStarted>(_onStarted);
    on<AppThemeCycleRequested>(_onThemeCycleRequested);
  }

  final LoadTheme _loadTheme;
  final CycleTheme _cycleTheme;

  Future<void> _onStarted(AppStarted event, Emitter<AppState> emit) async {
    try {
      final savedTheme = await _loadTheme();
      emit(state.copyWith(themePreference: savedTheme));
    } catch (_) {
      emit(state);
    }
  }

  Future<void> _onThemeCycleRequested(
    AppThemeCycleRequested event,
    Emitter<AppState> emit,
  ) async {
    try {
      final nextTheme = await _cycleTheme(state.themePreference);
      emit(state.copyWith(themePreference: nextTheme));
    } catch (_) {
      emit(state);
    }
  }
}
