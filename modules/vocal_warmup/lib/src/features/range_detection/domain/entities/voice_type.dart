import 'package:equatable/equatable.dart';

class VoiceType extends Equatable {
  const VoiceType({required this.title, required this.description});

  final String title;
  final String description;

  @override
  List<Object?> get props => [title, description];
}
