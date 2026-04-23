import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_instruments/my_instruments.dart';
import 'package:string_tension_calculator/src/features/calculator/domain/entities/entities.dart';
import 'package:string_tension_calculator/src/features/calculator/domain/repositories/calculator_repository.dart';
import 'package:string_tension_calculator/src/features/calculator/domain/services/calculator_engine.dart';
import 'package:string_tension_calculator/src/features/calculator/domain/usecases/load_selected_saved_instrument.dart';
import 'package:string_tension_calculator/src/features/calculator/domain/usecases/save_calculator_instrument.dart';
import 'package:string_tension_calculator/src/features/calculator/presentation/screens/calculator/bloc/calculator_event.dart';
import 'package:string_tension_calculator/src/features/calculator/presentation/screens/calculator/bloc/calculator_state.dart';
import 'package:string_tension_calculator/src/features/calculator/presentation/screens/calculator/models/calculator_mode.dart';
import 'package:string_tension_calculator/src/features/calculator/presentation/screens/calculator/models/save_instrument_submission.dart';

class CalculatorBloc extends Bloc<CalculatorEvent, CalculatorState> {
  CalculatorBloc({
    required CalculatorRepository repository,
    required CalculatorEngine engine,
    required MyInstrumentsRepository myInstrumentsRepository,
    required LoadSelectedSavedInstrument loadSelectedSavedInstrument,
    required SaveCalculatorInstrument saveCalculatorInstrument,
  }) : _repository = repository,
       _engine = engine,
       _myInstrumentsRepository = myInstrumentsRepository,
       _loadSelectedSavedInstrument = loadSelectedSavedInstrument,
       _saveCalculatorInstrument = saveCalculatorInstrument,
       super(const CalculatorInitial()) {
    on<CalculatorStarted>(_onStarted);
    on<CalculatorModeSelected>(_onModeSelected);
    on<CalculatorScalePresetSelected>(_onScalePresetSelected);
    on<CalculatorStringSetSelected>(_onStringSetSelected);
    on<CalculatorSavedInstrumentsChanged>(_onSavedInstrumentsChanged);
    on<CalculatorSavedInstrumentSelected>(_onSavedInstrumentSelected);
    on<CalculatorSavedInstrumentEditRequested>(_onSavedInstrumentEditRequested);
    on<CalculatorScaleIncremented>(_onScaleIncremented);
    on<CalculatorScaleDecremented>(_onScaleDecremented);
    on<CalculatorNoteIncremented>(_onNoteIncremented);
    on<CalculatorNoteDecremented>(_onNoteDecremented);
    on<CalculatorGaugeIncremented>(_onGaugeIncremented);
    on<CalculatorGaugeDecremented>(_onGaugeDecremented);
    on<CalculatorHelpToggled>(_onHelpToggled);
    on<CalculatorStringAdded>(_onStringAdded);
    on<CalculatorSaveSubmitted>(_onSaveSubmitted);
  }

  final CalculatorRepository _repository;
  final CalculatorEngine _engine;
  final MyInstrumentsRepository _myInstrumentsRepository;
  final LoadSelectedSavedInstrument _loadSelectedSavedInstrument;
  final SaveCalculatorInstrument _saveCalculatorInstrument;
  StreamSubscription<List<SavedInstrumentRecord>>? _myInstrumentsSubscription;

  void _onStarted(CalculatorStarted event, Emitter<CalculatorState> emit) {
    _ensureMyInstrumentsSubscription();
    final snapshot = _repository.buildDefaultSnapshot();
    final guitarDraft = snapshot.currentInstrument.type == InstrumentType.guitar
        ? snapshot.currentInstrument
        : snapshot.otherInstrument;
    final bassDraft = snapshot.currentInstrument.type == InstrumentType.bass
        ? snapshot.currentInstrument
        : snapshot.otherInstrument;
    final savedInstruments = _myInstrumentsRepository.getRecords();
    final selectedSavedInstrumentId = _resolveSelectedSavedInstrumentId(
      savedInstruments,
      null,
    );

    emit(
      _buildReadyState(
        selectedMode: CalculatorMode.guitar,
        guitarDraft: guitarDraft,
        bassDraft: bassDraft,
        myGuitarsDraft: _draftFromSelectedRecord(
          savedInstruments,
          selectedSavedInstrumentId,
        ),
        savedInstruments: savedInstruments,
        selectedSavedInstrumentId: selectedSavedInstrumentId,
        isHelpVisible: false,
      ),
    );
  }

