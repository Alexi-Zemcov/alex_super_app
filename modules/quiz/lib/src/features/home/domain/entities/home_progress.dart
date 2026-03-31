import 'package:equatable/equatable.dart';

class HomeProgress extends Equatable {
  const HomeProgress({
    required this.completedQuestions,
    required this.totalQuestions,
    required this.completedTickets,
    required this.totalTickets,
    required this.completedTopics,
    required this.totalTopics,
  });

  final int completedQuestions;
  final int totalQuestions;
  final int completedTickets;
  final int totalTickets;
  final int completedTopics;
  final int totalTopics;

  double get questionsRatio => _safeRatio(completedQuestions, totalQuestions);

  double get ticketsRatio => _safeRatio(completedTickets, totalTickets);

  double get topicsRatio => _safeRatio(completedTopics, totalTopics);

  static double _safeRatio(int completed, int total) {
    if (total == 0) {
      return 0;
    }

    return completed / total;
  }

  @override
  List<Object?> get props => [
    completedQuestions,
    totalQuestions,
    completedTickets,
    totalTickets,
    completedTopics,
    totalTopics,
  ];
}
