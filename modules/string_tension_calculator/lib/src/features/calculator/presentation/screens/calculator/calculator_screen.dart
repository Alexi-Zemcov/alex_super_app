import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:string_tension_calculator/src/features/calculator/domain/entities/entities.dart';
import 'package:string_tension_calculator/src/features/calculator/domain/repositories/calculator_repository.dart';
import 'package:string_tension_calculator/src/features/calculator/domain/services/calculator_engine.dart';
import 'package:string_tension_calculator/src/features/calculator/presentation/screens/calculator/bloc/calculator_bloc.dart';
import 'package:string_tension_calculator/src/features/calculator/presentation/screens/calculator/bloc/calculator_event.dart';
import 'package:string_tension_calculator/src/features/calculator/presentation/screens/calculator/bloc/calculator_state.dart';
import 'package:string_tension_calculator/src/features/calculator/presentation/widgets/calculator_cell.dart';
import 'package:string_tension_calculator/src/features/calculator/presentation/widgets/instrument_type_switch.dart';
import 'package:string_tension_calculator/src/features/calculator/presentation/widgets/tension_help_card.dart';

class CalculatorScreen extends StatelessWidget {
  const CalculatorScreen({super.key});

  static const _cardWidth = 760.0;
  static const _tableWidth =
      (calculatorCellWidth * 5) + (calculatorCellGap * 4);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Калькулятор натяжения струн')),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF141418), Color(0xFF1F2029)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: BlocBuilder<CalculatorBloc, CalculatorState>(
            builder: (context, state) {
              return switch (state) {
                CalculatorInitial() => const Center(
                  child: CircularProgressIndicator(),
                ),
                CalculatorReady() => Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: _cardWidth),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: _CalculatorCard(state: state),
                    ),
                  ),
                ),
              };
            },
          ),
        ),
      ),
    );
  }
}

class _CalculatorCard extends StatelessWidget {
  const _CalculatorCard({required this.state});

  final CalculatorReady state;

