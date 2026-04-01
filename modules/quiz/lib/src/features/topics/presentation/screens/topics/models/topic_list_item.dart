import 'package:equatable/equatable.dart';

class TopicListItem extends Equatable {
  const TopicListItem({
    required this.id,
    required this.name,
    required this.questionCount,
    required this.isCompleted,
  });

  final int id;
  final String name;
  final int questionCount;
  final bool isCompleted;

  @override
  List<Object?> get props => [id, name, questionCount, isCompleted];
}
