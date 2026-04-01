import 'package:equatable/equatable.dart';

class QuizCategoryResult extends Equatable {
  const QuizCategoryResult({
    required this.category,
    required this.correctCount,
    required this.totalCount,
  });

  final String category;
  final int correctCount;
  final int totalCount;

  int get percentage =>
      totalCount == 0 ? 0 : ((correctCount / totalCount) * 100).round();

  @override
  List<Object?> get props => [category, correctCount, totalCount];
}

class QuizResult extends Equatable {
  const QuizResult({
    required this.correctCount,
    required this.totalCount,
    required this.categoryResults,
  });

  final int correctCount;
  final int totalCount;
  final List<QuizCategoryResult> categoryResults;

  int get percentage =>
      totalCount == 0 ? 0 : ((correctCount / totalCount) * 100).round();

  @override
  List<Object?> get props => [correctCount, totalCount, categoryResults];
}