  @override
  Widget build(BuildContext context) {
    final currentInstrument = state.snapshot.currentInstrument;

    return Theme(
      data: Theme.of(context).copyWith(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF2A2A33),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF292B33)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF292B33)),
          ),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C24),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF292B33)),
          boxShadow: const [
            BoxShadow(
              blurRadius: 24,
              color: Color(0x44000000),
              offset: Offset(0, 12),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            InstrumentTypeSwitch(
              selectedType: currentInstrument.type,
              onSelectionChanged: (_) {
                context.read<CalculatorBloc>().add(
                  const CalculatorInstrumentToggled(),
                );
              },
            ),
            const SizedBox(height: 16),
            _ScalePresetSelector(
              presets: state.scalePresets,
              selectedPreset: state.selectedScalePreset,
            ),
            const SizedBox(height: 16),
            _StringSetSelector(
              stringSets: state.availableStringSets,
              selectedId: currentInstrument.stringSetId,
            ),
            const SizedBox(height: 20),
            const Divider(color: Color(0xFF292B33), height: 1),
            const SizedBox(height: 20),
            _CalculatorTable(
              snapshot: state.snapshot,
              isHelpVisible: state.isHelpVisible,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 180,
              child: FilledButton.icon(
                key: const Key('add-string-button'),
                onPressed: () {
                  context.read<CalculatorBloc>().add(
                    const CalculatorStringAdded(),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Добавить струну'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScalePresetSelector extends StatelessWidget {
  const _ScalePresetSelector({
    required this.presets,
    required this.selectedPreset,
  });

  final List<ScalePreset> presets;
  final ScalePreset? selectedPreset;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<ScalePreset>(
      key: const Key('scale-preset-selector'),
      initialValue: selectedPreset,
      dropdownColor: const Color(0xFF2A2A33),
      decoration: const InputDecoration(
        labelText: 'Выберите мензуру',
        labelStyle: TextStyle(color: Colors.white70),
      ),
      iconEnabledColor: Colors.white,
      style: const TextStyle(color: Colors.white),
      items: [
        for (final preset in presets)
          DropdownMenuItem<ScalePreset>(
            value: preset,
            child: Text(preset.toLabelRu()),
          ),
      ],
      onChanged: (preset) {
        if (preset == null) {
          return;
        }
        context.read<CalculatorBloc>().add(
          CalculatorScalePresetSelected(preset),
        );
      },
    );
  }
}

class _StringSetSelector extends StatelessWidget {
  const _StringSetSelector({
    required this.stringSets,
    required this.selectedId,
  });

  final List<StringSet> stringSets;
  final StringSetId selectedId;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<StringSetId>(
      key: const Key('string-set-selector'),
      initialValue: selectedId,
      dropdownColor: const Color(0xFF2A2A33),
      decoration: const InputDecoration(
        labelText: 'Набор струн',
        labelStyle: TextStyle(color: Colors.white70),
      ),
      iconEnabledColor: Colors.white,
      style: const TextStyle(color: Colors.white),
      items: [
        for (final stringSet in stringSets)
          DropdownMenuItem<StringSetId>(
            value: stringSet.id,
            child: Text(stringSet.displayName),
          ),
      ],
      onChanged: (stringSetId) {
        if (stringSetId == null) {
          return;
        }
        context.read<CalculatorBloc>().add(
          CalculatorStringSetSelected(stringSetId),
        );
      },
    );
  }
}

class _CalculatorTable extends StatelessWidget {
  const _CalculatorTable({required this.snapshot, required this.isHelpVisible});

  final CalculatorSnapshot snapshot;
  final bool isHelpVisible;

  @override
  Widget build(BuildContext context) {
    final engine = context.read<CalculatorEngine>();
    final repository = context.read<CalculatorRepository>();
    final instrument = snapshot.currentInstrument;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: CalculatorScreen._tableWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _HeaderRow(),
            if (isHelpVisible) ...[
              const SizedBox(height: 12),
              TensionHelpCard(
                onClose: () {
                  context.read<CalculatorBloc>().add(
                    const CalculatorHelpToggled(),
                  );
                },
              ),
              const SizedBox(height: 12),
            ],
            for (var index = 0; index < instrument.strings.length; index++) ...[
              if (index > 0) const SizedBox(height: 12),
              _StringRow(
                index: index,
                string: instrument.strings[index],
                stringSetId: instrument.stringSetId,
                instrumentType: instrument.type,
                engine: engine,
                repository: repository,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const _HeaderCell(label: 'Мензура'),
        _gap,
        const _HeaderCell(label: 'Нота'),
        _gap,
        const _HeaderCell(label: 'Калибр'),
        _gap,
        _HeaderCell(
          label: 'Натяжение',
          trailing: IconButton(
            key: const Key('toggle-help-button'),
            onPressed: () {
              context.read<CalculatorBloc>().add(const CalculatorHelpToggled());
            },
            icon: const Icon(
              Icons.question_mark_rounded,
              size: 16,
              color: Color(0xFF663DF3),
            ),
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFF383845),
              minimumSize: const Size(22, 22),
              padding: EdgeInsets.zero,
            ),
          ),
        ),
        _gap,
        const _HeaderCell(label: 'Частота'),
      ],
    );
  }
}

class _StringRow extends StatelessWidget {
  const _StringRow({
    required this.index,
    required this.string,
    required this.stringSetId,
    required this.instrumentType,
    required this.engine,
    required this.repository,
  });

  final int index;
  final InstrumentString string;
  final StringSetId stringSetId;
  final InstrumentType instrumentType;
  final CalculatorEngine engine;
  final CalculatorRepository repository;

  @override
  Widget build(BuildContext context) {
    final tension = engine.tensionLbs(stringSetId: stringSetId, string: string);
    final tensionColor = engine.colorCode(instrumentType, tension).toColor();
    final frequency = engine.frequencyHz(string.note);
    final bloc = context.read<CalculatorBloc>();
    final physical = repository.getPhysicalString(
      stringSetId,
      string.physicalStringId,
    );

    return Row(
      children: [
        CalculatorCell(
          onIncrement: () {
            bloc.add(CalculatorScaleIncremented(index));
          },
          onDecrement: () {
            bloc.add(CalculatorScaleDecremented(index));
          },
          child: Text(
            '${formatDecimal(string.scaleLengthInches)}"',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        _gap,
        CalculatorCell(
          onIncrement: () {
            bloc.add(CalculatorNoteIncremented(index));
          },
          onDecrement: () {
            bloc.add(CalculatorNoteDecremented(index));
          },
          child: Text(
            string.note.label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        _gap,
        CalculatorCell(
          onIncrement: () {
            bloc.add(CalculatorGaugeIncremented(index));
          },
          onDecrement: () {
            bloc.add(CalculatorGaugeDecremented(index));
          },
          child: Text(
            formatGauge(physical.gaugeInches),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        _gap,
        CalculatorCell(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                tension.toStringAsFixed(2),
                style: TextStyle(
                  color: tensionColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'lbs',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
        _gap,
        CalculatorCell(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                frequency.toStringAsFixed(1),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Hz',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell({required this.label, this.trailing});

  final String label;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return CalculatorCell(
      child: SizedBox.expand(
        child: Stack(
          children: [
            if (trailing != null)
              Positioned(top: 4, right: 4, child: trailing!),
            Center(
              child: Padding(
                padding: EdgeInsets.only(
                  top: trailing != null ? 4 : 0,
                  right: trailing != null ? 18 : 0,
                ),
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF8D8D9D),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    height: 1.1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const Widget _gap = SizedBox(width: calculatorCellGap);
