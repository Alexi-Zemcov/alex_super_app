import 'package:flutter_test/flutter_test.dart';
import 'package:my_instruments/my_instruments.dart';

void main() {
  test('saved instrument record supports json round-trip', () {
    final record = SavedInstrumentRecord(
      id: 'gtr-1',
      name: 'My Baritone',
      kind: SavedInstrumentKind.guitar,
      stringSetId: SavedStringSetId.k1,
      strings: const [
        SavedInstrumentString(
          noteLabel: 'B3',
          scaleLengthInches: 27,
          physicalStringId: 11,
          gaugeInches: 0.0135,
        ),
      ],
      createdAt: DateTime.parse('2026-04-19T10:00:00.000Z'),
      updatedAt: DateTime.parse('2026-04-19T10:30:00.000Z'),
    );

    final decoded = SavedInstrumentRecord.fromJson(record.toJson());

    expect(decoded, record);
  });
}
