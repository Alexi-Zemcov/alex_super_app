import 'package:circle_of_fifths/src/features/circle/domain/usecases/usecases.dart';
import 'package:circle_of_fifths/src/features/settings/bloc/settings_event.dart';
import 'package:circle_of_fifths/src/features/settings/bloc/settings_state.dart';
import 'package:circle_of_fifths/src/features/settings/domain/domain.dart';
import 'package:circle_of_fifths/src/features/settings/domain/usecases/usecases.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// BLoC for managing application settings.
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final LoadSettingsUseCase _loadSettingsUseCase;
  final SaveSettingsUseCase _saveSettingsUseCase;
  final SetMasterVolumeUseCase _setMasterVolumeUseCase;
  final ToggleMuteUseCase _toggleMuteUseCase;
  final ResetAudioUseCase _resetAudioUseCase;

  SettingsBloc({
    required LoadSettingsUseCase loadSettingsUseCase,
    required SaveSettingsUseCase saveSettingsUseCase,
    required SetMasterVolumeUseCase setMasterVolumeUseCase,
    required ToggleMuteUseCase toggleMuteUseCase,
    required ResetAudioUseCase resetAudioUseCase,
  }) : _loadSettingsUseCase = loadSettingsUseCase,
       _saveSettingsUseCase = saveSettingsUseCase,
       _setMasterVolumeUseCase = setMasterVolumeUseCase,
       _toggleMuteUseCase = toggleMuteUseCase,
       _resetAudioUseCase = resetAudioUseCase,
       super(const SettingsStateInitial()) {
    on<LoadSettings>(_onLoad);
    on<ChangeSettingsNotation>(_onNotationChanged);
    on<ChangeSettingsVolume>(_onVolumeChanged);
    on<ToggleSettingsMute>(_onMuteToggled);
    on<ResetSettings>(_onReset);
  }

  Future<void> _onLoad(LoadSettings event, Emitter<SettingsState> emit) async {
    emit(const SettingsStateLoading());
    try {
      final settings = await _loadSettingsUseCase() ?? Settings.defaults;
      _setMasterVolumeUseCase(settings.masterVolume);
      emit(SettingsStateLoaded(settings, isMuted: false));
    } catch (e) {
      _setMasterVolumeUseCase(Settings.defaults.masterVolume);
      emit(const SettingsStateLoaded(Settings.defaults, isMuted: false));
    }
  }

  Future<void> _onNotationChanged(
    ChangeSettingsNotation event,
    Emitter<SettingsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! SettingsStateLoaded) return;

    final newSettings = currentState.settings.copyWith(
      notationPreference: event.preference,
    );
    emit(currentState.copyWith(settings: newSettings));
    await _persistSettings(newSettings);
  }

  Future<void> _onVolumeChanged(
    ChangeSettingsVolume event,
    Emitter<SettingsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! SettingsStateLoaded) return;

    final clampedVolume = event.volume.clamp(0.0, 1.0);
    _setMasterVolumeUseCase(clampedVolume);
    final newSettings = currentState.settings.copyWith(
      masterVolume: clampedVolume,
    );
    emit(currentState.copyWith(settings: newSettings));
    await _persistSettings(newSettings);
  }

  Future<void> _onMuteToggled(
    ToggleSettingsMute event,
    Emitter<SettingsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! SettingsStateLoaded) return;

    final newMutedState = !currentState.isMuted;
    _toggleMuteUseCase(newMutedState);
    emit(currentState.copyWith(isMuted: newMutedState));
  }

  Future<void> _onReset(
    ResetSettings event,
    Emitter<SettingsState> emit,
  ) async {
    _resetAudioUseCase();
    emit(const SettingsStateLoaded(Settings.defaults, isMuted: false));
    await _persistSettings(Settings.defaults);
  }

  Future<void> _persistSettings(Settings settings) async {
    try {
      await _saveSettingsUseCase(settings);
    } catch (e) {
      // Silently fail if persistence fails.
    }
  }
}
