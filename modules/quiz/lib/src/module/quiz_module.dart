import 'package:flutter/material.dart';
import 'package:module_contracts/module_contracts.dart';
import 'package:quiz/src/navigation/quiz_routes.dart';

final quizModule = AppModuleDescriptor(
  id: 'quiz',
  title: 'Flutter Quiz',
  description:
      'Оффлайн-квиз по Flutter и Dart с билетами, темами и прогрессом.',
  icon: Icons.quiz_rounded,
  entryLocation: quizEntryLocation,
  rootRoute: quizModuleRootRoute,
);
