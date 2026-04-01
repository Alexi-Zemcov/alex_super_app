import 'package:circle_of_fifths/src/core/domain/usecase.dart';
import 'package:circle_of_fifths/src/features/settings/domain/entities/settings.dart';
import 'package:circle_of_fifths/src/features/settings/domain/repositories/settings_repository.dart';

/// Use case for saving settings.
class SaveSettingsUseCase implements AsyncUseCase<Settings, bool> {
  final SettingsRepository _repository;

  const SaveSettingsUseCase(this._repository);

  @override
  Future<bool> call(Settings params) async {
    return _repository.saveSettings(params);
  }
}
