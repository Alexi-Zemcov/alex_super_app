import 'package:equatable/equatable.dart';
import 'package:my_instruments/my_instruments.dart';
import 'package:string_tension_calculator/src/features/calculator/domain/entities/entities.dart';
import 'package:string_tension_calculator/src/features/calculator/presentation/screens/calculator/models/calculator_mode.dart';

sealed class CalculatorState extends Equatable {
  const CalculatorState();

  @override
  List<Object?> get props => const [];
}

final class CalculatorInitial extends CalculatorState {
  const CalculatorInitial();
}

final class CalculatorReady extends CalculatorState {
  const CalculatorReady({
    required this.selectedMode,
    required this.guitarDraft,
    required this.bassDraft,
    required this.myGuitarsDraft,
    required this.savedInstruments,
    required this.selectedSavedInstrumentId,
    required this.scalePresets,
    required this.availableStringSets,
    required this.selectedScalePreset,
    required this.isHelpVisible,
  });

  final CalculatorMode selectedMode;
  final Instrument guitarDraft;
  final Instrument bassDraft;
  final Instrument? myGuitarsDraft;
  final List<SavedInstrumentRecord> savedInstruments;
  final String? selectedSavedInstrumentId;
  final List<ScalePreset> scalePresets;
  final List<StringSet> availableStringSets;
  final ScalePreset? selectedScalePreset;
  final bool isHelpVisible;

  Instrument? get activeInstrument => switch (selectedMode) {
    CalculatorMode.guitar => guitarDraft,
    CalculatorMode.bass => bassDraft,
    CalculatorMode.myGuitars => myGuitarsDraft,
  };

  bool get isMyGuitarsEmptyState =>
      selectedMode == CalculatorMode.myGuitars && myGuitarsDraft == null;

  SavedInstrumentRecord? get selectedSavedInstrument {
    final selectedSavedInstrumentId = this.selectedSavedInstrumentId;
    if (selectedSavedInstrumentId == null) {
      return null;
    }

    for (final record in savedInstruments) {
      if (record.id == selectedSavedInstrumentId) {
        return record;
      }
    }

    return null;
  }

  CalculatorReady copyWith({
    CalculatorMode? selectedMode,
    Instrument? guitarDraft,
    Instrument? bassDraft,
    Instrument? myGuitarsDraft,
    bool clearMyGuitarsDraft = false,
    List<SavedInstrumentRecord>? savedInstruments,
    String? selectedSavedInstrumentId,
    bool clearSelectedSavedInstrumentId = false,
    List<ScalePreset>? scalePresets,
    List<StringSet>? availableStringSets,
    ScalePreset? selectedScalePreset,
    bool clearSelectedScalePreset = false,
    bool? isHelpVisible,
  }) {
    return CalculatorReady(
      selectedMode: selectedMode ?? this.selectedMode,
      guitarDraft: guitarDraft ?? this.guitarDraft,
      bassDraft: bassDraft ?? this.bassDraft,
      myGuitarsDraft: clearMyGuitarsDraft
          ? null
          : myGuitarsDraft ?? this.myGuitarsDraft,
      savedInstruments: savedInstruments ?? this.savedInstruments,
      selectedSavedInstrumentId: clearSelectedSavedInstrumentId
          ? null
          : selectedSavedInstrumentId ?? this.selectedSavedInstrumentId,
      scalePresets: scalePresets ?? this.scalePresets,
      availableStringSets: availableStringSets ?? this.availableStringSets,
      selectedScalePreset: clearSelectedScalePreset
          ? null
          : selectedScalePreset ?? this.selectedScalePreset,
      isHelpVisible: isHelpVisible ?? this.isHelpVisible,
    );
  }

  @override
  List<Object?> get props => [
    selectedMode,
    guitarDraft,
    bassDraft,
    myGuitarsDraft,
    savedInstruments,
    selectedSavedInstrumentId,
    scalePresets,
    availableStringSets,
    selectedScalePreset,
    isHelpVisible,
  ];
}
