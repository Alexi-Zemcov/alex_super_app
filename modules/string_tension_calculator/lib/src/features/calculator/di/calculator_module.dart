import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_instruments/my_instruments.dart';
import 'package:provider/single_child_widget.dart';
import 'package:scoped_di/scoped_di.dart';
import 'package:string_tension_calculator/src/features/calculator/data/mappers/saved_instrument_mapper.dart';
import 'package:string_tension_calculator/src/features/calculator/domain/repositories/calculator_repository.dart';
import 'package:string_tension_calculator/src/features/calculator/domain/services/calculator_engine.dart';
import 'package:string_tension_calculator/src/features/calculator/presentation/screens/calculator/bloc/calculator_bloc.dart';
import 'package:string_tension_calculator/src/features/calculator/presentation/screens/calculator/bloc/calculator_event.dart';

class CalculatorModule extends ScopeModule {
  const CalculatorModule();

  @override
  List<SingleChildWidget> get providers => [
    BlocProvider<CalculatorBloc>(
      create: (context) => CalculatorBloc(
        repository: context.read<CalculatorRepository>(),
        engine: context.read<CalculatorEngine>(),
        myInstrumentsRepository: context.read<MyInstrumentsRepository>(),
        savedInstrumentMapper: context.read<SavedInstrumentMapper>(),
      )..add(const CalculatorStarted()),
    ),
  ];
}
