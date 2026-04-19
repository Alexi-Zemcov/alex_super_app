import 'package:string_tension_calculator/src/features/calculator/domain/entities/entities.dart';
import 'package:string_tension_calculator/src/features/calculator/domain/repositories/calculator_repository.dart';

class CalculatorEngine {
  const CalculatorEngine({required CalculatorRepository repository})
    : _repository = repository;

  static const double _tensionConstant = 386.4;

  final CalculatorRepository _repository;

  double frequencyHz(ScientificNote note) => note.frequencyHz;

  double tensionLbs({
    required StringSetId stringSetId,
    required InstrumentString string,
  }) {
    final physicalString = _repository.getPhysicalString(
      stringSetId,
      string.physicalStringId,
    );

    return roundToDecimals(
      (physicalString.unitWeight *
              _square(2 * string.scaleLengthInches * string.note.frequencyHz)) /
          _tensionConstant,
      2,
    );
  }

  RgbColor colorCode(InstrumentType instrumentType, double tensionLbs) {
    final baseline = switch (instrumentType) {
      InstrumentType.guitar => (regular: 19.0, delta: 11.0),
      InstrumentType.bass => (regular: 40.0, delta: 15.0),
    };

    final isHeavy = tensionLbs >= baseline.regular;
    final percent =
        ((tensionLbs - baseline.regular).abs() / (baseline.delta / 100)).clamp(
          0,
          100,
        ) /
        100;

    final maxed = isHeavy
        ? const RgbColor(red: 255, green: 0, blue: 0)
        : const RgbColor(red: 255, green: 255, blue: 0);

    return RgbColor(
      red: _blendChannel(maxed.red, percent),
      green: _blendChannel(maxed.green, percent),
      blue: _blendChannel(maxed.blue, percent),
    );
  }

  ScalePreset? findMatchingScalePreset(Instrument instrument) {
    final presets = _repository.getScalePresets(instrument.type);
    final currentScales = instrument.strings
        .map((string) => roundToDecimals(string.scaleLengthInches, 2))
        .toList(growable: false);

    for (final preset in presets) {
      final presetScales = preset.buildScales(instrument.strings.length);
      if (_listsEqual(presetScales, currentScales)) {
        return preset;
      }
    }

    return null;
  }

  CalculatorSnapshot toggleInstrument(CalculatorSnapshot snapshot) {
    return CalculatorSnapshot(
      currentInstrument: snapshot.otherInstrument,
      otherInstrument: snapshot.currentInstrument,
    );
  }

  CalculatorSnapshot applyScalePreset(
    CalculatorSnapshot snapshot,
    ScalePreset preset,
  ) {
    final updatedInstrument = _applyScalePreset(
      snapshot.currentInstrument,
      preset,
    );
    return snapshot.copyWith(currentInstrument: updatedInstrument);
  }

  CalculatorSnapshot changeStringSet(
    CalculatorSnapshot snapshot,
    StringSetId stringSetId,
  ) {
    final current = snapshot.currentInstrument;
    if (current.stringSetId == stringSetId) {
      return snapshot;
    }

    final remappedStrings = current.strings
        .map((string) {
          final currentPhysicalString = _repository.getPhysicalString(
            current.stringSetId,
            string.physicalStringId,
          );
          final targetSet = _repository.getStringSet(stringSetId);

          var bestMatch = targetSet.strings.first;
          var bestDelta =
              (bestMatch.gaugeInches - currentPhysicalString.gaugeInches).abs();

          for (final candidate in targetSet.strings.skip(1)) {
            final delta =
                (candidate.gaugeInches - currentPhysicalString.gaugeInches)
                    .abs();
            if (delta < bestDelta) {
              bestMatch = candidate;
              bestDelta = delta;
            }
          }

          return string.copyWith(physicalStringId: bestMatch.id);
        })
        .toList(growable: false);

    return snapshot.copyWith(
      currentInstrument: current.copyWith(
        stringSetId: stringSetId,
        strings: remappedStrings,
      ),
    );
  }

  CalculatorSnapshot incrementScaleAtIndex(
    CalculatorSnapshot snapshot,
    int index,
  ) => _changeScale(snapshot, index, 0.1);

  CalculatorSnapshot decrementScaleAtIndex(
    CalculatorSnapshot snapshot,
    int index,
  ) => _changeScale(snapshot, index, -0.1);

  CalculatorSnapshot incrementNoteAtIndex(
    CalculatorSnapshot snapshot,
    int index,
  ) => _changeNote(snapshot, index, true);

