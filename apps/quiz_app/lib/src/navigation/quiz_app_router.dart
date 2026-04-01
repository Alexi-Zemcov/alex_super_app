import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz/quiz.dart';

final GlobalKey<NavigatorState> quizAppRootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'quiz_app_root');

GoRouter buildQuizAppRouter({String? initialLocation}) {
  return GoRouter(
    navigatorKey: quizAppRootNavigatorKey,
    initialLocation: initialLocation ?? quizModule.entryLocation,
    routes: [quizModule.rootRoute],
    redirect: (context, state) {
      if (state.uri.path == '/') {
        return quizModule.entryLocation;
      }

      return null;
    },
    errorBuilder: (context, state) {
      return _RouterErrorScreen(location: state.uri.toString());
    },
  );
}

class _RouterErrorScreen extends StatelessWidget {
  const _RouterErrorScreen({required this.location});

  final String location;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Маршрут не найден')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Не удалось открыть $location.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
