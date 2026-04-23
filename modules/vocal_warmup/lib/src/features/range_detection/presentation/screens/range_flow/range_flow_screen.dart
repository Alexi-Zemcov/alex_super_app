import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_theory/music_theory.dart';
import 'package:vocal_warmup/src/features/range_detection/domain/entities/range_detection_target.dart';
import 'package:vocal_warmup/src/features/range_detection/domain/entities/vocal_range.dart';
import 'package:vocal_warmup/src/features/range_detection/domain/entities/voice_type.dart';
import 'package:vocal_warmup/src/features/range_detection/domain/services/note_preview_service.dart';
import 'package:vocal_warmup/src/features/range_detection/domain/usecases/classify_voice_use_case.dart';
import 'package:vocal_warmup/src/features/range_detection/presentation/screens/range_flow/bloc/range_flow_bloc.dart';
import 'package:vocal_warmup/src/features/range_detection/presentation/screens/range_flow/bloc/range_flow_event.dart';
import 'package:vocal_warmup/src/features/range_detection/presentation/screens/range_flow/bloc/range_flow_state.dart';
import 'package:vocal_warmup/src/features/range_detection/presentation/widgets/range_visuals.dart';
import 'package:vocal_warmup/src/features/warmup/presentation/screens/exercise_selection/exercise_selection_screen.dart';

const _pickerMinMidi = 24;
const _pickerMaxMidi = 96;
const _holdSeconds = 3.0;

class RangeFlowScreen extends StatelessWidget {
  const RangeFlowScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RangeFlowBloc, RangeFlowState>(
      builder: (context, state) {
        return switch (state) {
          RangeFlowInitial() || RangeFlowLoading() => const _LoadingScreen(),
          RangeFlowListening() => _RangeListeningScreen(state: state),
          RangeFlowResult() => _RangeResultScreen(
            range: state.range,
            voiceType: state.voiceType,
          ),
          RangeFlowExerciseSelection() => ExerciseSelectionScreen(
            range: state.range,
          ),
          RangeFlowFailure() => _FailureScreen(message: state.message),
        };
      },
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: VocalWarmupColors.background,
      body: Center(
        child: CircularProgressIndicator(color: VocalWarmupColors.accent),
      ),
    );
  }
}

class _RangeListeningScreen extends StatelessWidget {
  const _RangeListeningScreen({required this.state});

  final RangeFlowListening state;

