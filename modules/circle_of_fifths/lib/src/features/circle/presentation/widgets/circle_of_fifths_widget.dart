import 'package:app_theme/app_theme.dart';
import 'package:circle_of_fifths/src/features/circle/domain/domain.dart';
import 'package:circle_of_fifths/src/features/circle/presentation/widgets/circle_of_fifths_painter.dart';
import 'package:flutter/material.dart';

/// Interactive widget displaying the Circle of Fifths.
///
/// Handles tap interactions to play chords and select keys.
class CircleOfFifthsWidget extends StatefulWidget {
  final void Function(Chord chord) onChordPressed;
  final void Function(Chord chord)? onChordUp;
  final MusicKey currentKey;
  final bool isLocked;
  final void Function(MusicKey) onKeySelected;
  final Chord? lastPlayedChord;

  const CircleOfFifthsWidget({
    required this.onChordPressed,
    required this.currentKey,
    required this.isLocked,
    required this.onKeySelected,
    this.onChordUp,
    this.lastPlayedChord,
    super.key,
  });

  @override
  State<CircleOfFifthsWidget> createState() => _CircleOfFifthsWidgetState();
}

class _CircleOfFifthsWidgetState extends State<CircleOfFifthsWidget> {
  Chord? _activeChord;

  @override
  Widget build(BuildContext context) {
    final colors = context.quizColors;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Make the circle square and as large as possible.
        final size = constraints.maxWidth < constraints.maxHeight
            ? constraints.maxWidth
            : constraints.maxHeight;

        return Center(
          child: SizedBox(
            width: size,
            height: size,
            child: GestureDetector(
              onTapDown: (details) => _handleTapDown(details, Size(size, size)),
              onTapUp: _handleTapUp,
              onTapCancel: _handleTapCancel,
              child: CustomPaint(
                size: Size(size, size),
                painter: CircleOfFifthsPainter(
                  currentKey: widget.currentKey,
                  lastPlayedChord: widget.lastPlayedChord,
                  backgroundColor: colors.background,
                  ringColors: [colors.cardAlt, colors.card, colors.cardAlt.withValues(alpha: 0.88)],
                  centerColor: colors.background,
                  centerForegroundColor: colors.textStrong,
                  mutedLabelColor: colors.textStrong.withValues(alpha: 0.72),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleTapDown(TapDownDetails details, Size size) {
    final hitTester = CircleOfFifthsHitTester(size);
    final result = hitTester.hitTest(details.localPosition);

    if (result != null) {
      final chord = result.chord;
      _activeChord = chord;

      widget.onChordPressed(chord);

      // Select key if not locked.
      if (!widget.isLocked) {
        // Determine the key based on chord type.
        MusicKey newKey;
        if (chord.quality == ChordQuality.major) {
          newKey = MusicKey(chord.root, true);
        } else if (chord.quality == ChordQuality.minor) {
          // For minor chords, select the key where this is the tonic.
          newKey = MusicKey(chord.root, false);
        } else {
          // For diminished chords, find the relative major key.
          // Diminished chord is the vii° of a major key.
          // The root of the major key is one semitone above the diminished root.
          final majorRoot = chord.root.transpose(1);
          newKey = MusicKey(majorRoot, true);
        }
        widget.onKeySelected(newKey);
      }
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (_activeChord != null) {
      widget.onChordUp?.call(_activeChord!);
      _activeChord = null;
    }
  }

  void _handleTapCancel() {
    if (_activeChord != null) {
      widget.onChordUp?.call(_activeChord!);
      _activeChord = null;
    }
  }
}
