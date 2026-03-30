import 'dart:convert';

import 'package:alex_super_app/features/quiz/data/models/quiz_question_model.dart';
import 'package:flutter/services.dart';

abstract interface class QuestionLocalDataSource {
  Future<List<QuizQuestionModel>> loadQuestions();
}

class AssetQuestionLocalDataSource implements QuestionLocalDataSource {
  const AssetQuestionLocalDataSource({
    required AssetBundle assetBundle,
    required this.assetPath,
  }) : _assetBundle = assetBundle;

  static const defaultAssetPath = 'assets/data/questions.json';

  final AssetBundle _assetBundle;
  final String assetPath;

  @override
  Future<List<QuizQuestionModel>> loadQuestions() async {
    final rawJson = await _assetBundle.loadString(assetPath);
    final decoded = jsonDecode(rawJson);

    if (decoded is! List<dynamic>) {
      throw const FormatException('Questions asset must contain a JSON array.');
    }

    return decoded
        .map(
          (item) => QuizQuestionModel.fromJson(
            Map<String, dynamic>.from(item as Map<dynamic, dynamic>),
          ),
        )
        .toList(growable: false);
  }
}
