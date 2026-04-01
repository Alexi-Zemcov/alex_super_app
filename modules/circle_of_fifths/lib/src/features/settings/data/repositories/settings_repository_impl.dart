import 'package:circle_of_fifths/src/features/settings/data/datasources/settings_datasource.dart';
import 'package:circle_of_fifths/src/features/settings/domain/domain.dart';

/// Implementation of SettingsRepository.
///
/// Uses SettingsDatasource to interact with persistent storage.
class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsDatasource _datasource;

  SettingsRepositoryImpl(this._datasource);

  @override
  Future<Settings?> loadSettings() {
    return _datasource.loadSettings();
  }

  @override
  Future<bool> saveSettings(Settings settings) {
    return _datasource.saveSettings(settings);
  }
}
