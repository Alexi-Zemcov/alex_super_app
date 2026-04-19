import 'dart:async';
import 'dart:convert';

import 'package:my_instruments/my_instruments.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesMyInstrumentsRepository
    implements MyInstrumentsRepository {
  SharedPreferencesMyInstrumentsRepository({
    required SharedPreferences sharedPreferences,
    DateTime Function()? now,
    String Function()? idFactory,
  }) : _sharedPreferences = sharedPreferences,
       _now = now ?? DateTime.now,
       _idFactory = idFactory;

  static const storageKey = 'myInstruments.v1';

  final SharedPreferences _sharedPreferences;
  final DateTime Function() _now;
  final String Function()? _idFactory;
  final StreamController<List<SavedInstrumentRecord>> _controller =
      StreamController<List<SavedInstrumentRecord>>.broadcast(sync: true);

  List<SavedInstrumentRecord>? _cachedRecords;

  @override
  Future<SavedInstrumentRecord> createRecord({
    required String name,
    required SavedInstrumentKind kind,
    required SavedStringSetId stringSetId,
    required List<SavedInstrumentString> strings,
  }) async {
    final createdAt = _now();
    final record = SavedInstrumentRecord(
      id: _idFactory?.call() ?? createdAt.microsecondsSinceEpoch.toString(),
      name: name,
      kind: kind,
      stringSetId: stringSetId,
      strings: strings,
      createdAt: createdAt,
      updatedAt: createdAt,
    );

    final updatedRecords = [..._loadRecords(), record];
    await _persistRecords(updatedRecords);
    return record;
  }

  @override
  List<SavedInstrumentRecord> getRecords() {
    return List<SavedInstrumentRecord>.unmodifiable(_loadRecords());
  }

  @override
  Future<SavedInstrumentRecord> updateRecord({
    required String id,
    required String name,
    required SavedInstrumentKind kind,
    required SavedStringSetId stringSetId,
    required List<SavedInstrumentString> strings,
  }) async {
    final records = _loadRecords();
    final index = records.indexWhere((record) => record.id == id);
    if (index == -1) {
      throw StateError('Saved instrument not found: $id');
    }

    final updatedRecord = records[index].copyWith(
      name: name,
      kind: kind,
      stringSetId: stringSetId,
      strings: strings,
      updatedAt: _now(),
    );

    final updatedRecords = [...records]..[index] = updatedRecord;
    await _persistRecords(updatedRecords);
    return updatedRecord;
  }

  @override
  Stream<List<SavedInstrumentRecord>> watchRecords() {
    return Stream<List<SavedInstrumentRecord>>.multi((controller) {
      controller.add(getRecords());
      final subscription = _controller.stream.listen(
        controller.add,
        onError: controller.addError,
      );
      controller.onCancel = subscription.cancel;
    }, isBroadcast: true);
  }

  List<SavedInstrumentRecord> _decodeRecords(String rawJson) {
    try {
      final decoded = jsonDecode(rawJson);
      if (decoded is! List<dynamic>) {
        return const [];
      }

      return decoded
          .map(
            (item) => SavedInstrumentRecord.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(growable: false);
    } on FormatException {
      return const [];
    }
  }

  List<SavedInstrumentRecord> _loadRecords() {
    final cachedRecords = _cachedRecords;
    if (cachedRecords != null) {
      return cachedRecords;
    }

    final rawJson = _sharedPreferences.getString(storageKey);
    if (rawJson == null || rawJson.isEmpty) {
      _cachedRecords = const [];
      return _cachedRecords!;
    }

    _cachedRecords = _sortRecords(_decodeRecords(rawJson));
    return _cachedRecords!;
  }

  Future<void> _persistRecords(List<SavedInstrumentRecord> records) async {
    final sortedRecords = _sortRecords(records);
    _cachedRecords = sortedRecords;
    await _sharedPreferences.setString(
      storageKey,
      jsonEncode(
        sortedRecords.map((record) => record.toJson()).toList(growable: false),
      ),
    );
    _controller.add(getRecords());
  }

  List<SavedInstrumentRecord> _sortRecords(
    List<SavedInstrumentRecord> records,
  ) {
    final sortedRecords = [...records]
      ..sort((left, right) => right.updatedAt.compareTo(left.updatedAt));
    return List<SavedInstrumentRecord>.unmodifiable(sortedRecords);
  }
}
