import 'package:circle_of_fifths/src/features/settings/domain/entities/notation_preference.dart';
import 'package:equatable/equatable.dart';

/// Application settings entity.
class Settings extends Equatable {
  const Settings({
    required this.notationPreference,
    required this.masterVolume,
  });

  /// Preference for displaying musical notation.
  final NotationPreference notationPreference;

  /// Master volume level (0.0 to 1.0).
  final double masterVolume;

  /// Default settings.
  static const Settings defaults = Settings(
    notationPreference: NotationPreference.automatic,
    masterVolume: 0.7,
  );

  /// Creates a copy of this Settings with the given fields replaced.
  Settings copyWith({
    NotationPreference? notationPreference,
    double? masterVolume,
  }) {
    return Settings(
      notationPreference: notationPreference ?? this.notationPreference,
      masterVolume: masterVolume ?? this.masterVolume,
    );
  }

  /// Converts settings to a JSON map for persistence.
  Map<String, dynamic> toJson() {
    return {
      'notationPreference': notationPreference.index,
      'masterVolume': masterVolume,
    };
  }

  /// Creates settings from a JSON map.
  factory Settings.fromJson(Map<String, dynamic> json) {
    return Settings(
      notationPreference:
          NotationPreference.values[json['notationPreference'] as int? ??
              defaults.notationPreference.index],
      masterVolume: json['masterVolume'] as double? ?? defaults.masterVolume,
    );
  }

  @override
  List<Object?> get props => [notationPreference, masterVolume];
}
