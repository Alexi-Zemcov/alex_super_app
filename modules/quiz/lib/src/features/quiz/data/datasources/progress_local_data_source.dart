import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

abstract interface class ProgressLocalDataSource {
  Future<Map<String, Map<String, dynamic>>> loadQuestionStats();
}

class SharedPreferencesProgressLocalDataSource
    implements ProgressLocalDataSource {
  SharedPreferencesProgressLocalDataSource({
    required SharedPreferences sharedPreferences,
  }) : _sharedPreferences = sharedPreferences;

  static const storageKey = 'flutterQuizStats';

  final SharedPreferences _sharedPreferences;

  @override
  Future<Map<String, Map<String, dynamic>>> loadQuestionStats() async {
    final rawStats = _sharedPreferences.getString(storageKey);
    if (rawStats == null || rawStats.isEmpty) {
      return const {};
    }

    try {
      final decoded = jsonDecode(rawStats);
      if (decoded is! Map<dynamic, dynamic>) {
        return const {};
      }

      final result = <String, Map<String, dynamic>>{};
      for (final entry in decoded.entries) {
        final key = entry.key;
        final value = entry.value;
        if (key is String && value is Map<dynamic, dynamic>) {
          result[key] = Map<String, dynamic>.from(value);
        }
      }

      return result;
    } on FormatException {
      return const {};
    }
  }
}
