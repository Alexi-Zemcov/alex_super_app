import 'dart:async';

import 'package:my_instruments/my_instruments.dart';

class FakeMyInstrumentsRepository implements MyInstrumentsRepository {
  FakeMyInstrumentsRepository({
    List<SavedInstrumentRecord> initialRecords = const [],
    DateTime Function()? now,
  }) : _records = _sortRecords(initialRecords),
       _now = now ?? DateTime.now;

  final DateTime Function() _now;
  final StreamController<List<SavedInstrumentRecord>> _controller =
      StreamController<List<SavedInstrumentRecord>>.broadcast(sync: true);

  List<SavedInstrumentRecord> _records;
  var _nextId = 1;

  @override
  Future<SavedInstrumentRecord> createRecord({
    required String name,
    required SavedInstrumentKind kind,
    required SavedStringSetId stringSetId,
    required List<SavedInstrumentString> strings,
  }) async {
    final timestamp = _now();
    final record = SavedInstrumentRecord(
      id: 'fake-${_nextId++}',
      name: name,
      kind: kind,
      stringSetId: stringSetId,
      strings: strings,
      createdAt: timestamp,
      updatedAt: timestamp,
    );
    _records = _sortRecords([..._records, record]);
    _controller.add(getRecords());
    return record;
  }

  @override
  List<SavedInstrumentRecord> getRecords() {
    return List<SavedInstrumentRecord>.unmodifiable(_records);
  }

  @override
  Future<SavedInstrumentRecord> updateRecord({
    required String id,
    required String name,
    required SavedInstrumentKind kind,
    required SavedStringSetId stringSetId,
    required List<SavedInstrumentString> strings,
  }) async {
    final index = _records.indexWhere((record) => record.id == id);
    if (index == -1) {
      throw StateError('Saved instrument not found: $id');
    }

    final updatedRecord = _records[index].copyWith(
      name: name,
      kind: kind,
      stringSetId: stringSetId,
      strings: strings,
      updatedAt: _now(),
    );
    _records = _sortRecords([..._records]..[index] = updatedRecord);
    _controller.add(getRecords());
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

  static List<SavedInstrumentRecord> _sortRecords(
    List<SavedInstrumentRecord> records,
  ) {
    final sortedRecords = [...records]
      ..sort((left, right) => right.updatedAt.compareTo(left.updatedAt));
    return List<SavedInstrumentRecord>.unmodifiable(sortedRecords);
  }
}

SavedInstrumentRecord buildSavedInstrumentRecord({
  required String id,
  required String name,
  required SavedInstrumentKind kind,
  required SavedStringSetId stringSetId,
  List<SavedInstrumentString>? strings,
  DateTime? createdAt,
  DateTime? updatedAt,
}) {
  final timestamp = createdAt ?? DateTime.parse('2026-04-19T10:00:00.000Z');
  return SavedInstrumentRecord(
    id: id,
    name: name,
    kind: kind,
    stringSetId: stringSetId,
    strings:
        strings ??
        switch (kind) {
          SavedInstrumentKind.guitar => const [
            SavedInstrumentString(
              noteLabel: 'E4',
              scaleLengthInches: 25.5,
              physicalStringId: 2,
              gaugeInches: 0.009,
            ),
            SavedInstrumentString(
              noteLabel: 'B3',
              scaleLengthInches: 25.5,
              physicalStringId: 9,
              gaugeInches: 0.013,
            ),
            SavedInstrumentString(
              noteLabel: 'G3',
              scaleLengthInches: 25.5,
              physicalStringId: 14,
              gaugeInches: 0.017,
            ),
            SavedInstrumentString(
              noteLabel: 'D3',
              scaleLengthInches: 25.5,
              physicalStringId: 22,
              gaugeInches: 0.026,
            ),
            SavedInstrumentString(
              noteLabel: 'A2',
              scaleLengthInches: 25.5,
              physicalStringId: 28,
              gaugeInches: 0.037,
            ),
            SavedInstrumentString(
              noteLabel: 'E2',
              scaleLengthInches: 25.5,
              physicalStringId: 36,
              gaugeInches: 0.049,
            ),
          ],
          SavedInstrumentKind.bass => const [
            SavedInstrumentString(
              noteLabel: 'G2',
              scaleLengthInches: 34,
              physicalStringId: 34,
              gaugeInches: 0.037,
            ),
            SavedInstrumentString(
              noteLabel: 'D2',
              scaleLengthInches: 34,
              physicalStringId: 41,
              gaugeInches: 0.051,
            ),
            SavedInstrumentString(
              noteLabel: 'A1',
              scaleLengthInches: 34,
              physicalStringId: 51,
              gaugeInches: 0.073,
            ),
            SavedInstrumentString(
              noteLabel: 'E1',
              scaleLengthInches: 34,
              physicalStringId: 61,
              gaugeInches: 0.110,
            ),
          ],
        },
    createdAt: timestamp,
    updatedAt: updatedAt ?? timestamp,
  );
}
