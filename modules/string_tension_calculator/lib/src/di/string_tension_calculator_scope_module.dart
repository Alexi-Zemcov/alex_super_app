import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:scoped_di/scoped_di.dart';
import 'package:string_tension_calculator/src/features/calculator/data/datasources/calculator_catalog_datasource.dart';
import 'package:string_tension_calculator/src/features/calculator/data/mappers/saved_instrument_mapper.dart';
import 'package:string_tension_calculator/src/features/calculator/data/repositories/local_calculator_repository.dart';
import 'package:string_tension_calculator/src/features/calculator/domain/repositories/calculator_repository.dart';
import 'package:string_tension_calculator/src/features/calculator/domain/services/calculator_engine.dart';
import 'package:string_tension_calculator/src/features/calculator/domain/services/saved_instrument_converter.dart';

class StringTensionCalculatorScopeModule extends ScopeModule {
  const StringTensionCalculatorScopeModule();

  @override
  List<SingleChildWidget> get providers => [
    Provider<CalculatorCatalogDataSource>.value(
      value: const CalculatorCatalogDataSource(),
    ),
    RepositoryProvider<CalculatorRepository>(
      create: (context) => LocalCalculatorRepository(
        dataSource: context.read<CalculatorCatalogDataSource>(),
      ),
    ),
    Provider<CalculatorEngine>(
      create: (context) =>
          CalculatorEngine(repository: context.read<CalculatorRepository>()),
    ),
    Provider<SavedInstrumentConverter>(
      create: (context) => SavedInstrumentMapper(
        repository: context.read<CalculatorRepository>(),
      ),
    ),
  ];
}
