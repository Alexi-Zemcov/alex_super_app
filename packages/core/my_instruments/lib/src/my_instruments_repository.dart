import 'package:my_instruments/src/saved_instrument_models.dart';

abstract interface class MyInstrumentsRepository {
  List<SavedInstrumentRecord> getRecords();

  Stream<List<SavedInstrumentRecord>> watchRecords();

  Future<SavedInstrumentRecord> createRecord({
    required String name,
    required SavedInstrumentKind kind,
    required SavedStringSetId stringSetId,
    required List<SavedInstrumentString> strings,
  });

  Future<SavedInstrumentRecord> updateRecord({
    required String id,
    required String name,
    required SavedInstrumentKind kind,
    required SavedStringSetId stringSetId,
    required List<SavedInstrumentString> strings,
  });
}
