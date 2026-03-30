import 'package:equatable/equatable.dart';

import 'quiz_question.dart';

class Topic extends Equatable {
  const Topic({required this.id, required this.name, required this.questions});

  final int id;
  final String name;
  final List<QuizQuestion> questions;

  @override
  List<Object?> get props => [id, name, questions];
}
