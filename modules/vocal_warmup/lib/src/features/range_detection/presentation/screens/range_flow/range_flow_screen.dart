import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocal_warmup/src/features/range_detection/domain/entities/range_detection_target.dart';
import 'package:vocal_warmup/src/features/range_detection/domain/entities/vocal_range.dart';
import 'package:vocal_warmup/src/features/range_detection/domain/entities/voice_type.dart';
import 'package:vocal_warmup/src/features/range_detection/presentation/screens/range_flow/bloc/range_flow_bloc.dart';
import 'package:vocal_warmup/src/features/range_detection/presentation/screens/range_flow/bloc/range_flow_event.dart';
import 'package:vocal_warmup/src/features/range_detection/presentation/screens/range_flow/bloc/range_flow_state.dart';
import 'package:vocal_warmup/src/features/range_detection/presentation/widgets/range_visuals.dart';
import 'package:vocal_warmup/src/features/warmup/presentation/screens/exercise_selection/exercise_selection_screen.dart';

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
    final target = state.target;
    final subtitle = target == RangeDetectionTarget.lowest
        ? 'Спойте самую низкую комфортную ноту'
        : 'Теперь спойте самую высокую комфортную ноту';

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
                      subtitle,
                      style: const TextStyle(
                        color: VocalWarmupColors.textStrong,
                        fontSize: 16,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 28),
                    const RangeWave(height: 142),
                    const SizedBox(height: 44),
                    const Center(child: MicrophoneOrb()),
                    const SizedBox(height: 36),
                    const Center(child: ListeningBars()),
                    const SizedBox(height: 12),
                    const Center(
                      child: Text(
                        'Слушаем...',
                        style: TextStyle(
                          color: Color(0xFF4F5470),
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 42),
                    Center(
                      child: RangeStepIndicator(
                        activeIndex: target == RangeDetectionTarget.lowest
                            ? 0
                            : 1,
                      ),
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
}

class _RangeResultScreen extends StatelessWidget {
  const _RangeResultScreen({required this.range, required this.voiceType});

  final VocalRange range;
  final VoiceType voiceType;

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
                  const Text(
                    'Ваш диапазон',
                    style: TextStyle(
                      color: VocalWarmupColors.textStrong,
                      fontSize: 23,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: _RangeEndpoint(
                          label: 'От',
                          note: range.lowestNote.label(),
                          frequencyHz: range.lowestFrequencyHz,
                        ),
                      ),
                      const SizedBox(width: 36),
                      Expanded(
                        child: _RangeEndpoint(
                          label: 'До',
                          note: range.highestNote.label(),
                          frequencyHz: range.highestFrequencyHz,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  const StaticRangeSlider(),
                  const SizedBox(height: 14),
                  PianoRangeKeyboard(range: range),
                  const SizedBox(height: 30),
                  _VoiceTypeCard(voiceType: voiceType),
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
                        const RangeFlowContinuePressed(),
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
}

class _RangeEndpoint extends StatelessWidget {
  const _RangeEndpoint({
    required this.label,
    required this.note,
    required this.frequencyHz,
  });

  final String label;
  final String note;
  final int frequencyHz;

  @override
  Widget build(BuildContext context) {
    return Column(
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
          note,
          style: const TextStyle(
            color: VocalWarmupColors.textStrong,
            fontSize: 48,
            height: 1,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '$frequencyHz Гц',
          style: const TextStyle(
            color: VocalWarmupColors.textMuted,
            fontSize: 15,
          ),
        ),
      ],
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
