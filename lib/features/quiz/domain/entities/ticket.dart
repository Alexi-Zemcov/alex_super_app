import 'package:equatable/equatable.dart';

import 'quiz_question.dart';

class Ticket extends Equatable {
  const Ticket({required this.id, required this.questions});

  final int id;
  final List<QuizQuestion> questions;

  @override
  List<Object?> get props => [id, questions];
}
