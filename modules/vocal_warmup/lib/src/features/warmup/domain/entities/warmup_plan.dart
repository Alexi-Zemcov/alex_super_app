import 'package:equatable/equatable.dart';
import 'package:vocal_warmup/src/features/warmup/domain/entities/warmup_step.dart';

class WarmupPlan extends Equatable {
  const WarmupPlan({required this.steps, required this.isRangeClamped});

  final List<WarmupStep> steps;
  final bool isRangeClamped;

  int get totalSteps => steps.length;

  bool get isEmpty => steps.isEmpty;

  @override
  List<Object?> get props => [steps, isRangeClamped];
}
