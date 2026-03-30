import '../../domain/entities/theme_preference.dart';
import '../../domain/repositories/theme_repository.dart';
import '../datasources/theme_local_data_source.dart';

class ThemeRepositoryImpl implements ThemeRepository {
  ThemeRepositoryImpl({required ThemeLocalDataSource localDataSource})
    : _localDataSource = localDataSource;

  final ThemeLocalDataSource _localDataSource;

  @override
  Future<ThemePreference> loadTheme() {
    return _localDataSource.loadTheme();
  }

  @override
  Future<void> saveTheme(ThemePreference theme) {
    return _localDataSource.saveTheme(theme);
  }
}