  @override
  Widget build(BuildContext context) {
    final isLowest = state.target == RangeDetectionTarget.lowest;
    final direction = isLowest ? 'вниз' : 'вверх';
    final currentNoteLabel = state.currentNote?.label() ?? '...';

    return Scaffold(
      backgroundColor: VocalWarmupColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 42, 28, 28),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 28),
                    const Text(
                      'Определение\nдиапазона',
                      style: TextStyle(
                        color: VocalWarmupColors.textStrong,
                        fontSize: 28,
                        height: 1.05,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      isLowest
                          ? 'Начните с комфортной ноты, затем двигайтесь вниз и удерживайте минимально комфортную ноту 3 секунды.'
                          : 'Начните с комфортной ноты, затем двигайтесь вверх и удерживайте максимально комфортную ноту 3 секунды.',
                      style: const TextStyle(
                        color: VocalWarmupColors.textStrong,
                        fontSize: 16,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 28),
                    const RangeWave(height: 142),
                    const SizedBox(height: 44),
                    Center(
                      child: Column(
                        children: [
                          const MicrophoneOrb(),
                          const SizedBox(height: 24),
                          Text(
                            currentNoteLabel,
                            style: const TextStyle(
                              color: VocalWarmupColors.accent,
                              fontSize: 36,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Center(child: ListeningBars()),
                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        _statusText(state, direction),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF4F5470),
                          fontSize: 14,
                          height: 1.35,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _ListeningProgressCard(state: state, direction: direction),
                    const SizedBox(height: 42),
                    Center(
                      child: RangeStepIndicator(activeIndex: isLowest ? 0 : 1),
                    ),
                    const SizedBox(height: 18),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _statusText(RangeFlowListening state, String direction) {
    if (state.comfortNote == null) {
      return 'Спойте комфортную ноту';
    }
    if (!state.hasMovedTowardTarget) {
      return 'Теперь двигайтесь $direction от ${state.comfortNote!.label()}';
    }
    if (state.currentNote == null) {
      return 'Вернитесь к ноте и удерживайте её';
    }
    if (state.holdProgress <= 0) {
      return 'Зафиксируйте ${state.currentNote!.label()} на 3 секунды';
    }
    final remainingSeconds = (_holdSeconds * (1 - state.holdProgress)).clamp(
      0.0,
      _holdSeconds,
    );
    return 'Удерживайте ${state.currentNote!.label()} ещё ${remainingSeconds.toStringAsFixed(1)} сек.';
  }
}

class _ListeningProgressCard extends StatelessWidget {
  const _ListeningProgressCard({required this.state, required this.direction});

  final RangeFlowListening state;
  final String direction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: VocalWarmupColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _ListeningNoteStat(
                  label: 'Комфортная',
                  value: state.comfortNote?.label() ?? '...',
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: _ListeningNoteStat(
                  label: 'Текущая',
                  value: state.currentNote?.label() ?? '...',
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            state.hasMovedTowardTarget
                ? 'Удержание границы'
                : 'Двигайтесь $direction',
            style: const TextStyle(
              color: VocalWarmupColors.textMuted,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: state.hasMovedTowardTarget ? state.holdProgress : 0,
              backgroundColor: const Color(0xFFE8EAF2),
              valueColor: const AlwaysStoppedAnimation<Color>(
                VocalWarmupColors.accent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ListeningNoteStat extends StatelessWidget {
  const _ListeningNoteStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: VocalWarmupColors.textMuted,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: VocalWarmupColors.textStrong,
            fontSize: 22,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _RangeResultScreen extends StatefulWidget {
  const _RangeResultScreen({required this.range, required this.voiceType});

  final VocalRange range;
  final VoiceType voiceType;

  @override
  State<_RangeResultScreen> createState() => _RangeResultScreenState();
}

class _RangeResultScreenState extends State<_RangeResultScreen> {
  late final NotePreviewService _notePreviewService;
  late final ClassifyVoiceUseCase _classifyVoice;
  late VocalRange _selectedRange;
  late VoiceType _selectedVoiceType;

  @override
  void initState() {
    super.initState();
    _selectedRange = widget.range;
    _selectedVoiceType = widget.voiceType;
    _notePreviewService = context.read<NotePreviewService>();
    _classifyVoice = context.read<ClassifyVoiceUseCase>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_notePreviewService.previewRange(_selectedRange));
    });
  }

  @override
  void didUpdateWidget(covariant _RangeResultScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.range != widget.range ||
        oldWidget.voiceType != widget.voiceType) {
      _selectedRange = widget.range;
      _selectedVoiceType = widget.voiceType;
      unawaited(_notePreviewService.previewRange(_selectedRange));
    }
  }

  @override
  void dispose() {
    unawaited(_notePreviewService.stop());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VocalWarmupColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDADCE5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Ваш диапазон',
                          style: TextStyle(
                            color: VocalWarmupColors.textStrong,
                            fontSize: 23,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        key: const Key('rangeFlow.rangeReplay'),
                        tooltip: 'Проиграть диапазон',
                        onPressed: () {
                          unawaited(
                            _notePreviewService.previewRange(_selectedRange),
                          );
                        },
                        icon: const Icon(
                          Icons.volume_up_rounded,
                          color: VocalWarmupColors.accent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: _EditableRangeEndpoint(
                          key: const Key('rangeFlow.lowestEndpoint'),
                          label: 'От',
                          note: _selectedRange.lowestNote,
                          onTap: () => _showPicker(_RangeEndpointType.lowest),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: _EditableRangeEndpoint(
                          key: const Key('rangeFlow.highestEndpoint'),
                          label: 'До',
                          note: _selectedRange.highestNote,
                          onTap: () => _showPicker(_RangeEndpointType.highest),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  StaticRangeSlider(range: _selectedRange),
                  const SizedBox(height: 14),
                  PianoRangeKeyboard(range: _selectedRange),
                  const SizedBox(height: 30),
                  _VoiceTypeCard(voiceType: _selectedVoiceType),
                  const SizedBox(height: 36),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: VocalWarmupColors.accent,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(58),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onPressed: () {
                      context.read<RangeFlowBloc>().add(
                        RangeFlowContinuePressed(_selectedRange),
                      );
                    },
                    child: const Text('Продолжить'),
                  ),
                  const SizedBox(height: 14),
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: VocalWarmupColors.textStrong,
                      backgroundColor: const Color(0xFFF1F2F7),
                      minimumSize: const Size.fromHeight(56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                    onPressed: () {
                      context.read<RangeFlowBloc>().add(
                        const RangeFlowRestarted(),
                      );
                    },
                    child: const Text('Заново'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showPicker(_RangeEndpointType endpointType) async {
    final notes = _pickerNotes(endpointType);
    final currentNote = endpointType == _RangeEndpointType.lowest
        ? _selectedRange.lowestNote
        : _selectedRange.highestNote;
    final initialIndex = notes.indexWhere((note) => note == currentNote);
    final controller = FixedExtentScrollController(
      initialItem: initialIndex < 0 ? 0 : initialIndex,
    );

    try {
      await showCupertinoModalPopup<void>(
        context: context,
        builder: (context) {
          return Material(
            color: Colors.transparent,
            child: Container(
              height: 320,
              padding: const EdgeInsets.only(top: 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              endpointType == _RangeEndpointType.lowest
                                  ? 'Нижняя нота'
                                  : 'Верхняя нота',
                              style: const TextStyle(
                                color: VocalWarmupColors.textStrong,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Готово'),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: CupertinoPicker(
                        key: Key('rangeFlow.${endpointType.name}Picker'),
                        itemExtent: 42,
                        scrollController: controller,
                        useMagnifier: true,
                        magnification: 1.08,
                        onSelectedItemChanged: (index) {
                          _updateRange(endpointType, notes[index]);
                        },
                        children: [
                          for (final note in notes)
                            Center(
                              child: Text(
                                note.label(),
                                style: const TextStyle(
                                  color: VocalWarmupColors.textStrong,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    } finally {
      controller.dispose();
    }
  }

  void _updateRange(_RangeEndpointType endpointType, ScientificNote note) {
    final updatedRange = endpointType == _RangeEndpointType.lowest
        ? _selectedRange.copyWith(lowestNote: note)
        : _selectedRange.copyWith(highestNote: note);
    setState(() {
      _selectedRange = updatedRange;
      _selectedVoiceType = _classifyVoice(updatedRange);
    });
    unawaited(_notePreviewService.previewNote(note));
  }

  List<ScientificNote> _pickerNotes(_RangeEndpointType endpointType) {
    final minMidi = endpointType == _RangeEndpointType.lowest
        ? _pickerMinMidi
        : (_selectedRange.lowestNote.midi + 1).clamp(
            _pickerMinMidi,
            _pickerMaxMidi,
          );
    final maxMidi = endpointType == _RangeEndpointType.lowest
        ? (_selectedRange.highestNote.midi - 1).clamp(
            _pickerMinMidi,
            _pickerMaxMidi,
          )
        : _pickerMaxMidi;

    return [
      for (var midi = minMidi; midi <= maxMidi; midi += 1)
        ScientificNote.fromMidi(midi),
    ];
  }
}

enum _RangeEndpointType { lowest, highest }

class _EditableRangeEndpoint extends StatelessWidget {
  const _EditableRangeEndpoint({
    required this.label,
    required this.note,
    required this.onTap,
    super.key,
  });

  final String label;
  final ScientificNote note;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: VocalWarmupColors.textMuted,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                note.label(),
                style: const TextStyle(
                  color: VocalWarmupColors.textStrong,
                  fontSize: 48,
                  height: 1,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${note.frequencyHz.round()} Гц',
                style: const TextStyle(
                  color: VocalWarmupColors.textMuted,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 10),
              const Row(
                children: [
                  Icon(
                    Icons.tune_rounded,
                    size: 16,
                    color: VocalWarmupColors.accent,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Изменить',
                    style: TextStyle(
                      color: VocalWarmupColors.accent,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VoiceTypeCard extends StatelessWidget {
  const _VoiceTypeCard({required this.voiceType});

  final VoiceType voiceType;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 118),
      padding: const EdgeInsets.fromLTRB(20, 16, 18, 16),
      decoration: BoxDecoration(
        color: VocalWarmupColors.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ваш тембр',
                  style: TextStyle(color: Color(0xFF656B78), fontSize: 13),
                ),
                const SizedBox(height: 14),
                Text(
                  voiceType.title,
                  style: const TextStyle(
                    color: VocalWarmupColors.textStrong,
                    fontSize: 27,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  voiceType.description,
                  style: const TextStyle(
                    color: Color(0xFF656B78),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const VoiceWaveMark(color: Color(0xFFAEB4EF)),
        ],
      ),
    );
  }
}

class _FailureScreen extends StatelessWidget {
  const _FailureScreen({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VocalWarmupColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: VocalWarmupColors.textStrong,
                    fontSize: 18,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 18),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: VocalWarmupColors.accent,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    context.read<RangeFlowBloc>().add(
                      const RangeFlowRestarted(),
                    );
                  },
                  child: const Text('Повторить'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
