import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:string_tension_calculator/src/features/calculator/domain/entities/entities.dart';
import 'package:string_tension_calculator/src/features/calculator/domain/repositories/calculator_repository.dart';
import 'package:string_tension_calculator/src/features/calculator/domain/services/calculator_engine.dart';
import 'package:string_tension_calculator/src/features/calculator/presentation/screens/calculator/bloc/calculator_event.dart';
import 'package:string_tension_calculator/src/features/calculator/presentation/screens/calculator/bloc/calculator_state.dart';

class CalculatorBloc extends Bloc<CalculatorEvent, CalculatorState> {
  CalculatorBloc({
    required CalculatorRepository repository,
    required CalculatorEngine engine,
  }) : _repository = repository,
       _engine = engine,
       super(const CalculatorInitial()) {
    on<CalculatorStarted>(_onStarted);
    on<CalculatorInstrumentToggled>(_onInstrumentToggled);
    on<CalculatorScalePresetSelected>(_onScalePresetSelected);
    on<CalculatorStringSetSelected>(_onStringSetSelected);
    on<CalculatorScaleIncremented>(_onScaleIncremented);
    on<CalculatorScaleDecremented>(_onScaleDecremented);
    on<CalculatorNoteIncremented>(_onNoteIncremented);
    on<CalculatorNoteDecremented>(_onNoteDecremented);
    on<CalculatorGaugeIncremented>(_onGaugeIncremented);
    on<CalculatorGaugeDecremented>(_onGaugeDecremented);
    on<CalculatorHelpToggled>(_onHelpToggled);
    on<CalculatorStringAdded>(_onStringAdded);
  }

  final CalculatorRepository _repository;
  final CalculatorEngine _engine;

  void _onStarted(CalculatorStarted event, Emitter<CalculatorState> emit) {
    emit(
      _buildReadyState(
        snapshot: _repository.buildDefaultSnapshot(),
        isHelpVisible: false,
      ),
    );
  }

  void _onInstrumentToggled(
    CalculatorInstrumentToggled event,
    Emitter<CalculatorState> emit,
  ) {
    final currentState = _requireReadyState();
    emit(
      _buildReadyState(
        snapshot: _engine.toggleInstrument(currentState.snapshot),
        isHelpVisible: currentState.isHelpVisible,
      ),
    );
  }

  void _onScalePresetSelected(
    CalculatorScalePresetSelected event,
    Emitter<CalculatorState> emit,
  ) {
    final currentState = _requireReadyState();
    emit(
      _buildReadyState(
        snapshot: _engine.applyScalePreset(currentState.snapshot, event.preset),
        isHelpVisible: currentState.isHelpVisible,
      ),
    );
  }

  void _onStringSetSelected(
    CalculatorStringSetSelected event,
    Emitter<CalculatorState> emit,
  ) {
    final currentState = _requireReadyState();
    emit(
      _buildReadyState(
        snapshot: _engine.changeStringSet(
          currentState.snapshot,
          event.stringSetId,
        ),
        isHelpVisible: currentState.isHelpVisible,
      ),
    );
  }

  void _onScaleIncremented(
    CalculatorScaleIncremented event,
    Emitter<CalculatorState> emit,
  ) {
    final currentState = _requireReadyState();
    emit(
      _buildReadyState(
        snapshot: _engine.incrementScaleAtIndex(
          currentState.snapshot,
          event.index,
        ),
        isHelpVisible: currentState.isHelpVisible,
      ),
    );
  }

  void _onScaleDecremented(
    CalculatorScaleDecremented event,
    Emitter<CalculatorState> emit,
  ) {
    final currentState = _requireReadyState();
    emit(
      _buildReadyState(
        snapshot: _engine.decrementScaleAtIndex(
          currentState.snapshot,
          event.index,
        ),
        isHelpVisible: currentState.isHelpVisible,
      ),
    );
  }

  void _onNoteIncremented(
    CalculatorNoteIncremented event,
    Emitter<CalculatorState> emit,
  ) {
    final currentState = _requireReadyState();
    emit(
      _buildReadyState(
        snapshot: _engine.incrementNoteAtIndex(
          currentState.snapshot,
          event.index,
        ),
        isHelpVisible: currentState.isHelpVisible,
      ),
    );
  }

  void _onNoteDecremented(
    CalculatorNoteDecremented event,
    Emitter<CalculatorState> emit,
  ) {
    final currentState = _requireReadyState();
    emit(
      _buildReadyState(
        snapshot: _engine.decrementNoteAtIndex(
          currentState.snapshot,
          event.index,
        ),
        isHelpVisible: currentState.isHelpVisible,
      ),
    );
  }

  void _onGaugeIncremented(
    CalculatorGaugeIncremented event,
    Emitter<CalculatorState> emit,
  ) {
    final currentState = _requireReadyState();
    emit(
      _buildReadyState(
        snapshot: _engine.incrementGaugeAtIndex(
          currentState.snapshot,
          event.index,
        ),
        isHelpVisible: currentState.isHelpVisible,
      ),
    );
  }

  void _onGaugeDecremented(
    CalculatorGaugeDecremented event,
    Emitter<CalculatorState> emit,
  ) {
    final currentState = _requireReadyState();
    emit(
      _buildReadyState(
        snapshot: _engine.decrementGaugeAtIndex(
          currentState.snapshot,
          event.index,
        ),
        isHelpVisible: currentState.isHelpVisible,
      ),
    );
  }

  void _onHelpToggled(
    CalculatorHelpToggled event,
    Emitter<CalculatorState> emit,
  ) {
    final currentState = _requireReadyState();
    emit(currentState.copyWith(isHelpVisible: !currentState.isHelpVisible));
  }

  void _onStringAdded(
    CalculatorStringAdded event,
    Emitter<CalculatorState> emit,
  ) {
    final currentState = _requireReadyState();
    emit(
      _buildReadyState(
        snapshot: _engine.addString(currentState.snapshot),
        isHelpVisible: currentState.isHelpVisible,
      ),
    );
  }

  CalculatorReady _buildReadyState({
    required CalculatorSnapshot snapshot,
    required bool isHelpVisible,
  }) {
    final currentInstrument = snapshot.currentInstrument;
    return CalculatorReady(
      snapshot: snapshot,
      scalePresets: _repository.getScalePresets(currentInstrument.type),
      availableStringSets: _repository.getAvailableStringSets(
        currentInstrument.type,
      ),
      selectedScalePreset: _engine.findMatchingScalePreset(currentInstrument),
      isHelpVisible: isHelpVisible,
    );
  }

  CalculatorReady _requireReadyState() {
    final currentState = state;
    if (currentState is! CalculatorReady) {
      throw StateError('Calculator state is not ready');
    }

    return currentState;
  }
}
