import 'package:my_instruments/my_instruments.dart';
import 'package:string_tension_calculator/src/features/calculator/domain/entities/entities.dart';
import 'package:string_tension_calculator/src/features/calculator/domain/services/saved_instrument_converter.dart';

class LoadSelectedSavedInstrument {
  const LoadSelectedSavedInstrument({
    required SavedInstrumentConverter converter,
  }) : _converter = converter;

  final SavedInstrumentConverter _converter;

  Instrument? call({
    required List<SavedInstrumentRecord> savedInstruments,
    required String? selectedSavedInstrumentId,
  }) {
    if (selectedSavedInstrumentId == null) {
      return null;
    }

    for (final record in savedInstruments) {
      if (record.id == selectedSavedInstrumentId) {
        return _converter.toInstrument(record);
      }
    }

    return null;
  }
}
