import 'package:alex_super_app/features/quiz/domain/entities/quiz_question.dart';
import 'package:alex_super_app/features/quiz/domain/entities/ticket.dart';
import 'package:alex_super_app/features/quiz/domain/entities/topic.dart';

class QuizCatalogBuilder {
  const QuizCatalogBuilder();

  static const ticketSize = 10;

  List<Ticket> buildTickets(List<QuizQuestion> questions) {
    final tickets = <Ticket>[];

    for (var index = 0; index < questions.length; index += ticketSize) {
      tickets.add(
        Ticket(
          id: tickets.length + 1,
          questions: [
            ...questions.sublist(
              index,
              index + ticketSize > questions.length
                  ? questions.length
                  : index + ticketSize,
            ),
          ],
        ),
      );
    }

    return List<Ticket>.unmodifiable(tickets);
  }

  List<Topic> buildTopics(List<QuizQuestion> questions) {
    final questionsByCategory = <String, List<QuizQuestion>>{};

    for (final question in questions) {
      questionsByCategory.putIfAbsent(
        question.category,
        () => <QuizQuestion>[],
      );
      questionsByCategory[question.category]!.add(question);
    }

    final topics = <Topic>[];
    var id = 1;

    for (final entry in questionsByCategory.entries) {
      topics.add(Topic(id: id, name: entry.key, questions: [...entry.value]));
      id += 1;
    }

    return List<Topic>.unmodifiable(topics);
  }
}
