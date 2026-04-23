import 'package:vocal_warmup/src/features/warmup/domain/entities/warmup_settings.dart';
import 'package:vocal_warmup/src/features/warmup/domain/repositories/warmup_settings_repository.dart';

class LoadWarmupSettingsUseCase {
  const LoadWarmupSettingsUseCase(this._repository);

  final WarmupSettingsRepository _repository;

  Future<WarmupSettings?> call() => _repository.loadSettings();
}
