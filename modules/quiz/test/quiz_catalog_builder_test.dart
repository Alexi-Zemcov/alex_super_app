import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:quiz/quiz_assets.dart';
import 'package:quiz/src/features/quiz/data/models/quiz_question_model.dart';
import 'package:quiz/src/features/quiz/domain/services/quiz_catalog_builder.dart';

void main() {
  test('builds tickets and topics from the bundled dataset', () async {
    final rawJson = await File(QuizAssets.questions).readAsString();
    final decoded = jsonDecode(rawJson) as List<dynamic>;
    final questions = decoded
        .map(
          (item) => QuizQuestionModel.fromJson(
            Map<String, dynamic>.from(item as Map<dynamic, dynamic>),
          ),
        )
        .map((model) => model.toEntity())
        .toList(growable: false);
    const catalogBuilder = QuizCatalogBuilder();

    expect(catalogBuilder.buildTickets(questions), hasLength(12));
    expect(catalogBuilder.buildTopics(questions), hasLength(14));
  });
}
