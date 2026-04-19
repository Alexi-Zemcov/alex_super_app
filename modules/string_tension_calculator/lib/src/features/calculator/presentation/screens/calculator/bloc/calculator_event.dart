import 'package:equatable/equatable.dart';
import 'package:my_instruments/my_instruments.dart';
import 'package:string_tension_calculator/src/features/calculator/domain/entities/entities.dart';
import 'package:string_tension_calculator/src/features/calculator/presentation/screens/calculator/models/calculator_mode.dart';
import 'package:string_tension_calculator/src/features/calculator/presentation/screens/calculator/models/save_instrument_submission.dart';

sealed class CalculatorEvent extends Equatable {
  const CalculatorEvent();

  @override
  List<Object?> get props => const [];
}

final class CalculatorStarted extends CalculatorEvent {
  const CalculatorStarted();
}

final class CalculatorModeSelected extends CalculatorEvent {
  const CalculatorModeSelected(this.mode);

  final CalculatorMode mode;

  @override
  List<Object?> get props => [mode];
}

final class CalculatorScalePresetSelected extends CalculatorEvent {
  const CalculatorScalePresetSelected(this.preset);

  final ScalePreset preset;

  @override
  List<Object?> get props => [preset];
}

final class CalculatorStringSetSelected extends CalculatorEvent {
  const CalculatorStringSetSelected(this.stringSetId);

  final StringSetId stringSetId;

  @override
  List<Object?> get props => [stringSetId];
}

final class CalculatorSavedInstrumentsChanged extends CalculatorEvent {
  const CalculatorSavedInstrumentsChanged(this.savedInstruments);

  final List<SavedInstrumentRecord> savedInstruments;

  @override
  List<Object?> get props => [savedInstruments];
}

final class CalculatorSavedInstrumentSelected extends CalculatorEvent {
  const CalculatorSavedInstrumentSelected(this.savedInstrumentId);

  final String savedInstrumentId;

  @override
  List<Object?> get props => [savedInstrumentId];
}

final class CalculatorSavedInstrumentEditRequested extends CalculatorEvent {
  const CalculatorSavedInstrumentEditRequested();
}

final class CalculatorScaleIncremented extends CalculatorEvent {
  const CalculatorScaleIncremented(this.index);

  final int index;

  @override
  List<Object?> get props => [index];
}

final class CalculatorScaleDecremented extends CalculatorEvent {
  const CalculatorScaleDecremented(this.index);

  final int index;

  @override
  List<Object?> get props => [index];
}

final class CalculatorNoteIncremented extends CalculatorEvent {
  const CalculatorNoteIncremented(this.index);

  final int index;

  @override
  List<Object?> get props => [index];
}

final class CalculatorNoteDecremented extends CalculatorEvent {
  const CalculatorNoteDecremented(this.index);

  final int index;

  @override
  List<Object?> get props => [index];
}

final class CalculatorGaugeIncremented extends CalculatorEvent {
  const CalculatorGaugeIncremented(this.index);

  final int index;

  @override
  List<Object?> get props => [index];
}

final class CalculatorGaugeDecremented extends CalculatorEvent {
  const CalculatorGaugeDecremented(this.index);

  final int index;

  @override
  List<Object?> get props => [index];
}

final class CalculatorHelpToggled extends CalculatorEvent {
  const CalculatorHelpToggled();
}

final class CalculatorStringAdded extends CalculatorEvent {
  const CalculatorStringAdded();
}

final class CalculatorSaveSubmitted extends CalculatorEvent {
  const CalculatorSaveSubmitted(this.submission);

  final SaveInstrumentSubmission submission;

  @override
  List<Object?> get props => [submission];
}
