import 'package:equatable/equatable.dart';

class TicketListItem extends Equatable {
  const TicketListItem({
    required this.id,
    required this.correctCount,
    required this.answeredCount,
    required this.totalCount,
  });

  final int id;
  final int correctCount;
  final int answeredCount;
  final int totalCount;

  bool get isCompleted => correctCount == totalCount;

  double get progressRatio => totalCount == 0 ? 0 : correctCount / totalCount;

  @override
  List<Object?> get props => [id, correctCount, answeredCount, totalCount];
}
