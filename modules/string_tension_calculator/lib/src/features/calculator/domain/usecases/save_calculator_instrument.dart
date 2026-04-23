import 'package:my_instruments/my_instruments.dart';
import 'package:string_tension_calculator/src/features/calculator/domain/entities/entities.dart';
import 'package:string_tension_calculator/src/features/calculator/domain/services/saved_instrument_converter.dart';

enum SaveCalculatorInstrumentMode { create, update }

class SaveCalculatorInstrument {
  const SaveCalculatorInstrument({
    required MyInstrumentsRepository repository,
    required SavedInstrumentConverter converter,
  }) : _repository = repository,
       _converter = converter;

  final MyInstrumentsRepository _repository;
  final SavedInstrumentConverter _converter;

  Future<SavedInstrumentRecord> call({
    required SaveCalculatorInstrumentMode mode,
    required Instrument instrument,
    required String name,
    required SavedInstrumentKind kind,
    String? existingRecordId,
  }) {
    final normalizedInstrument = instrument.copyWith(
      type: _converter.instrumentTypeFromSavedKind(kind),
    );
    final stringSetId = _converter.savedStringSetIdFromInstrument(
      normalizedInstrument.stringSetId,
    );
    final strings = _converter.toSavedStrings(normalizedInstrument);

    return switch (mode) {
      SaveCalculatorInstrumentMode.create => _repository.createRecord(
        name: name,
        kind: kind,
        stringSetId: stringSetId,
        strings: strings,
      ),
      SaveCalculatorInstrumentMode.update => _repository.updateRecord(
        id:
            existingRecordId ??
            (throw ArgumentError.notNull('existingRecordId')),
        name: name,
        kind: kind,
        stringSetId: stringSetId,
        strings: strings,
      ),
    };
  }
}
