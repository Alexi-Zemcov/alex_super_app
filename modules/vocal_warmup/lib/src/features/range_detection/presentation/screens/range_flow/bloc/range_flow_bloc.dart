import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocal_warmup/src/features/range_detection/domain/entities/range_detection_target.dart';
import 'package:vocal_warmup/src/features/range_detection/domain/entities/vocal_range.dart';
import 'package:vocal_warmup/src/features/range_detection/domain/usecases/classify_voice_use_case.dart';
import 'package:vocal_warmup/src/features/range_detection/domain/usecases/detect_stable_note_use_case.dart';
import 'package:vocal_warmup/src/features/range_detection/domain/usecases/load_vocal_range_use_case.dart';
import 'package:vocal_warmup/src/features/range_detection/domain/usecases/save_vocal_range_use_case.dart';
import 'package:vocal_warmup/src/features/range_detection/presentation/screens/range_flow/bloc/range_flow_event.dart';
import 'package:vocal_warmup/src/features/range_detection/presentation/screens/range_flow/bloc/range_flow_state.dart';

class RangeFlowBloc extends Bloc<RangeFlowEvent, RangeFlowState> {
  RangeFlowBloc({
    required LoadVocalRangeUseCase loadRange,
    required SaveVocalRangeUseCase saveRange,
    required DetectStableNoteUseCase detectStableNote,
    required ClassifyVoiceUseCase classifyVoice,
  }) : _loadRange = loadRange,
       _saveRange = saveRange,
       _detectStableNote = detectStableNote,
       _classifyVoice = classifyVoice,
       super(const RangeFlowInitial()) {
    on<RangeFlowStarted>(_onStarted);
    on<RangeFlowRestarted>(_onRestarted);
    on<RangeFlowContinuePressed>(_onContinuePressed);
  }

  final LoadVocalRangeUseCase _loadRange;
  final SaveVocalRangeUseCase _saveRange;
  final DetectStableNoteUseCase _detectStableNote;
  final ClassifyVoiceUseCase _classifyVoice;

  Future<void> _onStarted(
    RangeFlowStarted event,
    Emitter<RangeFlowState> emit,
  ) async {
    emit(const RangeFlowLoading());

    try {
      final storedRange = await _loadRange();
      if (storedRange != null) {
        emit(RangeFlowExerciseSelection(range: storedRange));
        return;
      }

      await _detectRange(emit);
    } catch (_) {
      emit(const RangeFlowFailure('Не удалось начать определение диапазона.'));
    }
  }

  Future<void> _onRestarted(
    RangeFlowRestarted event,
    Emitter<RangeFlowState> emit,
  ) async {
    try {
      await _detectRange(emit);
    } catch (_) {
      emit(const RangeFlowFailure('Не удалось определить диапазон заново.'));
    }
  }

  void _onContinuePressed(
    RangeFlowContinuePressed event,
    Emitter<RangeFlowState> emit,
  ) {
    final currentState = state;
    if (currentState is! RangeFlowResult) {
      return;
    }

    emit(RangeFlowExerciseSelection(range: currentState.range));
  }

  Future<void> _detectRange(Emitter<RangeFlowState> emit) async {
    emit(const RangeFlowListening(target: RangeDetectionTarget.lowest));
    final lowestNote = await _detectStableNote(RangeDetectionTarget.lowest);

    emit(
      RangeFlowListening(
        target: RangeDetectionTarget.highest,
        lowestNote: lowestNote,
      ),
    );
    final highestNote = await _detectStableNote(RangeDetectionTarget.highest);

    if (highestNote.midi <= lowestNote.midi) {
      emit(
        const RangeFlowFailure(
          'Верхняя нота должна быть выше нижней. Попробуйте ещё раз.',
        ),
      );
      return;
    }

    final range = VocalRange(
      lowestNote: lowestNote,
      highestNote: highestNote,
      detectedAt: DateTime.now(),
    );
    await _saveRange(range);

    emit(RangeFlowResult(range: range, voiceType: _classifyVoice(range)));
  }
}