  void _onModeSelected(
    CalculatorModeSelected event,
    Emitter<CalculatorState> emit,
  ) {
    final currentState = _requireReadyState();
    final selectedSavedInstrumentId = event.mode == CalculatorMode.myGuitars
        ? _resolveSelectedSavedInstrumentId(
            currentState.savedInstruments,
            currentState.selectedSavedInstrumentId,
          )
        : currentState.selectedSavedInstrumentId;

    emit(
      _buildReadyState(
        selectedMode: event.mode,
        guitarDraft: currentState.guitarDraft,
        bassDraft: currentState.bassDraft,
        myGuitarsDraft:
            currentState.myGuitarsDraft ??
            _draftFromSelectedRecord(
              currentState.savedInstruments,
              selectedSavedInstrumentId,
            ),
        savedInstruments: currentState.savedInstruments,
        selectedSavedInstrumentId: selectedSavedInstrumentId,
        isHelpVisible: currentState.isHelpVisible,
      ),
    );
  }

  void _onScalePresetSelected(
    CalculatorScalePresetSelected event,
    Emitter<CalculatorState> emit,
  ) {
    final currentState = _requireReadyState();
    _emitWithUpdatedActiveInstrument(
      currentState,
      emit,
      (instrument) =>
          _engine.applyScalePresetToInstrument(instrument, event.preset),
    );
  }

  void _onStringSetSelected(
    CalculatorStringSetSelected event,
    Emitter<CalculatorState> emit,
  ) {
    final currentState = _requireReadyState();
    _emitWithUpdatedActiveInstrument(
      currentState,
      emit,
      (instrument) =>
          _engine.changeStringSetForInstrument(instrument, event.stringSetId),
    );
  }

  void _onSavedInstrumentsChanged(
    CalculatorSavedInstrumentsChanged event,
    Emitter<CalculatorState> emit,
  ) {
    final currentState = state;
    if (currentState is! CalculatorReady) {
      return;
    }

    final selectedSavedInstrumentId = _resolveSelectedSavedInstrumentId(
      event.savedInstruments,
      currentState.selectedSavedInstrumentId,
    );

    emit(
      _buildReadyState(
        selectedMode: currentState.selectedMode,
        guitarDraft: currentState.guitarDraft,
        bassDraft: currentState.bassDraft,
        myGuitarsDraft: _draftFromSelectedRecord(
          event.savedInstruments,
          selectedSavedInstrumentId,
        ),
        savedInstruments: event.savedInstruments,
        selectedSavedInstrumentId: selectedSavedInstrumentId,
        isHelpVisible: currentState.isHelpVisible,
      ),
    );
  }

  void _onSavedInstrumentSelected(
    CalculatorSavedInstrumentSelected event,
    Emitter<CalculatorState> emit,
  ) {
    final currentState = _requireReadyState();
    final instrument = _loadSelectedSavedInstrument(
      savedInstruments: currentState.savedInstruments,
      selectedSavedInstrumentId: event.savedInstrumentId,
    );
    if (instrument == null) {
      return;
    }

    emit(
      _buildReadyState(
        selectedMode: currentState.selectedMode,
        guitarDraft: currentState.guitarDraft,
        bassDraft: currentState.bassDraft,
        myGuitarsDraft: instrument,
        savedInstruments: currentState.savedInstruments,
        selectedSavedInstrumentId: event.savedInstrumentId,
        isHelpVisible: currentState.isHelpVisible,
      ),
    );
  }

  void _onSavedInstrumentEditRequested(
    CalculatorSavedInstrumentEditRequested event,
    Emitter<CalculatorState> emit,
  ) {
    final currentState = _requireReadyState();
    final instrument = currentState.myGuitarsDraft;
    if (instrument == null) {
      return;
    }

    final selectedMode = instrument.type == InstrumentType.bass
        ? CalculatorMode.bass
        : CalculatorMode.guitar;

    emit(
      _buildReadyState(
        selectedMode: selectedMode,
        guitarDraft: selectedMode == CalculatorMode.guitar
            ? instrument
            : currentState.guitarDraft,
        bassDraft: selectedMode == CalculatorMode.bass
            ? instrument
            : currentState.bassDraft,
        myGuitarsDraft: currentState.myGuitarsDraft,
        savedInstruments: currentState.savedInstruments,
        selectedSavedInstrumentId: currentState.selectedSavedInstrumentId,
        isHelpVisible: currentState.isHelpVisible,
      ),
    );
  }

