import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:pitch_detection/pitch_detection.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _status = 'Ожидание разрешения';
  final _pitchDetectionClient = PitchDetectionClient();
  StreamSubscription<PitchFrame>? _subscription;
  PitchFrame? _lastFrame;

  @override
  void initState() {
    super.initState();
    _startDetection();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _pitchDetectionClient.stop();
    super.dispose();
  }

  Future<void> _startDetection() async {
    try {
      final permission = await _pitchDetectionClient
          .requestMicrophonePermission();
      if (!permission.isGranted) {
        setState(() {
          _status = 'Доступ к микрофону не выдан';
        });
        return;
      }

      _subscription = _pitchDetectionClient.frames().listen(
        (frame) {
          if (!mounted) {
            return;
          }
          setState(() {
            _lastFrame = frame;
            _status = frame.isPitched ? 'Слышу голос' : 'Жду устойчивую ноту';
          });
        },
        onError: (Object error) {
          if (!mounted) {
            return;
          }
          setState(() {
            _status = error.toString();
          });
        },
      );
    } catch (error) {
      setState(() {
        _status = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final frame = _lastFrame;
    final note = frame == null || frame.frequencyHz <= 0
        ? '...'
        : _formatNote(frame.frequencyHz);

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Pitch Detection Example')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_status),
              const SizedBox(height: 12),
              Text('Нота: $note'),
              if (frame != null) ...[
                const SizedBox(height: 8),
                Text('Частота: ${frame.frequencyHz.toStringAsFixed(1)} Гц'),
                Text('Амплитуда: ${frame.amplitude.toStringAsFixed(3)}'),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatNote(double frequencyHz) {
    final midi = (69 + 12 * (math.log(frequencyHz / 440) / math.ln2)).round();
    const labels = <String>[
      'C',
      'C#',
      'D',
      'D#',
      'E',
      'F',
      'F#',
      'G',
      'G#',
      'A',
      'A#',
      'B',
    ];
    final octave = (midi ~/ 12) - 1;
    return '${labels[midi % 12]}$octave';
  }
}
