import 'package:alex_super_app/features/theme/data/datasources/theme_local_data_source.dart';
import 'package:alex_super_app/features/theme/domain/entities/theme_preference.dart';
import 'package:alex_super_app/features/theme/domain/repositories/theme_repository.dart';

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
