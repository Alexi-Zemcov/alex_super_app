import 'package:equatable/equatable.dart';
import 'package:string_tension_calculator/src/features/calculator/domain/entities/catalog_models.dart';
import 'package:string_tension_calculator/src/features/calculator/domain/entities/note.dart';

class InstrumentString extends Equatable {
  const InstrumentString({
    required this.note,
    required this.scaleLengthInches,
    required this.physicalStringId,
  });

  final ScientificNote note;
  final double scaleLengthInches;
  final int physicalStringId;

  InstrumentString copyWith({
    ScientificNote? note,
    double? scaleLengthInches,
    int? physicalStringId,
  }) {
    return InstrumentString(
      note: note ?? this.note,
      scaleLengthInches: scaleLengthInches ?? this.scaleLengthInches,
      physicalStringId: physicalStringId ?? this.physicalStringId,
    );
  }

  @override
  List<Object?> get props => [note, scaleLengthInches, physicalStringId];
}

class Instrument extends Equatable {
  const Instrument({
    required this.type,
    required this.stringSetId,
    required this.strings,
  });

  final InstrumentType type;
  final StringSetId stringSetId;
  final List<InstrumentString> strings;

  Instrument copyWith({
    InstrumentType? type,
    StringSetId? stringSetId,
    List<InstrumentString>? strings,
  }) {
    return Instrument(
      type: type ?? this.type,
      stringSetId: stringSetId ?? this.stringSetId,
      strings: strings ?? this.strings,
    );
  }

  @override
  List<Object?> get props => [type, stringSetId, strings];
}

class CalculatorSnapshot extends Equatable {
  const CalculatorSnapshot({
    required this.currentInstrument,
    required this.otherInstrument,
  });

  final Instrument currentInstrument;
  final Instrument otherInstrument;

  CalculatorSnapshot copyWith({
    Instrument? currentInstrument,
    Instrument? otherInstrument,
  }) {
    return CalculatorSnapshot(
      currentInstrument: currentInstrument ?? this.currentInstrument,
      otherInstrument: otherInstrument ?? this.otherInstrument,
    );
  }

  @override
  List<Object?> get props => [currentInstrument, otherInstrument];
}
