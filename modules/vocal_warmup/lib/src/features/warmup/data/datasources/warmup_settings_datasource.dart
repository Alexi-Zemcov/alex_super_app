import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:vocal_warmup/src/features/warmup/domain/entities/warmup_settings.dart';

class WarmupSettingsDatasource {
  WarmupSettingsDatasource(this._prefs);

  static const String _storageKey = 'vocalWarmupSettings';

  final SharedPreferences _prefs;

  Future<WarmupSettings?> loadSettings() async {
    try {
      final rawValue = _prefs.getString(_storageKey);
      if (rawValue == null) {
        return null;
      }

      return WarmupSettings.fromJson(
        jsonDecode(rawValue) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  Future<bool> saveSettings(WarmupSettings settings) async {
    try {
      return _prefs.setString(_storageKey, jsonEncode(settings.toJson()));
    } catch (_) {
      return false;
    }
  }
}
