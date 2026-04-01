import 'dart:convert';

import 'package:circle_of_fifths/src/features/settings/domain/entities/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Datasource for managing settings storage.
///
/// Handles direct interaction with SharedPreferences for loading
/// and saving application settings.
class SettingsDatasource {
  final SharedPreferences _prefs;

  static const String _storageKey = 'circleOfFifthsSettings';

  SettingsDatasource(this._prefs);

  /// Loads settings from SharedPreferences.
  ///
  /// Returns the stored settings, or null if no settings exist.
  Future<Settings?> loadSettings() async {
    try {
      final jsonString = _prefs.getString(_storageKey);

      if (jsonString != null) {
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        return Settings.fromJson(json);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Saves settings to SharedPreferences.
  ///
  /// Returns true if successful, false otherwise.
  Future<bool> saveSettings(Settings settings) async {
    try {
      final jsonString = jsonEncode(settings.toJson());
      return await _prefs.setString(_storageKey, jsonString);
    } catch (e) {
      return false;
    }
  }
}
