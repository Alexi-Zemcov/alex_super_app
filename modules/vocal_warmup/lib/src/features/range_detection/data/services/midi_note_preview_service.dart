import 'dart:async';

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
    if (!_isInitialized) {
      return;
    }
    await _midiPlaybackService.stopAll();
  }

  @override
  Future<void> dispose() async {
    _playbackSessionId += 1;
    await _midiPlaybackService.dispose();
    _isInitialized = false;
  }

  Future<bool> _ensureInitialized() async {
    if (!_midiPlaybackService.availability.isSupported) {
      return false;
    }

    if (_isInitialized) {
      return true;
    }

    try {
      await _midiPlaybackService.initialize();
      _isInitialized = _midiPlaybackService.availability.isSupported;
      return _isInitialized;
    } catch (error) {
      return false;
    }
  }
}
