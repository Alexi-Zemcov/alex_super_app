import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:string_tension_calculator/src/features/calculator/data/datasources/calculator_catalog_datasource.dart';
import 'package:string_tension_calculator/src/features/calculator/data/repositories/local_calculator_repository.dart';
import 'package:string_tension_calculator/src/features/calculator/domain/entities/entities.dart';
import 'package:string_tension_calculator/src/features/calculator/domain/services/calculator_engine.dart';

void main() {
  const dataSource = CalculatorCatalogDataSource();
  const repository = LocalCalculatorRepository(dataSource: dataSource);
  const engine = CalculatorEngine(repository: repository);

  group('ScientificNote', () {
    test('parses and formats scientific notation', () {
      final note = ScientificNote.parse('F#3');

      expect(note.note, MusicalNote.fSharp);
      expect(note.octave, 3);
      expect(note.label, 'F#3');
      expect(note.midi, 54);
    });

    test('converts from midi and calculates frequency', () {
      expect(
        ScientificNote.fromMidi(69),
        const ScientificNote(note: MusicalNote.a, octave: 4),
      );
      expect(
        const ScientificNote(note: MusicalNote.a, octave: 4).frequencyHz,
        closeTo(440, 0.000001),
      );
      expect(
        ScientificNote.parse('C4').frequencyHz,
        closeTo(261.625565, 0.000001),
      );
    });

    test('clamps note changes to midi range', () {
      expect(ScientificNote.fromMidi(0).previous(), ScientificNote.fromMidi(0));
      expect(ScientificNote.fromMidi(127).next(), ScientificNote.fromMidi(127));
    });
  });

  group('CalculatorEngine', () {
    test('formats gauges with source precision', () {
      expect(formatGauge(0.009), '0.009');
      expect(formatGauge(0.013), '0.013');
      expect(formatGauge(0.0085), '0.0085');
      expect(formatGauge(0.110), '0.110');
    });

    test('calculates tension with site formula and rounds to 2 decimals', () {
      final snapshot = repository.buildDefaultSnapshot();
      final string = snapshot.currentInstrument.strings.first;
      final physical = repository.getPhysicalString(
        snapshot.currentInstrument.stringSetId,
        string.physicalStringId,
      );

      final expected = roundToDecimals(
        (physical.unitWeight *
                math.pow(
                  2 * string.scaleLengthInches * string.note.frequencyHz,
                  2,
                )) /
            386.4,
        2,
      );

      expect(
        engine.tensionLbs(
          stringSetId: snapshot.currentInstrument.stringSetId,
          string: string,
        ),
        expected,
      );
    });

    test('builds single-scale and multiscale presets', () {
      expect(const ScalePreset.single(25.5).buildScales(6), [
        25.5,
        25.5,
        25.5,
        25.5,
        25.5,
        25.5,
      ]);
      expect(const ScalePreset.multiscale(25.5, 27).buildScales(6), [
        25.5,
        25.8,
        26.1,
        26.4,
        26.7,
        27,
      ]);
    });

    test('applies scale and note steps and keeps gauge at boundaries', () {
      final snapshot = repository.buildDefaultSnapshot();
      final scaledUp = engine.incrementScaleAtIndex(snapshot, 0);
      final scaledDown = engine.decrementScaleAtIndex(snapshot, 0);

      expect(scaledUp.currentInstrument.strings.first.scaleLengthInches, 25.6);
      expect(
        scaledDown.currentInstrument.strings.first.scaleLengthInches,
        25.4,
      );

      final lowNoteSnapshot = snapshot.copyWith(
        currentInstrument: snapshot.currentInstrument.copyWith(
          strings: [
            snapshot.currentInstrument.strings.first.copyWith(
              note: ScientificNote.fromMidi(0),
            ),
            ...snapshot.currentInstrument.strings.skip(1),
          ],
        ),
      );

      expect(
        engine
            .decrementNoteAtIndex(lowNoteSnapshot, 0)
            .currentInstrument
            .strings
            .first
            .note,
        ScientificNote.fromMidi(0),
      );

      final stringSet = repository.getStringSet(StringSetId.dxl);
      final gaugeBoundarySnapshot = snapshot.copyWith(
        currentInstrument: snapshot.currentInstrument.copyWith(
          strings: [
            snapshot.currentInstrument.strings.first.copyWith(
              physicalStringId: 0,
            ),
            snapshot.currentInstrument.strings[1].copyWith(
              physicalStringId: stringSet.strings.length - 1,
            ),
            ...snapshot.currentInstrument.strings.skip(2),
          ],
        ),
      );

      expect(
        engine
            .decrementGaugeAtIndex(gaugeBoundarySnapshot, 0)
            .currentInstrument
            .strings[0]
            .physicalStringId,
        0,
      );
      expect(
        engine
            .incrementGaugeAtIndex(gaugeBoundarySnapshot, 1)
            .currentInstrument
            .strings[1]
            .physicalStringId,
        stringSet.strings.length - 1,
      );
    });

    test('remaps string set by nearest gauge', () {
      final snapshot = repository.buildDefaultSnapshot();
      final remapped = engine.changeStringSet(snapshot, StringSetId.k1);
      final targetSet = repository.getStringSet(StringSetId.k1);

      for (
        var index = 0;
        index < snapshot.currentInstrument.strings.length;
        index++
      ) {
        final originalString = snapshot.currentInstrument.strings[index];
        final remappedString = remapped.currentInstrument.strings[index];
        final originalGauge = repository
            .getPhysicalString(StringSetId.dxl, originalString.physicalStringId)
            .gaugeInches;
        final remappedGauge = repository
            .getPhysicalString(StringSetId.k1, remappedString.physicalStringId)
            .gaugeInches;

        final nearestGauge = targetSet.strings
            .map((candidate) => candidate.gaugeInches)
            .reduce((best, candidate) {
              final bestDelta = (best - originalGauge).abs();
              final candidateDelta = (candidate - originalGauge).abs();
              return candidateDelta < bestDelta ? candidate : best;
            });

        expect(remappedGauge, nearestGauge);
      }
    });

    test('adds a new string by lowering note and minimizing tension delta', () {
      final snapshot = repository.buildDefaultSnapshot();
      final added = engine.addString(snapshot);
      final previousLast = snapshot.currentInstrument.strings.last;
      final appended = added.currentInstrument.strings.last;
      final stringSet = repository.getStringSet(
        snapshot.currentInstrument.stringSetId,
      );

      var expectedNote = previousLast.note;
      for (var i = 0; i < 5; i++) {
        expectedNote = expectedNote.previous();
      }

      final referenceTension = engine.tensionLbs(
        stringSetId: snapshot.currentInstrument.stringSetId,
        string: previousLast,
      );

      var expectedPhysicalStringId = previousLast.physicalStringId;
      var bestDelta = double.infinity;

      for (final physical in stringSet.strings) {
        final candidate = previousLast.copyWith(
          note: expectedNote,
          physicalStringId: physical.id,
        );
        final delta =
            (engine.tensionLbs(
                      stringSetId: snapshot.currentInstrument.stringSetId,
                      string: candidate,
                    ) -
                    referenceTension)
                .abs();

        if (delta < bestDelta) {
          expectedPhysicalStringId = physical.id;
          bestDelta = delta;
        }
      }

      expect(added.currentInstrument.strings, hasLength(7));
      expect(appended.scaleLengthInches, previousLast.scaleLengthInches);
      expect(appended.note, expectedNote);
      expect(appended.physicalStringId, expectedPhysicalStringId);
    });

    test('uses expected color thresholds for guitar and bass', () {
      expect(
        engine.colorCode(InstrumentType.guitar, 8),
        const RgbColor(red: 255, green: 255, blue: 0),
      );
      expect(
        engine.colorCode(InstrumentType.guitar, 19),
        const RgbColor(red: 255, green: 255, blue: 255),
      );
      expect(
        engine.colorCode(InstrumentType.guitar, 30),
        const RgbColor(red: 255, green: 0, blue: 0),
      );
      expect(
        engine.colorCode(InstrumentType.bass, 25),
        const RgbColor(red: 255, green: 255, blue: 0),
      );
      expect(
        engine.colorCode(InstrumentType.bass, 40),
        const RgbColor(red: 255, green: 255, blue: 255),
      );
      expect(
        engine.colorCode(InstrumentType.bass, 55),
        const RgbColor(red: 255, green: 0, blue: 0),
      );
    });
  });
}
