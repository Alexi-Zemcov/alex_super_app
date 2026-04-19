import 'package:equatable/equatable.dart';
import 'package:my_instruments/my_instruments.dart';

enum SaveInstrumentAction { create, update, clone }

class SaveInstrumentSubmission extends Equatable {
  const SaveInstrumentSubmission({
    required this.action,
    required this.name,
    required this.kind,
  });

  final SaveInstrumentAction action;
  final String name;
  final SavedInstrumentKind kind;

  @override
  List<Object?> get props => [action, name, kind];
}
