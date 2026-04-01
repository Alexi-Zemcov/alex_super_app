import 'package:app_theme/app_theme.dart';
import 'package:circle_of_fifths/src/features/circle/domain/domain.dart';
import 'package:flutter/material.dart';

/// Widget displaying scale degrees for major and minor keys.
///
/// Shows two rows of colored circles with Roman numeral labels:
/// - Major: I, ii, iii, IV, V, vi, vii°
/// - Minor: i, ii°, III, iv, v, VI, VII
class DegreeTableWidget extends StatefulWidget {
  final MusicKey currentKey;
  final Chord? lastPlayedChord;
  final void Function(Chord chord) onChordPressed;
  final void Function(Chord chord)? onChordUp;

  const DegreeTableWidget({
    required this.currentKey,
    required this.onChordPressed,
    this.lastPlayedChord,
    super.key,
    this.onChordUp,
  });

  @override
  State<DegreeTableWidget> createState() => _DegreeTableWidgetState();
}

class _DegreeTableWidgetState extends State<DegreeTableWidget> {
  Chord? _activeChord;

  @override
  Widget build(BuildContext context) {
    final colors = context.quizColors;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Row(
              degrees: MusicKey.majorDegreeNames,
              currentKey: widget.currentKey,
              lastPlayedChord: widget.lastPlayedChord,
              isMajor: true,
              onChordPressed: _handleChordPressed,
              onChordUp: _handleChordUp,
            ),
            const SizedBox(height: 8),
            _Row(
              degrees: MusicKey.minorDegreeNames,
              currentKey: widget.currentKey,
              lastPlayedChord: widget.lastPlayedChord,
              isMajor: false,
              onChordPressed: _handleChordPressed,
              onChordUp: _handleChordUp,
            ),
          ],
        ),
      ),
    );
  }

  void _handleChordPressed(Chord chord) {
    setState(() {
      _activeChord = chord;
    });
    widget.onChordPressed(chord);
  }

  void _handleChordUp(Chord chord) {
    if (_activeChord != null && widget.onChordUp != null) {
      widget.onChordUp!(_activeChord!);
      setState(() {
        _activeChord = null;
      });
    } else {
      setState(() {
        _activeChord = null;
      });
    }
  }
}

class _Row extends StatelessWidget {
  final List<String> degrees;
  final MusicKey currentKey;
  final Chord? lastPlayedChord;
  final bool isMajor;
  final void Function(Chord chord) onChordPressed;
  final void Function(Chord chord)? onChordUp;

  const _Row({
    required this.degrees,
    required this.currentKey,
    required this.isMajor,
    required this.onChordPressed,
    this.lastPlayedChord,
    this.onChordUp,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.quizColors;
    final label = isMajor ? 'Major' : 'Minor';

    final keyForRow = isMajor
        ? (currentKey.isMajor ? currentKey : currentKey.parallelKey)
        : (currentKey.isMajor ? currentKey.parallelKey : currentKey);

    final chords = keyForRow.diatonicChords;

    return Row(
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: colors.textMuted),
        ),
        const SizedBox(width: 8),
        Row(
          children: List.generate(7, (index) {
            final chord = chords[index];
            final color =
                currentKey.getChordColor(chord) ?? MusicKey.degreeColors[index];
            return Padding(
              padding: EdgeInsets.only(left: index == 0 ? 0 : 2),
              child: _DegreeCircle(
                degree: degrees[index],
                color: color,
                chord: chord,
                isLastPlayed: chord == lastPlayedChord,
                onChordPressed: onChordPressed,
                onChordUp: onChordUp,
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _DegreeCircle extends StatelessWidget {
  const _DegreeCircle({
    required this.degree,
    required this.color,
    required this.chord,
    required this.onChordPressed,
    this.isLastPlayed = false,
    this.onChordUp,
  });

  final String degree;
  final Color color;
  final Chord chord;
  final bool isLastPlayed;
  final void Function(Chord chord) onChordPressed;
  final void Function(Chord chord)? onChordUp;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => onChordPressed(chord),
      onTapUp: (_) => onChordUp?.call(chord),
      onTapCancel: () => onChordUp?.call(chord),
      child: Material(
        color: color,
        shape: const CircleBorder(),
        child: SizedBox.square(
          dimension: 42,
          child: Center(
            child: isLastPlayed
                ? Stack(
                    children: [
                      Text(
                        degree,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          foreground: Paint()
                            ..style = PaintingStyle.stroke
                            ..strokeWidth = 2
                            ..color = Colors.black,
                        ),
                      ),
                      Text(
                        degree,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                : Text(
                    degree,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
