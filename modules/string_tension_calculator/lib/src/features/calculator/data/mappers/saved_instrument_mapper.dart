import 'package:my_instruments/my_instruments.dart';
import 'package:string_tension_calculator/src/features/calculator/domain/entities/entities.dart';
import 'package:string_tension_calculator/src/features/calculator/domain/repositories/calculator_repository.dart';

class SavedInstrumentMapper {
  const SavedInstrumentMapper({required CalculatorRepository repository})
    : _repository = repository;

  final CalculatorRepository _repository;

  SavedInstrumentKind savedKindFromInstrumentType(InstrumentType type) {
    return switch (type) {
      InstrumentType.guitar => SavedInstrumentKind.guitar,
      InstrumentType.bass => SavedInstrumentKind.bass,
    };
  }

  SavedStringSetId savedStringSetIdFromInstrument(StringSetId stringSetId) {
    return switch (stringSetId) {
      StringSetId.dxl => SavedStringSetId.dxl,
      StringSetId.k1 => SavedStringSetId.k1,
    };
  }

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
