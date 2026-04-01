import 'dart:math' as math;

import 'package:circle_of_fifths/src/features/circle/domain/domain.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Custom painter for the Circle of Fifths visualization.
///
/// Draws three concentric rings:
/// - Outer ring: Major chords
/// - Middle ring: Minor chords
/// - Inner ring: Diminished chords
class CircleOfFifthsPainter extends CustomPainter {
  CircleOfFifthsPainter({
    required this.currentKey,
    this.lastPlayedChord,
    this.backgroundColor = const Color(0xFF212121),
    this.ringColors = _defaultRingColors,
    this.centerColor = const Color(0xFF1A1A1A),
    this.centerForegroundColor = Colors.white,
    this.mutedLabelColor = Colors.white70,
  });

  /// The currently selected musical key for highlighting.
  final MusicKey currentKey;

  /// The most recently played chord.
  final Chord? lastPlayedChord;

  /// Background color for non-highlighted segments.
  final Color backgroundColor;

  final List<Color> ringColors;

  final Color centerColor;

  final Color centerForegroundColor;

  final Color mutedLabelColor;

  /// Number of segments (one for each note in chromatic scale).
  static const int segmentCount = 12;

  /// Angle per segment in radians.
  static const double segmentAngle = 2 * math.pi / segmentCount;

  /// Ring configuration: [innerRadius ratio, outerRadius ratio].
  static const List<List<double>> ringRadii = [
    [0.72, 1.0], // Outer ring (major)
    [0.50, 0.72], // Middle ring (minor)
    [0.35, 0.50], // Inner ring (diminished)
  ];

  /// Center circle radius ratio.
  static const double centerRadius = 0.35;

  /// Colors for the rings when not highlighted.
  static const List<Color> _defaultRingColors = [
    Color(0xFF424242), // Outer ring - grey 800
    Color(0xFF616161), // Middle ring - grey 700
    Color(0xFF757575), // Inner ring - grey 600
  ];

  /// Starting offset in circleOfFifths array for each ring.
  /// [major offset, minor offset, diminished offset]
  static const List<int> ringOffsets = [0, 3, 5];

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    // Draw segments for each ring.
    _drawRing(canvas, center, radius, 0, ChordQuality.major);
    _drawRing(canvas, center, radius, 1, ChordQuality.minor);
    _drawRing(canvas, center, radius, 2, ChordQuality.diminished);

    // Draw center circle with treble clef.
    _drawCenter(canvas, center, radius);

