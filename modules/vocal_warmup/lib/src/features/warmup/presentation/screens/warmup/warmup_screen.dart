import 'dart:async';

import 'package:app_theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocal_warmup/src/features/warmup/domain/entities/vocal_exercise.dart';
import 'package:vocal_warmup/src/features/warmup/domain/entities/warmup_session_status.dart';
import 'package:vocal_warmup/src/features/warmup/presentation/screens/warmup/bloc/warmup_bloc.dart';
import 'package:vocal_warmup/src/features/warmup/presentation/screens/warmup/bloc/warmup_event.dart';
import 'package:vocal_warmup/src/features/warmup/presentation/screens/warmup/bloc/warmup_state.dart';
import 'package:vocal_warmup/src/features/warmup/presentation/widgets/exercise_details_sheet.dart';
import 'package:vocal_warmup/src/features/warmup/presentation/widgets/voice_type_picker.dart';
import 'package:vocal_warmup/src/features/warmup/presentation/widgets/warmup_status_chip.dart';

const unsupportedAudioIssueUrl =
    'https://github.com/Alexi-Zemcov/alex_super_app/issues/3';

class WarmupScreen extends StatefulWidget {
  const WarmupScreen({super.key});

  @override
  State<WarmupScreen> createState() => _WarmupScreenState();
}

class _WarmupScreenState extends State<WarmupScreen> {
  bool _voiceDialogVisible = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.quizColors;

    return BlocListener<WarmupBloc, WarmupState>(
      listenWhen: (previous, current) =>
          previous.requiresVoiceSelection != current.requiresVoiceSelection,
      listener: (context, state) {
        if (state.requiresVoiceSelection && !_voiceDialogVisible) {
          unawaited(_showInitialVoiceDialog());
        }
      },
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          title: Text(
            'Распевка',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: colors.textStrong,
              fontWeight: FontWeight.w800,
            ),
          ),
          actions: [
            BlocBuilder<WarmupBloc, WarmupState>(
              builder: (context, state) {
                return IconButton(
                  tooltip: 'Settings',
                  icon: Icon(Icons.tune_rounded, color: colors.textStrong),
                  onPressed: state.controlsLocked
                      ? null
                      : () {
                          unawaited(
                            showVoiceTypeSelectionSheet(
                              context,
                              selectedVoice: state.settings.voiceType,
                              onSelected: (voiceType) {
                                context.read<WarmupBloc>().add(
                                  WarmupVoiceSelected(voiceType),
                                );
                              },
                            ),
                          );
                        },
                );
              },
            ),
          ],
        ),
        body: SafeArea(
          child: BlocBuilder<WarmupBloc, WarmupState>(
            builder: (context, state) {
              if (state.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (!state.hasPlayableAudio) const _UnsupportedAudioBanner(),
                  _SummaryCard(state: state),
                  const SizedBox(height: 16),
                  _ExerciseSection(state: state),
                  const SizedBox(height: 16),
                  _TempoSection(state: state),
                  const SizedBox(height: 16),
                  _StepSection(state: state),
                  const SizedBox(height: 16),
                  _ControlsSection(state: state),
                  if (state.isRangeClamped) ...[
                    const SizedBox(height: 16),
                    _RangeClampNotice(),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _showInitialVoiceDialog() async {
    if (!mounted) {
      return;
    }

    _voiceDialogVisible = true;
    final bloc = context.read<WarmupBloc>();
    await showVoiceTypeSelectionDialog(
      context,
      selectedVoice: bloc.state.settings.voiceType,
      onSelected: (voiceType) {
        bloc.add(WarmupVoiceSelected(voiceType));
      },
    );
    _voiceDialogVisible = false;

    if (mounted && context.read<WarmupBloc>().state.requiresVoiceSelection) {
      unawaited(_showInitialVoiceDialog());
    }
  }
}

class _UnsupportedAudioBanner extends StatelessWidget {
  const _UnsupportedAudioBanner();

  @override
  Widget build(BuildContext context) {
    final colors = context.quizColors;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.accentRed.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.accentRed.withValues(alpha: 0.35)),
      ),
      child: Text(
        'Audio playback is unavailable on this platform. TODO tracked in $unsupportedAudioIssueUrl',
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: colors.textStrong, height: 1.4),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.state});

  final WarmupState state;

  @override
  Widget build(BuildContext context) {
    final colors = context.quizColors;
    final selectedVoice = state.settings.voiceType;
    final displayedBaseNote = state.displayedBaseNote;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    selectedVoice?.displayName ?? 'Тип голоса не выбран',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: colors.textStrong,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                WarmupStatusChip(status: state.sessionStatus),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              selectedVoice == null
                  ? 'Выберите голос, затем задайте упражнение и диапазон транспонирования.'
                  : 'Старт: ${selectedVoice.startNote.label()} · Диапазон: ${selectedVoice.minNote.label()} — ${selectedVoice.maxNote.label()}',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: colors.textSoft),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _InfoTile(
                    label: 'Current tonality',
                    value: state.tonalityLabel,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _InfoTile(
                    label: 'Base note',
                    value: displayedBaseNote?.label() ?? '—',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _InfoTile(
                    label: 'Current step',
                    value: '${state.currentStep} / ${state.totalSteps}',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _InfoTile(
                    label: 'Exercise',
                    value: state.settings.exercise.title,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ExerciseSection extends StatelessWidget {
  const _ExerciseSection({required this.state});

  final WarmupState state;

  @override
  Widget build(BuildContext context) {
    final colors = context.quizColors;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Упражнение',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: colors.textStrong,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<VocalExercise>(
              initialValue: state.settings.exercise,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: VocalExercise.values.map((exercise) {
                return DropdownMenuItem(
                  value: exercise,
                  child: Text('${exercise.title} / ${exercise.subtitle}'),
                );
              }).toList(),
              onChanged: state.controlsLocked
                  ? null
                  : (value) {
                      if (value != null) {
                        context.read<WarmupBloc>().add(
                          WarmupExerciseChanged(value),
                        );
                      }
                    },
            ),
            const SizedBox(height: 12),
            Text(
              state.settings.exercise.summary,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colors.textSoft,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () {
                  unawaited(
                    showExerciseDetailsSheet(context, state.settings.exercise),
                  );
                },
                child: const Text('Подробнее'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TempoSection extends StatelessWidget {
  const _TempoSection({required this.state});

  final WarmupState state;

  @override
  Widget build(BuildContext context) {
    final colors = context.quizColors;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tempo',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: colors.textStrong,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${state.settings.tempoBpm} BPM',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: colors.textSoft),
            ),
            Slider(
              min: 60,
              max: 120,
              divisions: 12,
              value: state.settings.tempoBpm.toDouble(),
              onChanged: state.controlsLocked
                  ? null
                  : (value) {
                      context.read<WarmupBloc>().add(
                        WarmupTempoChanged(value.round()),
                      );
                    },
            ),
          ],
        ),
      ),
    );
  }
}

class _StepSection extends StatelessWidget {
  const _StepSection({required this.state});

  final WarmupState state;

  @override
  Widget build(BuildContext context) {
    final colors = context.quizColors;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SliderHeader(
              title: 'Шаги вверх',
              value: state.settings.stepsUp.toString(),
            ),
            Slider(
              min: 0,
              max: 12,
              divisions: 12,
              value: state.settings.stepsUp.toDouble(),
              onChanged: state.controlsLocked
                  ? null
                  : (value) {
                      context.read<WarmupBloc>().add(
                        WarmupStepsUpChanged(value.round()),
                      );
                    },
            ),
            const SizedBox(height: 8),
            _SliderHeader(
              title: 'Шаги вниз',
              value: state.settings.stepsDown.toString(),
            ),
            Slider(
              min: 0,
              max: 12,
              divisions: 12,
              value: state.settings.stepsDown.toDouble(),
              onChanged: state.controlsLocked
                  ? null
                  : (value) {
                      context.read<WarmupBloc>().add(
                        WarmupStepsDownChanged(value.round()),
                      );
                    },
            ),
          ],
        ),
      ),
    );
  }
}

