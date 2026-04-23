import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:vocal_warmup/src/features/range_detection/domain/entities/vocal_range.dart';

abstract final class VocalWarmupColors {
  static const background = Color(0xFFF8F8FE);
  static const surface = Color(0xFFF0F1F7);
  static const surfaceSoft = Color(0xFFF5F6FA);
  static const textStrong = Color(0xFF22232B);
  static const textMuted = Color(0xFF8E93A1);
  static const accent = Color(0xFF6657F5);
  static const accentSoft = Color(0xFFDCD7FF);
  static const border = Color(0xFFE2E4EC);
}

class RangeWave extends StatelessWidget {
  const RangeWave({this.height = 120, super.key});

  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(painter: _RangeWavePainter()),
    );
  }
}

class MicrophoneOrb extends StatelessWidget {
  const MicrophoneOrb({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 132,
      height: 132,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.82),
        boxShadow: [
          BoxShadow(
            color: VocalWarmupColors.accent.withValues(alpha: 0.08),
            blurRadius: 28,
            spreadRadius: 10,
          ),
        ],
      ),
      child: const Icon(
        Icons.mic_rounded,
        size: 42,
        color: VocalWarmupColors.accent,
      ),
    );
  }
}

class ListeningBars extends StatelessWidget {
  const ListeningBars({super.key});

  static const _heights = [10.0, 16.0, 24.0, 30.0, 18.0, 12.0];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (final height in _heights)
          Container(
            width: 3,
            height: height,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: VocalWarmupColors.accent,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
      ],
    );
  }
}

class RangeStepIndicator extends StatelessWidget {
  const RangeStepIndicator({required this.activeIndex, super.key});

  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var index = 0; index < 3; index++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 38,
            height: 4,
            margin: const EdgeInsets.symmetric(horizontal: 7),
            decoration: BoxDecoration(
              color: index == activeIndex
                  ? VocalWarmupColors.accent
                  : const Color(0xFFD1D4DD),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
      ],
    );
  }
}

class StaticRangeSlider extends StatelessWidget {
  const StaticRangeSlider({required this.range, super.key});

  final VocalRange range;

  static const _minMidi = 24.0;
  static const _maxMidi = 96.0;

  @override
  Widget build(BuildContext context) {
    final span = _maxMidi - _minMidi;
    final start = ((range.lowestNote.midi - _minMidi) / span)
        .clamp(0.0, 1.0)
        .toDouble();
    final end = ((range.highestNote.midi - _minMidi) / span)
        .clamp(0.0, 1.0)
        .toDouble();

    return SizedBox(
      height: 32,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final trackWidth = constraints.maxWidth - 32;
          final activeLeft = 16.0 + (trackWidth * start);
          final activeRight = 16.0 + (trackWidth * end);

          return Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 5,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3E5EC),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              Positioned(
                left: activeLeft,
                right: constraints.maxWidth - activeRight,
                child: Container(
                  height: 5,
                  decoration: BoxDecoration(
                    color: VocalWarmupColors.accent,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
              Positioned(left: activeLeft - 12, child: const _SliderThumb()),
              Positioned(
                right: constraints.maxWidth - activeRight - 12,
                child: const _SliderThumb(),
              ),
            ],
          );
        },
      ),
    );
  }
}

class PianoRangeKeyboard extends StatelessWidget {
  const PianoRangeKeyboard({required this.range, super.key});

  final VocalRange range;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      width: double.infinity,
      child: CustomPaint(painter: _PianoRangePainter(range)),
    );
  }
}

class VoiceWaveMark extends StatelessWidget {
  const VoiceWaveMark({this.color = VocalWarmupColors.accent, super.key});

  final Color color;

  static const _heights = [12.0, 24.0, 34.0, 18.0, 28.0, 42.0, 30.0, 20.0];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        for (final height in _heights)
          Container(
            width: 3,
            height: height,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
      ],
    );
  }
}

class ExerciseWaveIcon extends StatelessWidget {
  const ExerciseWaveIcon({required this.active, super.key});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 62,
      height: 48,
      child: Center(
        child: VoiceWaveMark(
          color: active
              ? VocalWarmupColors.accent
              : VocalWarmupColors.textMuted,
        ),
      ),
    );
  }
}

class _SliderThumb extends StatelessWidget {
  const _SliderThumb();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: VocalWarmupColors.accentSoft, width: 2),
      ),
    );
  }
}

class _RangeWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintPrimary = Paint()
      ..color = VocalWarmupColors.accent.withValues(alpha: 0.64)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;
    final paintSecondary = Paint()
      ..color = VocalWarmupColors.accent.withValues(alpha: 0.12)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    canvas.drawPath(_buildWave(size, 0.0, 0.78), paintPrimary);
    canvas.drawPath(_buildWave(size, math.pi / 2, 0.46), paintSecondary);
  }

  Path _buildWave(Size size, double phase, double amplitudeFactor) {
    final path = Path();
    for (var x = 0.0; x <= size.width; x += 4) {
      final progress = x / size.width;
      final y =
          size.height * 0.5 +
          math.sin(progress * math.pi * 3.1 + phase) *
              size.height *
              0.22 *
              amplitudeFactor +
          math.sin(progress * math.pi * 7.4 + phase) * size.height * 0.08;
      if (x == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PianoRangePainter extends CustomPainter {
  const _PianoRangePainter(this.range);

  final VocalRange range;

  @override
  void paint(Canvas canvas, Size size) {
    final whitePaint = Paint()..color = Colors.white;
    final highlightPaint = Paint()..color = VocalWarmupColors.accentSoft;
    final borderPaint = Paint()
      ..color = const Color(0xFFABB0BC)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final blackPaint = Paint()..color = const Color(0xFF20222A);

    const keyCount = 22;
    final keyWidth = size.width / keyCount;
    final startHighlight = (range.lowestNote.midi % keyCount).clamp(4, 9);
    final endHighlight = (startHighlight + 6).clamp(10, 17);

    for (var index = 0; index < keyCount; index++) {
      final rect = Rect.fromLTWH(index * keyWidth, 0, keyWidth, size.height);
      canvas.drawRect(
        rect,
        index >= startHighlight && index <= endHighlight
            ? highlightPaint
            : whitePaint,
      );
      canvas.drawRect(rect, borderPaint);
    }

    const blackPattern = {0, 1, 3, 4, 5};
    for (var index = 0; index < keyCount - 1; index++) {
      if (!blackPattern.contains(index % 7)) {
        continue;
      }
      final left = (index + 0.68) * keyWidth;
      final rect = Rect.fromLTWH(left, 0, keyWidth * 0.58, size.height * 0.62);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(1)),
        blackPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PianoRangePainter oldDelegate) {
    return oldDelegate.range != range;
  }
}
