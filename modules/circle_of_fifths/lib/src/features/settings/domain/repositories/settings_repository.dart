import 'package:circle_of_fifths/src/features/settings/domain/entities/settings.dart';

/// Repository interface for managing application settings.
///
/// This defines the contract for loading and saving settings,
/// to be implemented in the data layer.
abstract class SettingsRepository {
  /// Loads settings from persistent storage.
  ///
  /// Returns the stored settings, or null if no settings have been saved yet.
  Future<Settings?> loadSettings();

  /// Saves settings to persistent storage.
  ///
  /// Returns true if the save was successful, false otherwise.
  Future<bool> saveSettings(Settings settings);
}
