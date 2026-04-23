import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:midi_playback/midi_playback.dart';
import 'package:music_theory/music_theory.dart';
import 'package:vocal_warmup/src/features/range_detection/domain/entities/vocal_range.dart';
import 'package:vocal_warmup/src/features/range_detection/domain/services/note_preview_service.dart';

class MidiNotePreviewService implements NotePreviewService {
  MidiNotePreviewService(this._midiPlaybackService);

  final MidiPlaybackService _midiPlaybackService;

  bool _isInitialized = false;
  int _playbackSessionId = 0;

  static const _singlePreviewDuration = Duration(milliseconds: 950);
  static const _rangePreviewPause = Duration(milliseconds: 260);

  @override
  Future<void> previewNote(ScientificNote note) async {
    final sessionId = ++_playbackSessionId;
    _log('previewNote note=${note.label()}');

    if (!await _ensureInitialized()) {
      return;
    }

    await _midiPlaybackService.stopAll();
    await _midiPlaybackService.playNote(note);
    await Future<void>.delayed(_singlePreviewDuration);
    if (sessionId != _playbackSessionId) {
      return;
    }
    _midiPlaybackService.stopNote(note);
  }

  @override
  Future<void> previewRange(VocalRange range) async {
    final sessionId = ++_playbackSessionId;
    _log(
      'previewRange range=${range.lowestNote.label()}-${range.highestNote.label()}',
    );

    if (!await _ensureInitialized()) {
      return;
    }

    await _midiPlaybackService.stopAll();
    for (final note in [range.lowestNote, range.highestNote]) {
      if (sessionId != _playbackSessionId) {
        return;
      }
      await _midiPlaybackService.playNote(note);
      await Future<void>.delayed(_singlePreviewDuration);
      if (sessionId != _playbackSessionId) {
        return;
      }
      _midiPlaybackService.stopNote(note);
      await Future<void>.delayed(_rangePreviewPause);
    }
  }

  @override
  Future<void> stop() async {
    _playbackSessionId += 1;
    _log('stop');
    if (!_isInitialized) {
      return;
    }
    await _midiPlaybackService.stopAll();
  }

  @override
  Future<void> dispose() async {
    _playbackSessionId += 1;
    _log('dispose');
    await _midiPlaybackService.dispose();
    _isInitialized = false;
  }

  Future<bool> _ensureInitialized() async {
    if (!_midiPlaybackService.availability.isSupported) {
      _log('playback unsupported');
      return false;
    }

    if (_isInitialized) {
      return true;
    }

    try {
      await _midiPlaybackService.initialize();
      _isInitialized = _midiPlaybackService.availability.isSupported;
      _log('initialize completed supported=$_isInitialized');
      return _isInitialized;
    } catch (error) {
      _log('initialize failed error=$error');
      return false;
    }
  }

  void _log(String message) {
    debugPrint('[VocalWarmup][NotePreviewService] $message');
  }
}