  void _onScaleIncremented(
    CalculatorScaleIncremented event,
    Emitter<CalculatorState> emit,
  ) {
    final currentState = _requireReadyState();
    _emitWithUpdatedActiveInstrument(
      currentState,
      emit,
      (instrument) =>
          _engine.incrementScaleAtIndexOnInstrument(instrument, event.index),
    );
  }

  void _onScaleDecremented(
    CalculatorScaleDecremented event,
    Emitter<CalculatorState> emit,
  ) {
    final currentState = _requireReadyState();
    _emitWithUpdatedActiveInstrument(
      currentState,
      emit,
      (instrument) =>
          _engine.decrementScaleAtIndexOnInstrument(instrument, event.index),
    );
  }

  void _onNoteIncremented(
    CalculatorNoteIncremented event,
    Emitter<CalculatorState> emit,
  ) {
    final currentState = _requireReadyState();
    _emitWithUpdatedActiveInstrument(
      currentState,
      emit,
      (instrument) =>
          _engine.incrementNoteAtIndexOnInstrument(instrument, event.index),
    );
  }

  void _onNoteDecremented(
    CalculatorNoteDecremented event,
    Emitter<CalculatorState> emit,
  ) {
    final currentState = _requireReadyState();
    _emitWithUpdatedActiveInstrument(
      currentState,
      emit,
      (instrument) =>
          _engine.decrementNoteAtIndexOnInstrument(instrument, event.index),
    );
  }

  void _onGaugeIncremented(
    CalculatorGaugeIncremented event,
    Emitter<CalculatorState> emit,
  ) {
    final currentState = _requireReadyState();
    _emitWithUpdatedActiveInstrument(
      currentState,
      emit,
      (instrument) =>
          _engine.incrementGaugeAtIndexOnInstrument(instrument, event.index),
    );
  }

