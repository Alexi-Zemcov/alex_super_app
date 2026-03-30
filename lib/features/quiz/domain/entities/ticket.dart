import 'package:alex_super_app/features/quiz/domain/entities/quiz_question.dart';
import 'package:equatable/equatable.dart';

class Ticket extends Equatable {
  const Ticket({required this.id, required this.questions});

  final int id;
  final List<QuizQuestion> questions;

  @override
  List<Object?> get props => [id, questions];
}
