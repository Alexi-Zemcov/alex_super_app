import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../features/theme/domain/entities/theme_preference.dart';
import '../theme/app_theme_factory.dart';

final class AppState extends Equatable {
  const AppState({required this.themePreference});

  final ThemePreference themePreference;

  ThemeData get themeData => AppThemeFactory.fromPreference(themePreference);

  AppState copyWith({ThemePreference? themePreference}) {
    return AppState(themePreference: themePreference ?? this.themePreference);
  }

  @override
  List<Object?> get props => [themePreference];
}