    // Draw chord labels.
    _drawLabels(canvas, center, radius);
  }

  void _drawRing(
    Canvas canvas,
    Offset center,
    double radius,
    int ringIndex,
    ChordQuality quality,
  ) {
    final innerRadius = radius * ringRadii[ringIndex][0];
    final outerRadius = radius * ringRadii[ringIndex][1];

    for (var i = 0; i < segmentCount; i++) {
      final offsetIndex = (i + ringOffsets[ringIndex]) % segmentCount;
      final note = Note.circleOfFifths[offsetIndex];
      final chord = Chord(note, quality);

      // Start angle: C is at top (270° or -90° in standard coords).
      // Flutter uses clockwise from 3 o'clock, so -90° = -π/2.
      final startAngle = -math.pi / 2 + (i * segmentAngle) - (segmentAngle / 2);

      // Determine color based on whether chord is in current key.
      var segmentColor = ringColors[ringIndex];
      final highlightColor = currentKey.getChordColor(chord);
      if (highlightColor != null) {
        segmentColor = highlightColor;
      }

      _drawSegment(
        canvas,
        center,
        innerRadius,
        outerRadius,
        startAngle,
        segmentAngle,
        segmentColor,
      );
    }
  }

  void _drawSegment(
    Canvas canvas,
    Offset center,
    double innerRadius,
    double outerRadius,
    double startAngle,
    double sweepAngle,
    Color color,
  ) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    // Outer arc.
    path.addArc(
      Rect.fromCircle(center: center, radius: outerRadius),
      startAngle,
      sweepAngle,
    );

    // Line to inner arc end point.
    final innerEndAngle = startAngle + sweepAngle;
    path.lineTo(
      center.dx + innerRadius * math.cos(innerEndAngle),
      center.dy + innerRadius * math.sin(innerEndAngle),
    );

    // Inner arc (reverse direction).
    path.arcTo(
      Rect.fromCircle(center: center, radius: innerRadius),
      innerEndAngle,
      -sweepAngle,
      false,
    );

    path.close();
    canvas.drawPath(path, paint);

    // Draw subtle border.
    final borderPaint = Paint()
      ..color = backgroundColor.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawPath(path, borderPaint);
  }

  void _drawCenter(Canvas canvas, Offset center, double radius) {
    final centerR = radius * centerRadius;

    // Draw center circle.
    final centerPaint = Paint()
      ..color = centerColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, centerR, centerPaint);

    // Draw staff lines.
    final staffPaint = Paint()
      ..color = centerForegroundColor.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final staffHeight = centerR * 0.6;
    final lineSpacing = staffHeight / 4;
    final staffTop = center.dy - staffHeight / 2;
    final staffWidth = centerR * 0.7;

    for (var i = 0; i < 5; i++) {
      final y = staffTop + i * lineSpacing;
      canvas.drawLine(
        Offset(center.dx - staffWidth / 2, y),
        Offset(center.dx + staffWidth / 2, y),
        staffPaint,
      );
    }

    // Draw treble clef symbol.
    final clefPainter = TextPainter(
      text: TextSpan(
        text: '𝄞',
        style: TextStyle(
          fontSize: centerR * 1.2,
          color: centerForegroundColor.withValues(alpha: 0.8),
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    clefPainter.layout();
    clefPainter.paint(
      canvas,
      Offset(
        center.dx - clefPainter.width / 2,
        center.dy - clefPainter.height / 2 + centerR * 0.05,
      ),
    );
  }

  void _drawLabels(Canvas canvas, Offset center, double radius) {
    // Draw labels for each ring.
    _drawRingLabels(canvas, center, radius, 0, ChordQuality.major);
    _drawRingLabels(canvas, center, radius, 1, ChordQuality.minor);
    _drawRingLabels(canvas, center, radius, 2, ChordQuality.diminished);
  }

  void _drawRingLabels(
    Canvas canvas,
    Offset center,
    double radius,
    int ringIndex,
    ChordQuality quality,
  ) {
    final innerRadius = radius * ringRadii[ringIndex][0];
    final outerRadius = radius * ringRadii[ringIndex][1];
    final labelRadius = (innerRadius + outerRadius) / 2;

    // Font sizes for different rings.
    final fontSizes = [radius * 0.12, radius * 0.08, radius * 0.06];
    final fontSize = fontSizes[ringIndex];

    for (var i = 0; i < segmentCount; i++) {
      final offsetIndex = (i + ringOffsets[ringIndex]) % segmentCount;
      final note = Note.circleOfFifths[offsetIndex];
      final chord = Chord(note, quality);

      // Angle to center of segment.
      final angle = -math.pi / 2 + (i * segmentAngle);

      final x = center.dx + labelRadius * math.cos(angle);
      final y = center.dy + labelRadius * math.sin(angle);

      // Determine if chord is highlighted.
      final isHighlighted = currentKey.getChordColor(chord) != null;
      final isLastPlayed = chord == lastPlayedChord;

      // Use flats for notes on the left side of the circle.
      final useFlats = note.prefersFlats;
      final label = chord.displayName(useFlats: useFlats);

      final textPainter = TextPainter(textDirection: TextDirection.ltr);

      if (isLastPlayed) {
        // Draw black outline
        textPainter.text = TextSpan(
          text: label,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2
              ..color = Colors.black,
          ),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(x - textPainter.width / 2, y - textPainter.height / 2),
        );

        // Draw white fill
        textPainter.text = TextSpan(
          text: label,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: centerForegroundColor,
          ),
        );
      } else {
        textPainter.text = TextSpan(
          text: label,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
            color: isHighlighted ? Colors.black87 : mutedLabelColor,
          ),
        );
      }

      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CircleOfFifthsPainter oldDelegate) {
    return oldDelegate.currentKey != currentKey ||
        oldDelegate.lastPlayedChord != lastPlayedChord ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.centerColor != centerColor ||
        oldDelegate.centerForegroundColor != centerForegroundColor ||
        oldDelegate.mutedLabelColor != mutedLabelColor ||
        !listEquals(oldDelegate.ringColors, ringColors);
  }
}

/// Helper class for hit testing on the circle of fifths.
class CircleOfFifthsHitTester {
  CircleOfFifthsHitTester(this.size);

  final Size size;

  /// Ring configuration matching the painter.
  static const List<List<double>> ringRadii = CircleOfFifthsPainter.ringRadii;

  /// Tests which chord (if any) was hit at the given position.
  /// Returns the chord and its ring index, or null if no chord was hit.
  ({Chord chord, int ringIndex})? hitTest(Offset position) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.min(size.width, size.height) / 2;

    // Calculate distance from center.
    final dx = position.dx - center.dx;
    final dy = position.dy - center.dy;
    final distance = math.sqrt(dx * dx + dy * dy);
    final normalizedDistance = distance / maxRadius;

    // Determine which ring was hit.
    int? ringIndex;
    for (var i = 0; i < ringRadii.length; i++) {
      if (normalizedDistance >= ringRadii[i][0] &&
          normalizedDistance <= ringRadii[i][1]) {
        ringIndex = i;
        break;
      }
    }

    if (ringIndex == null) return null;

    // Calculate angle from center.
    var angle = math.atan2(dy, dx);
    // Adjust so C is at top (270° or -π/2).
    angle = angle + math.pi / 2;
    if (angle < 0) angle += 2 * math.pi;

    // Determine segment index.
    const segmentAngle = 2 * math.pi / 12;
    // Offset by half a segment so boundaries are between notes.
    var segmentIndex = ((angle + segmentAngle / 2) / segmentAngle).floor();
    segmentIndex = segmentIndex % 12;

    // Get the note and chord.
    final offsetIndex =
        (segmentIndex + CircleOfFifthsPainter.ringOffsets[ringIndex]) % 12;
    final note = Note.circleOfFifths[offsetIndex];
    final quality = switch (ringIndex) {
      0 => ChordQuality.major,
      1 => ChordQuality.minor,
      2 => ChordQuality.diminished,
      _ => ChordQuality.major,
    };

    return (chord: Chord(note, quality), ringIndex: ringIndex);
  }
}
