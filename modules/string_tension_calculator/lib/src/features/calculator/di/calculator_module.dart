import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_instruments/my_instruments.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:scoped_di/scoped_di.dart';
import 'package:string_tension_calculator/src/features/calculator/domain/repositories/calculator_repository.dart';
import 'package:string_tension_calculator/src/features/calculator/domain/services/calculator_engine.dart';
import 'package:string_tension_calculator/src/features/calculator/domain/services/saved_instrument_converter.dart';
import 'package:string_tension_calculator/src/features/calculator/domain/usecases/load_selected_saved_instrument.dart';
import 'package:string_tension_calculator/src/features/calculator/domain/usecases/save_calculator_instrument.dart';
import 'package:string_tension_calculator/src/features/calculator/presentation/screens/calculator/bloc/calculator_bloc.dart';
import 'package:string_tension_calculator/src/features/calculator/presentation/screens/calculator/bloc/calculator_event.dart';

class CalculatorModule extends ScopeModule {
  const CalculatorModule();

  @override
  List<SingleChildWidget> get providers => [
    Provider<LoadSelectedSavedInstrument>(
      create: (context) => LoadSelectedSavedInstrument(
        converter: context.read<SavedInstrumentConverter>(),
      ),
    ),
    Provider<SaveCalculatorInstrument>(
      create: (context) => SaveCalculatorInstrument(
        repository: context.read<MyInstrumentsRepository>(),
        converter: context.read<SavedInstrumentConverter>(),
      ),
    ),
    BlocProvider<CalculatorBloc>(
      create: (context) => CalculatorBloc(
        repository: context.read<CalculatorRepository>(),
        engine: context.read<CalculatorEngine>(),
        myInstrumentsRepository: context.read<MyInstrumentsRepository>(),
        loadSelectedSavedInstrument: context
            .read<LoadSelectedSavedInstrument>(),
        saveCalculatorInstrument: context.read<SaveCalculatorInstrument>(),
      )..add(const CalculatorStarted()),
    ),
  ];
}
