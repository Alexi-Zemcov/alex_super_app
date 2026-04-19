import 'package:string_tension_calculator/src/features/calculator/domain/entities/entities.dart';

abstract interface class CalculatorRepository {
  CalculatorSnapshot buildDefaultSnapshot();

  List<ScalePreset> getScalePresets(InstrumentType instrumentType);

  List<StringSet> getAvailableStringSets(InstrumentType instrumentType);

  StringSet getStringSet(StringSetId stringSetId);

  PhysicalString getPhysicalString(
    StringSetId stringSetId,
    int physicalStringId,
  );
}
