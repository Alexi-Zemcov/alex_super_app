import 'package:my_instruments/my_instruments.dart';
import 'package:string_tension_calculator/src/features/calculator/domain/entities/entities.dart';
import 'package:string_tension_calculator/src/features/calculator/domain/repositories/calculator_repository.dart';
import 'package:string_tension_calculator/src/features/calculator/domain/services/saved_instrument_converter.dart';

class SavedInstrumentMapper implements SavedInstrumentConverter {
  const SavedInstrumentMapper({required CalculatorRepository repository})
    : _repository = repository;

  final CalculatorRepository _repository;

  SavedInstrumentKind savedKindFromInstrumentType(InstrumentType type) {
    return switch (type) {
      InstrumentType.guitar => SavedInstrumentKind.guitar,
      InstrumentType.bass => SavedInstrumentKind.bass,
    };
  }

  @override
  SavedStringSetId savedStringSetIdFromInstrument(StringSetId stringSetId) {
    return switch (stringSetId) {
      StringSetId.dxl => SavedStringSetId.dxl,
      StringSetId.k1 => SavedStringSetId.k1,
    };
  }

  @override
  Instrument toInstrument(SavedInstrumentRecord record) {
    return Instrument(
      type: instrumentTypeFromSavedKind(record.kind),
      stringSetId: stringSetIdFromSaved(record.stringSetId),
      strings: record.strings
          .map(
            (item) => InstrumentString(
              note: ScientificNote.parse(item.noteLabel),
              scaleLengthInches: item.scaleLengthInches,
              physicalStringId: item.physicalStringId,
            ),
          )
          .toList(growable: false),
    );
  }

  @override
  List<SavedInstrumentString> toSavedStrings(Instrument instrument) {
    return instrument.strings
        .map((string) {
          final physicalString = _repository.getPhysicalString(
            instrument.stringSetId,
            string.physicalStringId,
          );

          return SavedInstrumentString(
            noteLabel: string.note.label,
            scaleLengthInches: string.scaleLengthInches,
            physicalStringId: string.physicalStringId,
            gaugeInches: physicalString.gaugeInches,
          );
        })
        .toList(growable: false);
  }

  @override
  InstrumentType instrumentTypeFromSavedKind(SavedInstrumentKind kind) {
    return switch (kind) {
      SavedInstrumentKind.guitar => InstrumentType.guitar,
      SavedInstrumentKind.bass => InstrumentType.bass,
    };
  }

  StringSetId stringSetIdFromSaved(SavedStringSetId stringSetId) {
    return switch (stringSetId) {
      SavedStringSetId.dxl => StringSetId.dxl,
      SavedStringSetId.k1 => StringSetId.k1,
    };
  }
}
