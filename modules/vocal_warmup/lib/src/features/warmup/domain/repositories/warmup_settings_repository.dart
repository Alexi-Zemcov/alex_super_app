import 'package:vocal_warmup/src/features/warmup/domain/entities/warmup_settings.dart';

abstract interface class WarmupSettingsRepository {
  Future<WarmupSettings?> loadSettings();

  Future<bool> saveSettings(WarmupSettings settings);
}
