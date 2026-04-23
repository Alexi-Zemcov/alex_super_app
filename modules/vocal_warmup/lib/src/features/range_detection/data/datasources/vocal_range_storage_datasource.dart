import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

abstract interface class VocalRangeStorageDataSource {
  Future<Map<String, dynamic>?> loadRange();

  Future<void> saveRange(Map<String, dynamic> json);
}

class SharedPreferencesVocalRangeStorageDataSource
    implements VocalRangeStorageDataSource {
  const SharedPreferencesVocalRangeStorageDataSource(this._preferences);

  static const storageKey = 'vocalWarmupRange';

  final SharedPreferences _preferences;

  @override
  Future<Map<String, dynamic>?> loadRange() async {
    final rawRange = _preferences.getString(storageKey);
    if (rawRange == null) {
      return null;
    }

    try {
      final decoded = jsonDecode(rawRange);
      if (decoded is! Map<dynamic, dynamic>) {
        return null;
      }

      return Map<String, dynamic>.from(decoded);
    } on FormatException {
      return null;
    }
  }

  @override
  Future<void> saveRange(Map<String, dynamic> json) {
    return _preferences.setString(storageKey, jsonEncode(json));
  }
}
