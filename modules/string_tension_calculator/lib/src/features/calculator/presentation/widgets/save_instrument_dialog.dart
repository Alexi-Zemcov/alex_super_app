import 'package:flutter/material.dart';
import 'package:my_instruments/my_instruments.dart';
import 'package:string_tension_calculator/src/features/calculator/presentation/screens/calculator/models/save_instrument_submission.dart';

class SaveInstrumentDialog extends StatefulWidget {
  const SaveInstrumentDialog({
    required this.initialName,
    required this.initialKind,
    required this.isEditingExisting,
    super.key,
  });

  final String initialName;
  final SavedInstrumentKind initialKind;
  final bool isEditingExisting;

  @override
  State<SaveInstrumentDialog> createState() => _SaveInstrumentDialogState();
}

class _SaveInstrumentDialogState extends State<SaveInstrumentDialog> {
  late final TextEditingController _nameController;
  late SavedInstrumentKind _selectedKind;

  bool get _canSubmit => _nameController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _selectedKind = widget.initialKind;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Сохранить в мои гитары'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              key: const Key('save-instrument-name-field'),
              controller: _nameController,
              autofocus: true,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'Название',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Тип инструмента',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            SegmentedButton<SavedInstrumentKind>(
              key: const Key('save-instrument-kind-switch'),
              showSelectedIcon: false,
              segments: const [
                ButtonSegment<SavedInstrumentKind>(
                  value: SavedInstrumentKind.guitar,
                  label: Text('Гитара'),
                ),
                ButtonSegment<SavedInstrumentKind>(
                  value: SavedInstrumentKind.bass,
                  label: Text('Бас'),
                ),
              ],
              selected: {_selectedKind},
              onSelectionChanged: (selection) {
                setState(() {
                  _selectedKind = selection.single;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          key: const Key('save-instrument-cancel-button'),
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        if (widget.isEditingExisting)
          TextButton(
            key: const Key('save-instrument-clone-button'),
            onPressed: _canSubmit
                ? () => _submit(SaveInstrumentAction.clone)
                : null,
            child: const Text('Сохранить как новую'),
          ),
        FilledButton(
          key: Key(
            widget.isEditingExisting
                ? 'save-instrument-update-button'
                : 'save-instrument-create-button',
          ),
          onPressed: _canSubmit
              ? () => _submit(
                  widget.isEditingExisting
                      ? SaveInstrumentAction.update
                      : SaveInstrumentAction.create,
                )
              : null,
          child: Text(widget.isEditingExisting ? 'Обновить' : 'Сохранить'),
        ),
      ],
    );
  }

  void _submit(SaveInstrumentAction action) {
    Navigator.of(context).pop(
      SaveInstrumentSubmission(
        action: action,
        name: _nameController.text.trim(),
        kind: _selectedKind,
      ),
    );
  }
}