  CalculatorSnapshot decrementNoteAtIndex(
    CalculatorSnapshot snapshot,
    int index,
  ) => _changeNote(snapshot, index, false);

  CalculatorSnapshot incrementGaugeAtIndex(
    CalculatorSnapshot snapshot,
    int index,
  ) => _changeGauge(snapshot, index, true);

  CalculatorSnapshot decrementGaugeAtIndex(
    CalculatorSnapshot snapshot,
    int index,
  ) => _changeGauge(snapshot, index, false);

  CalculatorSnapshot addString(CalculatorSnapshot snapshot) {
    final current = snapshot.currentInstrument;
    final lastString = current.strings.last;
    var newNote = lastString.note;
    for (var i = 0; i < 5; i++) {
      newNote = newNote.previous();
    }

    final baseString = InstrumentString(
      note: newNote,
      scaleLengthInches: lastString.scaleLengthInches,
      physicalStringId: lastString.physicalStringId,
    );

    final referenceTension = tensionLbs(
      stringSetId: current.stringSetId,
      string: lastString,
    );

    final set = _repository.getStringSet(current.stringSetId);
    var bestString = baseString;
    var bestDelta = double.infinity;

    for (final physicalString in set.strings) {
      final candidate = baseString.copyWith(
        physicalStringId: physicalString.id,
      );
      final candidateTension = tensionLbs(
        stringSetId: current.stringSetId,
        string: candidate,
      );
      final delta = (referenceTension - candidateTension).abs();
      if (delta < bestDelta) {
        bestString = candidate;
        bestDelta = delta;
      }
    }

    return snapshot.copyWith(
      currentInstrument: current.copyWith(
        strings: [...current.strings, bestString],
      ),
    );
  }

  CalculatorSnapshot _changeScale(
    CalculatorSnapshot snapshot,
    int index,
    double delta,
  ) {
    return snapshot.copyWith(
      currentInstrument: _mapString(
        snapshot.currentInstrument,
        index,
        (string) => string.copyWith(
          scaleLengthInches: roundToDecimals(
            string.scaleLengthInches + delta,
            1,
          ),
        ),
      ),
    );
  }

  CalculatorSnapshot _changeNote(
    CalculatorSnapshot snapshot,
    int index,
    bool increment,
  ) {
    return snapshot.copyWith(
      currentInstrument: _mapString(
        snapshot.currentInstrument,
        index,
        (string) => string.copyWith(
          note: increment ? string.note.next() : string.note.previous(),
        ),
      ),
    );
  }

  CalculatorSnapshot _changeGauge(
    CalculatorSnapshot snapshot,
    int index,
    bool increment,
  ) {
    final current = snapshot.currentInstrument;
    final set = _repository.getStringSet(current.stringSetId);

    return snapshot.copyWith(
      currentInstrument: _mapString(current, index, (string) {
        final nextId = increment
            ? (string.physicalStringId + 1)
            : (string.physicalStringId - 1);
        if (nextId < 0 || nextId >= set.strings.length) {
          return string;
        }
        return string.copyWith(physicalStringId: nextId);
      }),
    );
  }

  Instrument _applyScalePreset(Instrument instrument, ScalePreset preset) {
    final scales = preset.buildScales(instrument.strings.length);
    final updatedStrings = List<InstrumentString>.generate(
      instrument.strings.length,
      (index) =>
          instrument.strings[index].copyWith(scaleLengthInches: scales[index]),
      growable: false,
    );

    return instrument.copyWith(strings: updatedStrings);
  }

  Instrument _mapString(
    Instrument instrument,
    int index,
    InstrumentString Function(InstrumentString string) mapper,
  ) {
    final updatedStrings = List<InstrumentString>.generate(
      instrument.strings.length,
      (itemIndex) => itemIndex == index
          ? mapper(instrument.strings[itemIndex])
          : instrument.strings[itemIndex],
      growable: false,
    );
    return instrument.copyWith(strings: updatedStrings);
  }

  static double _square(double value) => value * value;

  static int _blendChannel(int maxValue, double percent) {
    return (maxValue * percent + (255 - (percent * 255))).round();
  }

  static bool _listsEqual(List<double> left, List<double> right) {
    if (left.length != right.length) {
      return false;
    }

    for (var index = 0; index < left.length; index++) {
      if (left[index] != right[index]) {
        return false;
      }
    }

    return true;
  }
}
