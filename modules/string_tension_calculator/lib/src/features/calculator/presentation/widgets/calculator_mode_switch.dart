import 'package:flutter/material.dart';
import 'package:string_tension_calculator/src/features/calculator/presentation/screens/calculator/models/calculator_mode.dart';

class CalculatorModeSwitch extends StatelessWidget {
  const CalculatorModeSwitch({
    required this.selectedMode,
    required this.onSelectionChanged,
    super.key,
  });

  final CalculatorMode selectedMode;
  final ValueChanged<CalculatorMode> onSelectionChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<CalculatorMode>(
      showSelectedIcon: false,
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? const Color(0xFF663DF3)
              : const Color(0xFF2A2A33);
        }),
        foregroundColor: const WidgetStatePropertyAll(Colors.white),
        side: const WidgetStatePropertyAll(
          BorderSide(color: Color(0xFF292B33)),
        ),
        textStyle: const WidgetStatePropertyAll(
          TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      segments: const [
        ButtonSegment<CalculatorMode>(
          value: CalculatorMode.guitar,
          label: Text('Гитара'),
        ),
        ButtonSegment<CalculatorMode>(
          value: CalculatorMode.bass,
          label: Text('Бас'),
        ),
        ButtonSegment<CalculatorMode>(
          value: CalculatorMode.myGuitars,
          label: Text('Мои гитары'),
        ),
      ],
      selected: {selectedMode},
      onSelectionChanged: (selection) {
        onSelectionChanged(selection.single);
      },
    );
  }
}
