import 'package:flutter/material.dart';
import 'package:string_tension_calculator/src/features/calculator/domain/entities/entities.dart';

class InstrumentTypeSwitch extends StatelessWidget {
  const InstrumentTypeSwitch({
    required this.selectedType,
    required this.onSelectionChanged,
    super.key,
  });

  final InstrumentType selectedType;
  final ValueChanged<InstrumentType> onSelectionChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<InstrumentType>(
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
        ButtonSegment<InstrumentType>(
          value: InstrumentType.guitar,
          label: Text('Гитара'),
        ),
        ButtonSegment<InstrumentType>(
          value: InstrumentType.bass,
          label: Text('Бас'),
        ),
      ],
      selected: {selectedType},
      onSelectionChanged: (selection) {
        onSelectionChanged(selection.single);
      },
    );
  }
}
