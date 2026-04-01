import 'dart:async';

import 'package:circle_of_fifths/src/core/audio/audio_playback_service.dart';
import 'package:circle_of_fifths/src/features/circle/domain/entities/chord.dart';
import 'package:flutter/services.dart';
import 'package:flutter_midi_pro/flutter_midi_pro.dart';

class FlutterMidiAudioPlaybackService implements AudioPlaybackService {
  FlutterMidiAudioPlaybackService();

  final MidiPro _midiPro = MidiPro();

  bool _isInitialized = false;
  bool _isMuted = false;
  int _sfId = 1;
  double _masterVolume = 0.7;

  static const int _channel = 0;
  static const int _baseVelocity = 127;
  static const int _octave = 4;
  static const String _soundfontPath =
      'packages/circle_of_fifths/assets/sf2/soundfont.sf2';

  @override
  bool get isMuted => _isMuted;

  @override
  double get masterVolume => _masterVolume;

  @override
  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    try {
      _sfId = await _midiPro.loadSoundfontAsset(
        assetPath: _soundfontPath,
        bank: 0,
        program: 0,
      );
      _isInitialized = true;
    } on MissingPluginException {
      _isInitialized = false;
    } catch (_) {
      _isInitialized = false;
    }
  }

  @override
  void setMutedAndStopAll(bool value) {
    _isMuted = value;
    if (_isMuted) {
      unawaited(stopAll());
    }
  }

  @override
  void setMasterVolume(double volume) {
    _masterVolume = volume.clamp(0.0, 1.0);
  }

  @override
  Future<void> playChord(Chord chord) async {
    if (_isMuted || !_isInitialized) {
      return;
    }

    final midiNotes = chord.midiNotes(_octave);
    for (final note in midiNotes) {
      unawaited(_playNote(note));
    }
  }

  @override
  void stopChord(Chord chord) {
    if (!_isInitialized) {
      return;
    }

    final midiNotes = chord.midiNotes(_octave);
    for (final note in midiNotes) {
      unawaited(_stopNote(note));
    }
  }

  @override
  Future<void> stopAll() async {
    if (!_isInitialized) {
      return;
    }

    await _midiPro.stopAllNotes(sfId: _sfId);
  }

  @override
  Future<void> dispose() async {
    await stopAll();
    await _midiPro.dispose();
    _isInitialized = false;
  }

  Future<void> _playNote(int midiNote) async {
    final velocity = (_baseVelocity * _masterVolume).round().clamp(0, 127);
    await _midiPro.playNote(
      channel: _channel,
      key: midiNote,
      velocity: velocity,
      sfId: _sfId,
    );
  }

  Future<void> _stopNote(int midiNote) async {
    await _midiPro.stopNote(channel: _channel, key: midiNote, sfId: _sfId);
  }
}
