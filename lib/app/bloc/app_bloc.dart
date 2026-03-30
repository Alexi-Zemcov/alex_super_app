import 'package:alex_super_app/app/bloc/app_event.dart';
import 'package:alex_super_app/app/bloc/app_state.dart';
import 'package:alex_super_app/features/theme/domain/entities/theme_preference.dart';
import 'package:alex_super_app/features/theme/domain/usecases/cycle_theme_use_case.dart';
import 'package:alex_super_app/features/theme/domain/usecases/load_theme_use_case.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc({required LoadThemeUseCase loadTheme, required CycleThemeUseCase cycleTheme})
    : _loadTheme = loadTheme,
      _cycleTheme = cycleTheme,
      super(const AppState(themePreference: ThemePreference.dark)) {
    on<AppStarted>(_onStarted);
    on<AppThemeCycleRequested>(_onThemeCycleRequested);
  }

  final LoadThemeUseCase _loadTheme;
  final CycleThemeUseCase _cycleTheme;

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
