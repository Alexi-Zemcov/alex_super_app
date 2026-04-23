import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:midi_playback/midi_playback.dart';
import 'package:vocal_warmup/src/features/warmup/domain/entities/warmup_plan.dart';
import 'package:vocal_warmup/src/features/warmup/domain/entities/warmup_step.dart';

sealed class WarmupSessionEvent extends Equatable {
  const WarmupSessionEvent();

  @override
  List<Object?> get props => [];
}

final class WarmupSessionStepStarted extends WarmupSessionEvent {
  const WarmupSessionStepStarted({
    required this.step,
    required this.stepIndex,
    required this.totalSteps,
  });

  final WarmupStep step;
  final int stepIndex;
  final int totalSteps;

  @override
  List<Object?> get props => [step, stepIndex, totalSteps];
}

final class WarmupSessionFinished extends WarmupSessionEvent {
  const WarmupSessionFinished();
}

class WarmupSessionRunner {
  WarmupSessionRunner(this._playbackService);

  final MidiPlaybackService _playbackService;
  final StreamController<WarmupSessionEvent> _events =
      StreamController<WarmupSessionEvent>.broadcast();

  Timer? _timer;
  WarmupPlan? _plan;
  int _currentStepIndex = 0;
  int _currentPhaseIndex = 0;
  int _beatDurationMs = 750;
  bool _isRunning = false;
  bool _isPaused = false;

  Stream<WarmupSessionEvent> get events => _events.stream;

  bool get isRunning => _isRunning;

  bool get isPaused => _isPaused;

  Future<void> start({required WarmupPlan plan, required int tempoBpm}) async {
    await stop();
    if (plan.isEmpty) {
      _events.add(const WarmupSessionFinished());
      return;
    }

    _plan = plan;
    _beatDurationMs = (60000 / tempoBpm).round();
    _currentStepIndex = 0;
    _currentPhaseIndex = 0;
    _isRunning = true;
    _isPaused = false;
    _startCurrentStep();
  }

  void pause() {
    if (!_isRunning || _isPaused) {
      return;
    }

    _isPaused = true;
    _timer?.cancel();
    unawaited(_playbackService.stopAll());
  }

  void resume() {
    if (!_isRunning || !_isPaused) {
      return;
    }

    _isPaused = false;
    unawaited(_playCurrentPhase());
  }

  Future<void> stop() async {
    _timer?.cancel();
    _timer = null;
    _plan = null;
    _currentStepIndex = 0;
    _currentPhaseIndex = 0;
    _isRunning = false;
    _isPaused = false;
    await _playbackService.stopAll();
  }

  Future<void> dispose() async {
    await stop();
    await _events.close();
  }

  void _startCurrentStep() {
    final plan = _plan;
    if (plan == null || _currentStepIndex >= plan.totalSteps) {
      _finish();
      return;
    }

    _currentPhaseIndex = 0;
    _events.add(
      WarmupSessionStepStarted(
        step: plan.steps[_currentStepIndex],
        stepIndex: _currentStepIndex + 1,
        totalSteps: plan.totalSteps,
      ),
    );
    unawaited(_playCurrentPhase());
  }

  Future<void> _playCurrentPhase() async {
    final plan = _plan;
    if (plan == null || !_isRunning || _isPaused) {
      return;
    }

    final step = plan.steps[_currentStepIndex];
    final phases = step.phases;
    if (_currentPhaseIndex >= phases.length) {
      _currentStepIndex += 1;
      _startCurrentStep();
      return;
    }

    final phase = phases[_currentPhaseIndex];
    await _playbackService.stopAll();
    if (!identical(_plan, plan) || !_isRunning || _isPaused) {
      return;
    }

    if (phase.chord case final chord?) {
      await _playbackService.playChord(chord, octave: phase.octave!);
    } else if (phase.note case final note?) {
      await _playbackService.playNote(note);
    }

    if (!identical(_plan, plan) || !_isRunning || _isPaused) {
      return;
    }

    _timer = Timer(Duration(milliseconds: _beatDurationMs), () {
      _currentPhaseIndex += 1;
      unawaited(_playCurrentPhase());
    });
  }

  void _finish() {
    _isRunning = false;
    _isPaused = false;
    _timer?.cancel();
    _timer = null;
    unawaited(_playbackService.stopAll());
    _events.add(const WarmupSessionFinished());
  }
}
