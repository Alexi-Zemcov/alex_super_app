import 'package:app_theme/app_theme.dart';
import 'package:circle_of_fifths/src/features/settings/presentation/widgets/widgets.dart';
import 'package:circle_of_fifths/src/features/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Settings screen for the Circle of Fifths app.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.quizColors;
    final themeController = context.watch<AppThemeController>();

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: colors.textStrong,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: IconThemeData(color: colors.textStrong),
      ),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        buildWhen: (prev, next) {
          if (prev is! SettingsStateLoaded || next is! SettingsStateLoaded) {
            return true;
          }
          return prev.settings != next.settings;
        },
        builder: (context, state) {
          return switch (state) {
            SettingsStateInitial() || SettingsStateLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
            SettingsStateLoaded(:final settings) => ListView(
              padding: const EdgeInsets.all(16),
              children: [
                SettingSection(
                  title: 'Appearance',
                  children: [
                    ListTile(
                      title: Text(
                        'App Theme',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: colors.textStrong,
                        ),
                      ),
                      subtitle: Text(
                        'Uses the shared theme controller from the host app',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colors.textSoft,
                        ),
                      ),
                      trailing: TextButton(
                        onPressed: themeController.cycleTheme,
                        child: Text(
                          themeController.themePreference.icon,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SettingSection(
                  title: 'Audio',
                  children: [_buildVolumeSlider(context, settings)],
                ),
                const SizedBox(height: 16),
                SettingSection(
                  title: 'Display',
                  children: [
                    ListTile(
                      title: Text(
                        'Notation Preference',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: colors.textStrong,
                        ),
                      ),
                      subtitle: Text(
                        'Choose how to display accidentals',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colors.textSoft,
                        ),
                      ),
                      trailing: DropdownButton<NotationPreference>(
                        value: settings.notationPreference,
                        dropdownColor: colors.card,
                        style: TextStyle(
                          color: colors.textStrong,
                          fontSize: 14,
                        ),
                        underline: Container(),
                        items: NotationPreference.values.map((preference) {
                          return DropdownMenuItem(
                            value: preference,
                            child: Text(preference.displayName),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            context.read<SettingsBloc>().add(
                              ChangeSettingsNotation(value),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const SettingSection(
                  title: 'About',
                  children: [
                    AboutItem(
                      icon: Icons.info_outline,
                      title: 'Version',
                      subtitle: '1.0.0',
                    ),
                    Divider(height: 1, color: Colors.white12),
                    AboutItem(
                      icon: Icons.music_note,
                      title: 'Circle of Fifths',
                      subtitle: 'Interactive chord synthesizer',
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: OutlinedButton(
                    onPressed: () async {
                      await showDialog(
                        context: context,
                        builder: (dialogContext) => AlertDialog(
                          backgroundColor: colors.card,
                          title: Text(
                            'Reset Settings',
                            style: TextStyle(color: colors.textStrong),
                          ),
                          content: Text(
                            'Are you sure you want to reset all settings to their default values?',
                            style: TextStyle(color: colors.textSoft),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(),
                              child: Text(
                                'Cancel',
                                style: TextStyle(color: colors.textSoft),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                context.read<SettingsBloc>().add(
                                  const ResetSettings(),
                                );
                                Navigator.of(dialogContext).pop();
                              },
                              child: Text(
                                'Reset',
                                style: TextStyle(color: colors.accentRed),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.accentRed,
                      side: BorderSide(color: colors.accentRed),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Reset to Defaults'),
                  ),
                ),
              ],
            ),
          };
        },
      ),
    );
  }

  Widget _buildVolumeSlider(BuildContext context, Settings settings) {
    final colors = context.quizColors;
    final volumePercent = (settings.masterVolume * 100).round();

    return Column(
      children: [
        ListTile(
          title: Text(
            'Master Volume',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: colors.textStrong),
          ),
          trailing: Text(
            '$volumePercent%',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: colors.textSoft,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(Icons.volume_down, color: colors.textMuted, size: 20),
              Expanded(
                child: Slider(
                  value: settings.masterVolume,
                  onChanged: (value) {
                    context.read<SettingsBloc>().add(
                      ChangeSettingsVolume(value),
                    );
                  },
                  activeColor: colors.accentBlue,
                  inactiveColor: colors.border.withValues(alpha: 0.35),
                ),
              ),
              Icon(Icons.volume_up, color: colors.textMuted, size: 20),
            ],
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
