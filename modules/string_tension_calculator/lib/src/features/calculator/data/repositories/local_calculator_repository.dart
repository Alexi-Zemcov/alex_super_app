import 'package:string_tension_calculator/src/features/calculator/data/datasources/calculator_catalog_datasource.dart';
import 'package:string_tension_calculator/src/features/calculator/domain/entities/entities.dart';
import 'package:string_tension_calculator/src/features/calculator/domain/repositories/calculator_repository.dart';

class LocalCalculatorRepository implements CalculatorRepository {
  const LocalCalculatorRepository({
    required CalculatorCatalogDataSource dataSource,
  }) : _dataSource = dataSource;

  final CalculatorCatalogDataSource _dataSource;

  @override
  CalculatorSnapshot buildDefaultSnapshot() =>
      _dataSource.buildDefaultSnapshot();

  @override
  List<StringSet> getAvailableStringSets(InstrumentType instrumentType) {
    return List<StringSet>.unmodifiable(
      _dataSource.getStringSets().where(
        (set) => set.instrumentTypes.contains(instrumentType),
      ),
    );
  }

  @override
  PhysicalString getPhysicalString(
    StringSetId stringSetId,
    int physicalStringId,
  ) {
    final set = getStringSet(stringSetId);
    return set.strings[physicalStringId];
  }

  @override
  List<ScalePreset> getScalePresets(InstrumentType instrumentType) {
    return List<ScalePreset>.unmodifiable(
      _dataSource.getScalePresets(instrumentType),
    );
  }

  @override
  StringSet getStringSet(StringSetId stringSetId) {
    return _dataSource.getStringSets().firstWhere(
      (set) => set.id == stringSetId,
    );
  }
}
