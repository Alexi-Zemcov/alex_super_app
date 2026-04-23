import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_midi_pro/flutter_midi_pro.dart';
import 'package:midi_playback/src/midi_playback_assets.dart';
import 'package:midi_playback/src/midi_playback_service.dart';
import 'package:music_theory/music_theory.dart';

class FlutterMidiPlaybackService implements MidiPlaybackService {
  FlutterMidiPlaybackService({
    this.soundfontPath = MidiPlaybackPackageAssets.soundfont,
  }) : _availability = _computeAvailability();

  final MidiPro _midiPro = MidiPro();
  final String soundfontPath;

  bool _isInitialized = false;
  bool _isMuted = false;
  int _sfId = 1;
  double _masterVolume = 0.7;
  PlaybackAvailability _availability;

  static const int _channel = 0;
  static const int _baseVelocity = 127;

  @override
  PlaybackAvailability get availability => _availability;

  @override
  bool get isMuted => _isMuted;

  @override
  double get masterVolume => _masterVolume;

  @override
  Future<void> initialize() async {
    if (_isInitialized || !_availability.isSupported) {
      return;
    }

    try {
      _sfId = await _midiPro.loadSoundfontAsset(
        assetPath: soundfontPath,
        bank: 0,
        program: 0,
      );
      _isInitialized = true;
    } on MissingPluginException {
      _availability = PlaybackAvailability.unsupported;
      _isInitialized = false;
    } catch (_) {
      _availability = PlaybackAvailability.unsupported;
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
  Future<void> playNote(ScientificNote note) async {
    if (_isMuted || !_isInitialized) {
      return;
    }

    await _playMidi(note.midi);
  }

  @override
  void stopNote(ScientificNote note) {
    if (!_isInitialized) {
      return;
    }

    unawaited(_stopMidi(note.midi));
  }

  @override
  Future<void> playChord(Chord chord, {int octave = 4}) async {
    if (_isMuted || !_isInitialized) {
      return;
    }

    for (final midiNote in chord.midiNotes(octave)) {
      unawaited(_playMidi(midiNote));
    }
  }

  @override
  void stopChord(Chord chord, {int octave = 4}) {
    if (!_isInitialized) {
      return;
    }

    for (final midiNote in chord.midiNotes(octave)) {
      unawaited(_stopMidi(midiNote));
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
    try {
      await _midiPro.dispose();
    } on MissingPluginException {
      _availability = PlaybackAvailability.unsupported;
    }
    _isInitialized = false;
  }

  Future<void> _playMidi(int midiNote) async {
    final velocity = (_baseVelocity * _masterVolume).round().clamp(0, 127);
    await _midiPro.playNote(
      channel: _channel,
      key: midiNote,
      velocity: velocity,
      sfId: _sfId,
    );
  }

  Future<void> _stopMidi(int midiNote) async {
    await _midiPro.stopNote(channel: _channel, key: midiNote, sfId: _sfId);
  }

  static PlaybackAvailability _computeAvailability() {
    if (kIsWeb) {
      return PlaybackAvailability.unsupported;
    }

    return switch (defaultTargetPlatform) {
      TargetPlatform.android ||
      TargetPlatform.iOS => PlaybackAvailability.supported,
      _ => PlaybackAvailability.unsupported,
    };
  }
}
