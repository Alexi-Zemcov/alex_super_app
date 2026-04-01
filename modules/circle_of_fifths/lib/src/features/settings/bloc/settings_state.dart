import 'package:circle_of_fifths/src/features/settings/domain/domain.dart';
import 'package:equatable/equatable.dart';

/// Base sealed class for settings feature states.
sealed class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

/// Initial state when the app starts, before loading settings.
final class SettingsStateInitial extends SettingsState {
  const SettingsStateInitial();

  @override
  List<Object?> get props => [];
}

/// State while settings are being loaded from storage.
final class SettingsStateLoading extends SettingsState {
  const SettingsStateLoading();

  @override
  List<Object?> get props => [];
}

/// State when settings have been successfully loaded.
final class SettingsStateLoaded extends SettingsState {
  const SettingsStateLoaded(this.settings, {this.isMuted = false});

  /// Current settings.
  final Settings settings;

  /// Whether the sound is muted.
  final bool isMuted;

  /// Creates a copy of this state with the given fields replaced.
  SettingsStateLoaded copyWith({Settings? settings, bool? isMuted}) {
    return SettingsStateLoaded(
      settings ?? this.settings,
      isMuted: isMuted ?? this.isMuted,
    );
  }

  @override
  List<Object?> get props => [settings, isMuted];
}