  void _onGaugeDecremented(
    CalculatorGaugeDecremented event,
    Emitter<CalculatorState> emit,
  ) {
    final currentState = _requireReadyState();
    _emitWithUpdatedActiveInstrument(
      currentState,
      emit,
      (instrument) =>
          _engine.decrementGaugeAtIndexOnInstrument(instrument, event.index),
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
    _emitWithUpdatedActiveInstrument(
      currentState,
      emit,
      (instrument) => _engine.addStringToInstrument(instrument),
    );
  }

  Future<void> _onSaveSubmitted(
    CalculatorSaveSubmitted event,
    Emitter<CalculatorState> emit,
  ) async {
    final currentState = _requireReadyState();
    final activeInstrument = currentState.activeInstrument;
    if (activeInstrument == null) {
      return;
    }

    final savedRecord = await _saveCalculatorInstrument(
      mode: event.submission.action == SaveInstrumentAction.update
          ? SaveCalculatorInstrumentMode.update
          : SaveCalculatorInstrumentMode.create,
      instrument: activeInstrument,
      name: event.submission.name,
      kind: event.submission.kind,
      existingRecordId: currentState.selectedSavedInstrumentId,
    );

    final savedInstruments = _myInstrumentsRepository.getRecords();
    emit(
      _buildReadyState(
        selectedMode: currentState.selectedMode,
        guitarDraft: currentState.guitarDraft,
        bassDraft: currentState.bassDraft,
        myGuitarsDraft: _loadSelectedSavedInstrument(
          savedInstruments: [savedRecord],
          selectedSavedInstrumentId: savedRecord.id,
        ),
        savedInstruments: savedInstruments,
        selectedSavedInstrumentId: savedRecord.id,
        isHelpVisible: currentState.isHelpVisible,
      ),
    );
  }

  CalculatorReady _buildReadyState({
    required CalculatorMode selectedMode,
    required Instrument guitarDraft,
    required Instrument bassDraft,
    required Instrument? myGuitarsDraft,
    required List<SavedInstrumentRecord> savedInstruments,
    required String? selectedSavedInstrumentId,
    required bool isHelpVisible,
  }) {
    final activeInstrument = switch (selectedMode) {
      CalculatorMode.guitar => guitarDraft,
      CalculatorMode.bass => bassDraft,
      CalculatorMode.myGuitars => myGuitarsDraft,
    };

    return CalculatorReady(
      selectedMode: selectedMode,
      guitarDraft: guitarDraft,
      bassDraft: bassDraft,
      myGuitarsDraft: myGuitarsDraft,
      savedInstruments: savedInstruments,
      selectedSavedInstrumentId: selectedSavedInstrumentId,
      scalePresets: activeInstrument == null
          ? const []
          : _repository.getScalePresets(activeInstrument.type),
      availableStringSets: activeInstrument == null
          ? const []
          : _repository.getAvailableStringSets(activeInstrument.type),
      selectedScalePreset: activeInstrument == null
          ? null
          : _engine.findMatchingScalePreset(activeInstrument),
      isHelpVisible: isHelpVisible,
    );
  }

  Instrument? _draftFromSelectedRecord(
    List<SavedInstrumentRecord> savedInstruments,
    String? selectedSavedInstrumentId,
  ) {
    return _loadSelectedSavedInstrument(
      savedInstruments: savedInstruments,
      selectedSavedInstrumentId: selectedSavedInstrumentId,
    );
  }

  void _emitWithUpdatedActiveInstrument(
    CalculatorReady currentState,
    Emitter<CalculatorState> emit,
    Instrument Function(Instrument instrument) updater,
  ) {
    final activeInstrument = currentState.activeInstrument;
    if (activeInstrument == null) {
      return;
    }

    final updatedInstrument = updater(activeInstrument);
    emit(switch (currentState.selectedMode) {
      CalculatorMode.guitar => _buildReadyState(
        selectedMode: currentState.selectedMode,
        guitarDraft: updatedInstrument,
        bassDraft: currentState.bassDraft,
        myGuitarsDraft: currentState.myGuitarsDraft,
        savedInstruments: currentState.savedInstruments,
        selectedSavedInstrumentId: currentState.selectedSavedInstrumentId,
        isHelpVisible: currentState.isHelpVisible,
      ),
      CalculatorMode.bass => _buildReadyState(
        selectedMode: currentState.selectedMode,
        guitarDraft: currentState.guitarDraft,
        bassDraft: updatedInstrument,
        myGuitarsDraft: currentState.myGuitarsDraft,
        savedInstruments: currentState.savedInstruments,
        selectedSavedInstrumentId: currentState.selectedSavedInstrumentId,
        isHelpVisible: currentState.isHelpVisible,
      ),
      CalculatorMode.myGuitars => _buildReadyState(
        selectedMode: currentState.selectedMode,
        guitarDraft: currentState.guitarDraft,
        bassDraft: currentState.bassDraft,
        myGuitarsDraft: updatedInstrument,
        savedInstruments: currentState.savedInstruments,
        selectedSavedInstrumentId: currentState.selectedSavedInstrumentId,
        isHelpVisible: currentState.isHelpVisible,
      ),
    });
  }

  void _ensureMyInstrumentsSubscription() {
    if (_myInstrumentsSubscription != null) {
      return;
    }

    var isFirstEvent = true;
    _myInstrumentsSubscription = _myInstrumentsRepository.watchRecords().listen(
      (savedInstruments) {
        if (isFirstEvent) {
          isFirstEvent = false;
          return;
        }

        add(CalculatorSavedInstrumentsChanged(savedInstruments));
      },
    );
  }

  String? _resolveSelectedSavedInstrumentId(
    List<SavedInstrumentRecord> savedInstruments,
    String? preferredId,
  ) {
    if (savedInstruments.isEmpty) {
      return null;
    }

    if (preferredId != null &&
        savedInstruments.any((record) => record.id == preferredId)) {
      return preferredId;
    }

    return savedInstruments.first.id;
  }

  @override
  Future<void> close() async {
    await _myInstrumentsSubscription?.cancel();
    return super.close();
  }

  CalculatorReady _requireReadyState() {
    final currentState = state;
    if (currentState is! CalculatorReady) {
      throw StateError('Calculator state is not ready');
    }

    return currentState;
  }
}
