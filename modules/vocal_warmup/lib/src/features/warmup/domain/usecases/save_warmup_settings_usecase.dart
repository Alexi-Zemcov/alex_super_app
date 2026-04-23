import 'package:vocal_warmup/src/features/warmup/domain/entities/warmup_settings.dart';
import 'package:vocal_warmup/src/features/warmup/domain/repositories/warmup_settings_repository.dart';

class SaveWarmupSettingsUseCase {
  const SaveWarmupSettingsUseCase(this._repository);

  final WarmupSettingsRepository _repository;

  Future<bool> call(WarmupSettings settings) =>
      _repository.saveSettings(settings);
}
