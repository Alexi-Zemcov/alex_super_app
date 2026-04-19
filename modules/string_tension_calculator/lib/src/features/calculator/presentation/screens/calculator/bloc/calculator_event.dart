import 'package:equatable/equatable.dart';
import 'package:string_tension_calculator/src/features/calculator/domain/entities/entities.dart';

sealed class CalculatorEvent extends Equatable {
  const CalculatorEvent();

  @override
  List<Object?> get props => const [];
}

final class CalculatorStarted extends CalculatorEvent {
  const CalculatorStarted();
}

final class CalculatorInstrumentToggled extends CalculatorEvent {
  const CalculatorInstrumentToggled();
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
