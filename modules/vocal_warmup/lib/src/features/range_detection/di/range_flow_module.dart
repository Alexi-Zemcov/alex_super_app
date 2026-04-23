import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:scoped_di/scoped_di.dart';
import 'package:vocal_warmup/src/features/range_detection/domain/repositories/vocal_range_repository.dart';
import 'package:vocal_warmup/src/features/range_detection/domain/services/pitch_detection_service.dart';
import 'package:vocal_warmup/src/features/range_detection/domain/services/voice_classifier.dart';
import 'package:vocal_warmup/src/features/range_detection/domain/usecases/classify_voice_use_case.dart';
import 'package:vocal_warmup/src/features/range_detection/domain/usecases/detect_stable_note_use_case.dart';
import 'package:vocal_warmup/src/features/range_detection/domain/usecases/load_vocal_range_use_case.dart';
import 'package:vocal_warmup/src/features/range_detection/domain/usecases/save_vocal_range_use_case.dart';
import 'package:vocal_warmup/src/features/range_detection/presentation/screens/range_flow/bloc/range_flow_bloc.dart';
import 'package:vocal_warmup/src/features/range_detection/presentation/screens/range_flow/bloc/range_flow_event.dart';

class RangeFlowModule extends ScopeModule {
  const RangeFlowModule();

  @override
  List<SingleChildWidget> get providers => [
    Provider<LoadVocalRangeUseCase>(
      create: (context) =>
          LoadVocalRangeUseCase(context.read<VocalRangeRepository>()),
    ),
    Provider<SaveVocalRangeUseCase>(
      create: (context) =>
          SaveVocalRangeUseCase(context.read<VocalRangeRepository>()),
    ),
    Provider<DetectStableNoteUseCase>(
      create: (context) =>
          DetectStableNoteUseCase(context.read<PitchDetectionService>()),
    ),
    Provider<ClassifyVoiceUseCase>(
      create: (context) =>
          ClassifyVoiceUseCase(context.read<VoiceClassifier>()),
    ),
    BlocProvider<RangeFlowBloc>(
      create: (context) => RangeFlowBloc(
        loadRange: context.read<LoadVocalRangeUseCase>(),
        saveRange: context.read<SaveVocalRangeUseCase>(),
        detectStableNote: context.read<DetectStableNoteUseCase>(),
        classifyVoice: context.read<ClassifyVoiceUseCase>(),
      )..add(const RangeFlowStarted()),
    ),
  ];
}
