import 'package:equatable/equatable.dart';
import 'package:string_tension_calculator/src/features/calculator/domain/entities/entities.dart';

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
    required this.snapshot,
    required this.scalePresets,
    required this.availableStringSets,
    required this.selectedScalePreset,
    required this.isHelpVisible,
  });

  final CalculatorSnapshot snapshot;
  final List<ScalePreset> scalePresets;
  final List<StringSet> availableStringSets;
  final ScalePreset? selectedScalePreset;
  final bool isHelpVisible;

  CalculatorReady copyWith({
    CalculatorSnapshot? snapshot,
    List<ScalePreset>? scalePresets,
    List<StringSet>? availableStringSets,
    ScalePreset? selectedScalePreset,
    bool clearSelectedScalePreset = false,
    bool? isHelpVisible,
  }) {
    return CalculatorReady(
      snapshot: snapshot ?? this.snapshot,
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
    snapshot,
    scalePresets,
    availableStringSets,
    selectedScalePreset,
    isHelpVisible,
  ];
}
