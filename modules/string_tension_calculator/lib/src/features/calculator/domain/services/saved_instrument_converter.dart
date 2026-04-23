import 'package:my_instruments/my_instruments.dart';
import 'package:string_tension_calculator/src/features/calculator/domain/entities/entities.dart';

abstract interface class SavedInstrumentConverter {
  SavedStringSetId savedStringSetIdFromInstrument(StringSetId stringSetId);

  Instrument toInstrument(SavedInstrumentRecord record);

  List<SavedInstrumentString> toSavedStrings(Instrument instrument);

  InstrumentType instrumentTypeFromSavedKind(SavedInstrumentKind kind);
}
