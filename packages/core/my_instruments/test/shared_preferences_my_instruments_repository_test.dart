import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_instruments/my_instruments.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('SharedPreferencesMyInstrumentsRepository', () {
    test('returns empty list for empty storage', () async {
      SharedPreferences.setMockInitialValues({});
      final sharedPreferences = await SharedPreferences.getInstance();
      final repository = SharedPreferencesMyInstrumentsRepository(
        sharedPreferences: sharedPreferences,
      );

      expect(repository.getRecords(), isEmpty);
    });

    test('create stores record and sorts by updatedAt desc', () async {
      SharedPreferences.setMockInitialValues({});
      final sharedPreferences = await SharedPreferences.getInstance();
      final times = <DateTime>[
        DateTime.parse('2026-04-19T10:00:00.000Z'),
        DateTime.parse('2026-04-19T11:00:00.000Z'),
      ];
      var timeIndex = 0;
      final repository = SharedPreferencesMyInstrumentsRepository(
        sharedPreferences: sharedPreferences,
        now: () => times[timeIndex++],
        idFactory: () => 'id-$timeIndex',
      );

      await repository.createRecord(
        name: 'First',
        kind: SavedInstrumentKind.guitar,
        stringSetId: SavedStringSetId.dxl,
        strings: const [],
      );
      await repository.createRecord(
        name: 'Second',
        kind: SavedInstrumentKind.bass,
        stringSetId: SavedStringSetId.k1,
        strings: const [],
      );

      expect(repository.getRecords().map((record) => record.name).toList(), [
        'Second',
        'First',
      ]);
    });

    test('update changes existing record without changing id', () async {
      SharedPreferences.setMockInitialValues({});
      final sharedPreferences = await SharedPreferences.getInstance();
      final times = <DateTime>[
        DateTime.parse('2026-04-19T10:00:00.000Z'),
        DateTime.parse('2026-04-19T12:00:00.000Z'),
      ];
      var timeIndex = 0;
      final repository = SharedPreferencesMyInstrumentsRepository(
        sharedPreferences: sharedPreferences,
        now: () => times[timeIndex++],
        idFactory: () => 'saved-1',
      );

      final created = await repository.createRecord(
        name: 'Original',
        kind: SavedInstrumentKind.guitar,
        stringSetId: SavedStringSetId.dxl,
        strings: const [],
      );

      final updated = await repository.updateRecord(
        id: created.id,
        name: 'Updated',
        kind: SavedInstrumentKind.bass,
        stringSetId: SavedStringSetId.k1,
        strings: const [],
      );

      expect(updated.id, created.id);
      expect(updated.name, 'Updated');
      expect(updated.kind, SavedInstrumentKind.bass);
      expect(updated.updatedAt, times.last);
    });

    test('watch emits initial state and subsequent changes', () async {
      SharedPreferences.setMockInitialValues({});
      final sharedPreferences = await SharedPreferences.getInstance();
      final repository = SharedPreferencesMyInstrumentsRepository(
        sharedPreferences: sharedPreferences,
        now: () => DateTime.parse('2026-04-19T10:00:00.000Z'),
        idFactory: () => 'stream-id',
      );

      final emitted = <List<SavedInstrumentRecord>>[];
      final completer = Completer<void>();
      final subscription = repository.watchRecords().listen((records) {
        emitted.add(records);
        if (emitted.length == 2 && !completer.isCompleted) {
          completer.complete();
        }
      });

      await repository.createRecord(
        name: 'Streamed',
        kind: SavedInstrumentKind.guitar,
        stringSetId: SavedStringSetId.dxl,
        strings: const [],
      );

      await completer.future;
      await subscription.cancel();

      expect(emitted[0], isEmpty);
      expect(emitted[1].single.name, 'Streamed');
    });
  });
}