class _ControlsSection extends StatelessWidget {
  const _ControlsSection({required this.state});

  final WarmupState state;

  @override
  Widget build(BuildContext context) {
    final pauseLabel = state.sessionStatus == WarmupSessionStatus.paused
        ? 'Continue'
        : 'Pause';

    return Row(
      children: [
        Expanded(
          child: FilledButton(
            onPressed: state.canStart
                ? () =>
                      context.read<WarmupBloc>().add(const WarmupStartPressed())
                : null,
            child: const Text('Start'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton(
            onPressed: switch (state.sessionStatus) {
              WarmupSessionStatus.playing =>
                () =>
                    context.read<WarmupBloc>().add(const WarmupPausePressed()),
              WarmupSessionStatus.paused =>
                () =>
                    context.read<WarmupBloc>().add(const WarmupResumePressed()),
              _ => null,
            },
            child: Text(pauseLabel),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton(
            onPressed: state.sessionStatus.isLocked
                ? () =>
                      context.read<WarmupBloc>().add(const WarmupStopPressed())
                : null,
            child: const Text('Stop'),
          ),
        ),
      ],
    );
  }
}

class _RangeClampNotice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.quizColors;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.cardAlt,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border),
      ),
      child: Text(
        'Маршрут был сокращён, потому что часть шагов выходила за пределы выбранного диапазона.',
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: colors.textSoft, height: 1.4),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.quizColors;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.cardAlt,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: colors.textMuted),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: colors.textStrong,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SliderHeader extends StatelessWidget {
  const _SliderHeader({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.quizColors;

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: colors.textStrong,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: colors.textSoft),
        ),
      ],
    );
  }
}
