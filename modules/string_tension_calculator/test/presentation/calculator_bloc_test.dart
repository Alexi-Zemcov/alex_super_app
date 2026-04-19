import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:string_tension_calculator/src/features/calculator/data/datasources/calculator_catalog_datasource.dart';
import 'package:string_tension_calculator/src/features/calculator/data/repositories/local_calculator_repository.dart';
import 'package:string_tension_calculator/src/features/calculator/domain/entities/entities.dart';
import 'package:string_tension_calculator/src/features/calculator/domain/services/calculator_engine.dart';
import 'package:string_tension_calculator/src/features/calculator/presentation/screens/calculator/bloc/calculator_bloc.dart';
import 'package:string_tension_calculator/src/features/calculator/presentation/screens/calculator/bloc/calculator_event.dart';
import 'package:string_tension_calculator/src/features/calculator/presentation/screens/calculator/bloc/calculator_state.dart';

void main() {
  const dataSource = CalculatorCatalogDataSource();
  const repository = LocalCalculatorRepository(dataSource: dataSource);
  const engine = CalculatorEngine(repository: repository);

  blocTest<CalculatorBloc, CalculatorState>(
    'starts with the default guitar state',
    build: () => CalculatorBloc(repository: repository, engine: engine),
    act: (bloc) => bloc.add(const CalculatorStarted()),
    expect: () => [
      isA<CalculatorReady>()
          .having(
            (state) => state.snapshot.currentInstrument.type,
            'instrument type',
            InstrumentType.guitar,
          )
          .having(
            (state) => state.snapshot.currentInstrument.strings.length,
            'string count',
            6,
          )
          .having(
            (state) => state.selectedScalePreset,
            'selected preset',
            const ScalePreset.single(25.5),
          ),
    ],
  );

  blocTest<CalculatorBloc, CalculatorState>(
    'toggles to the default bass state',
    build: () => CalculatorBloc(repository: repository, engine: engine),
    act: (bloc) {
      bloc.add(const CalculatorStarted());
      bloc.add(const CalculatorInstrumentToggled());
    },
    expect: () => [
      isA<CalculatorReady>(),
      isA<CalculatorReady>()
          .having(
            (state) => state.snapshot.currentInstrument.type,
            'instrument type',
            InstrumentType.bass,
          )
          .having(
            (state) => state.snapshot.currentInstrument.strings.length,
            'string count',
            4,
          )
          .having(
            (state) => state.selectedScalePreset,
            'selected preset',
            const ScalePreset.single(34),
          ),
    ],
  );
}
