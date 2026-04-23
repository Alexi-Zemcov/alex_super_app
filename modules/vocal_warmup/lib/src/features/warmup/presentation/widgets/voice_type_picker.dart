import 'package:app_theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:vocal_warmup/src/features/warmup/domain/entities/voice_type.dart';

Future<void> showVoiceTypeSelectionDialog(
  BuildContext context, {
  required VoiceType? selectedVoice,
  required ValueChanged<VoiceType> onSelected,
}) {
  final colors = context.quizColors;

  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        backgroundColor: colors.card,
        title: Text(
          'Выберите тип голоса',
          style: TextStyle(color: colors.textStrong),
        ),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: _VoiceTypePickerList(
            selectedVoice: selectedVoice,
            onSelected: (voiceType) {
              onSelected(voiceType);
              Navigator.of(context).pop();
            },
          ),
        ),
      );
    },
  );
}

Future<void> showVoiceTypeSelectionSheet(
  BuildContext context, {
  required VoiceType? selectedVoice,
  required ValueChanged<VoiceType> onSelected,
}) {
  final colors = context.quizColors;

  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: colors.card,
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Тип голоса',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: colors.textStrong,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              _VoiceTypePickerList(
                selectedVoice: selectedVoice,
                onSelected: (voiceType) {
                  onSelected(voiceType);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _VoiceTypePickerList extends StatelessWidget {
  const _VoiceTypePickerList({
    required this.selectedVoice,
    required this.onSelected,
  });

  final VoiceType? selectedVoice;
  final ValueChanged<VoiceType> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.quizColors;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final voiceType in VoiceType.values)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              voiceType.displayName,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: colors.textStrong),
            ),
            subtitle: Text(
              '${voiceType.startNote.label()} · ${voiceType.minNote.label()} — ${voiceType.maxNote.label()}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: colors.textSoft),
            ),
            trailing: selectedVoice == voiceType
                ? Icon(Icons.check_circle, color: colors.accentBlue)
                : null,
            onTap: () => onSelected(voiceType),
          ),
      ],
    );
  }
}
