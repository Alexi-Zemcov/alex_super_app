import 'package:vocal_warmup/src/features/warmup/data/datasources/warmup_settings_datasource.dart';
import 'package:vocal_warmup/src/features/warmup/domain/entities/warmup_settings.dart';
import 'package:vocal_warmup/src/features/warmup/domain/repositories/warmup_settings_repository.dart';

class WarmupSettingsRepositoryImpl implements WarmupSettingsRepository {
  const WarmupSettingsRepositoryImpl(this._datasource);

  final WarmupSettingsDatasource _datasource;

  @override
  Future<WarmupSettings?> loadSettings() => _datasource.loadSettings();

  @override
  Future<bool> saveSettings(WarmupSettings settings) {
    return _datasource.saveSettings(settings);
  }
}
