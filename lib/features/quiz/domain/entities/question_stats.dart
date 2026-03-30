import 'package:equatable/equatable.dart';

class QuestionStats extends Equatable {
  const QuestionStats({
    required this.correctAttempts,
    required this.totalAttempts,
  });

  final int correctAttempts;
  final int totalAttempts;

  bool get hasCorrectAttempt => correctAttempts > 0;

  factory QuestionStats.fromStorageMap(Map<String, dynamic> rawStats) {
    return QuestionStats(
      correctAttempts: _readInt(
        rawStats['correctAttempts'] ?? rawStats['correct'],
      ),
      totalAttempts: _readInt(rawStats['totalAttempts'] ?? rawStats['total']),
    );
  }

  static int _readInt(Object? value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return 0;
  }

  @override
  List<Object?> get props => [correctAttempts, totalAttempts];
}
