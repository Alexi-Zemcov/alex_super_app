import 'package:circle_of_fifths/src/core/domain/usecase.dart';
import 'package:circle_of_fifths/src/features/settings/domain/entities/settings.dart';
import 'package:circle_of_fifths/src/features/settings/domain/repositories/settings_repository.dart';

/// Use case for loading settings.
class LoadSettingsUseCase implements NoParamsAsyncUseCase<Settings?> {
  final SettingsRepository _repository;

  const LoadSettingsUseCase(this._repository);

  @override
  Future<Settings?> call() async {
    return _repository.loadSettings();
  }
}
