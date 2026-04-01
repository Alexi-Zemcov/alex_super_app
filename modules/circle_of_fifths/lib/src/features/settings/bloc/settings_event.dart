import 'package:circle_of_fifths/src/features/settings/domain/domain.dart';
import 'package:equatable/equatable.dart';

/// Base class for all settings events.
sealed class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load settings from persistent storage.
final class LoadSettings extends SettingsEvent {
  const LoadSettings();
}

/// Event to change notation preference.
final class ChangeSettingsNotation extends SettingsEvent {
  const ChangeSettingsNotation(this.preference);

  final NotationPreference preference;

  @override
  List<Object?> get props => [preference];
}

/// Event to change master volume.
final class ChangeSettingsVolume extends SettingsEvent {
  const ChangeSettingsVolume(this.volume);

  final double volume;

  @override
  List<Object?> get props => [volume];
}

/// Event to toggle the mute state.
final class ToggleSettingsMute extends SettingsEvent {
  const ToggleSettingsMute();
}

/// Event to reset settings to defaults.
final class ResetSettings extends SettingsEvent {
  const ResetSettings();
}
