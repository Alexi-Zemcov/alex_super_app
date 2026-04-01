import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

abstract interface class ProgressLocalDataSource {
  Future<Map<String, Map<String, dynamic>>> loadQuestionStats();

  Future<void> saveQuestionStats(Map<String, Map<String, dynamic>> stats);

  Future<Set<String>> loadFavorites();

  Future<void> saveFavorites(Set<String> favorites);

  Future<Map<String, dynamic>?> loadTicketSession();

  Future<void> saveTicketSession(Map<String, dynamic> session);

  Future<void> clearTicketSession();
}

class SharedPreferencesProgressLocalDataSource
    implements ProgressLocalDataSource {
  SharedPreferencesProgressLocalDataSource({
    required SharedPreferences sharedPreferences,
  }) : _sharedPreferences = sharedPreferences;

  static const storageKey = 'flutterQuizStats';
  static const favoritesStorageKey = 'flutterQuizFavorites';
  static const sessionStorageKey = 'flutterQuizSession';

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

  @override
  Future<void> saveQuestionStats(Map<String, Map<String, dynamic>> stats) {
    return _sharedPreferences.setString(storageKey, jsonEncode(stats));
  }

  @override
  Future<Set<String>> loadFavorites() async {
    final rawFavorites = _sharedPreferences.getString(favoritesStorageKey);
    if (rawFavorites == null || rawFavorites.isEmpty) {
      return <String>{};
    }

    try {
      final decoded = jsonDecode(rawFavorites);
      if (decoded is! List<dynamic>) {
        return <String>{};
      }

      return decoded.map((item) => item.toString()).toSet();
    } on FormatException {
      return <String>{};
    }
  }

  @override
  Future<void> saveFavorites(Set<String> favorites) {
    return _sharedPreferences.setString(
      favoritesStorageKey,
      jsonEncode(favorites.toList(growable: false)),
    );
  }

  @override
  Future<Map<String, dynamic>?> loadTicketSession() async {
    final rawSession = _sharedPreferences.getString(sessionStorageKey);
    if (rawSession == null || rawSession.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(rawSession);
      if (decoded is! Map<dynamic, dynamic>) {
        return null;
      }

      return Map<String, dynamic>.from(decoded);
    } on FormatException {
      return null;
    }
  }

  @override
  Future<void> saveTicketSession(Map<String, dynamic> session) {
    return _sharedPreferences.setString(sessionStorageKey, jsonEncode(session));
  }

  @override
  Future<void> clearTicketSession() {
    return _sharedPreferences.remove(sessionStorageKey);
  }
}
