import 'package:app_theme/app_theme.dart';
import 'package:circle_of_fifths/src/features/circle/domain/domain.dart';
import 'package:circle_of_fifths/src/features/circle/presentation/screens/circle/bloc/circle_bloc.dart';
import 'package:circle_of_fifths/src/features/circle/presentation/screens/circle/bloc/circle_event.dart';
import 'package:circle_of_fifths/src/features/circle/presentation/screens/circle/bloc/circle_state.dart';
import 'package:circle_of_fifths/src/features/circle/presentation/widgets/circle_of_fifths_widget.dart';
import 'package:circle_of_fifths/src/features/circle/presentation/widgets/degree_table_widget.dart';
import 'package:circle_of_fifths/src/features/settings/settings.dart';
import 'package:circle_of_fifths/src/navigation/circle_of_fifths_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Main screen of the Circle of Fifths app.
///
/// Contains the app bar with controls, the circle visualization,
/// and the degree table.
class CircleScreen extends StatelessWidget {
  const CircleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.quizColors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(
          'Circle of Fifths',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: colors.textStrong,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          BlocBuilder<CircleBloc, CircleState>(
            buildWhen: (prev, next) =>
                (prev is CircleStateReady ? prev.hasSustain : null) !=
                (next is CircleStateReady ? next.hasSustain : null),
            builder: (context, state) {
              final hasSustain = switch (state) {
                CircleStateReady(:final hasSustain) => hasSustain,
                _ => false,
              };

              return IconButton(
                icon: Icon(
                  hasSustain ? Icons.radio_button_on : Icons.radio_button_off,
                  color: colors.textStrong,
                ),
                onPressed: () =>
                    context.read<CircleBloc>().add(const ToggleSustain()),
                tooltip: hasSustain ? 'Sustain: On' : 'Sustain: Off',
              );
            },
          ),

          // Lock button.
          BlocBuilder<CircleBloc, CircleState>(
            buildWhen: (prev, next) =>
                (prev is CircleStateReady ? prev.isLocked : null) !=
                (next is CircleStateReady ? next.isLocked : null),
            builder: (context, state) {
              final isLocked = switch (state) {
                CircleStateReady(:final isLocked) => isLocked,
                _ => false,
              };

              return IconButton(
                icon: Icon(
                  isLocked ? Icons.lock : Icons.lock_open,
                  color: colors.textStrong,
                ),
                onPressed: () =>
                    context.read<CircleBloc>().add(const ToggleCircleLock()),
                tooltip: isLocked
                    ? 'Unlock key selection'
                    : 'Lock key selection',
              );
            },
          ),
          BlocBuilder<SettingsBloc, SettingsState>(
            buildWhen: (prev, next) =>
                (prev is SettingsStateLoaded ? prev.isMuted : null) !=
                (next is SettingsStateLoaded ? next.isMuted : null),
            builder: (context, state) {
              final isMuted = switch (state) {
                SettingsStateLoaded(:final isMuted) => isMuted,
                _ => false,
              };

              return IconButton(
                icon: Icon(
                  isMuted ? Icons.volume_off : Icons.volume_up,
                  color: colors.textStrong,
                ),
                onPressed: () => context.read<SettingsBloc>().add(
                  const ToggleSettingsMute(),
                ),
                tooltip: isMuted ? 'Unmute' : 'Mute',
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.more_vert, color: colors.textStrong),
            onPressed: () async {
              await const CircleSettingsRoute().push<void>(context);
            },
            tooltip: 'Settings',
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            BlocBuilder<CircleBloc, CircleState>(
              buildWhen: (prev, next) {
                if (prev is! CircleStateReady || next is! CircleStateReady) {
                  return true;
                }
                return prev.currentKey != next.currentKey ||
                    prev.isLocked != next.isLocked ||
                    prev.lastPlayedChord != next.lastPlayedChord;
              },
              builder: (context, homeState) {
                final currentKey = switch (homeState) {
                  CircleStateReady(:final currentKey) => currentKey,
                  _ => MusicKey.cMajor,
                };
                final isLocked = switch (homeState) {
                  CircleStateReady(:final isLocked) => isLocked,
                  _ => false,
                };
                final lastPlayedChord = switch (homeState) {
                  CircleStateReady(:final lastPlayedChord) => lastPlayedChord,
                  _ => null,
                };

                return Column(
                  children: [
                    CircleOfFifthsWidget(
                      onChordPressed: (chord) {
                        context.read<CircleBloc>().add(PlayChord(chord));
                      },
                      onChordUp: (chord) {
                        final state = context.read<CircleBloc>().state;
                        final hasSustain = switch (state) {
                          CircleStateReady(:final hasSustain) => hasSustain,
                          _ => false,
                        };
                        if (hasSustain) return;
                        context.read<CircleBloc>().add(StopChord(chord));
                      },
                      currentKey: currentKey,
                      isLocked: isLocked,
                      lastPlayedChord: lastPlayedChord,
                      onKeySelected: (newKey) {
                        context.read<CircleBloc>().add(SelectCircleKey(newKey));
                      },
                    ),
                    DegreeTableWidget(
                      currentKey: currentKey,
                      lastPlayedChord: lastPlayedChord,
                      onChordPressed: (chord) {
                        context.read<CircleBloc>().add(PlayChord(chord));
                      },
                      onChordUp: (chord) {
                        final state = context.read<CircleBloc>().state;
                        final hasSustain = switch (state) {
                          CircleStateReady(:final hasSustain) => hasSustain,
                          _ => false,
                        };
                        if (hasSustain) {
                          return;
                        }
                        context.read<CircleBloc>().add(StopChord(chord));
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
