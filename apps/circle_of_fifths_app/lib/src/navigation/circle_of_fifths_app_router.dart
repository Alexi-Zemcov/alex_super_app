import 'package:circle_of_fifths/circle_of_fifths.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GlobalKey<NavigatorState> circleOfFifthsAppRootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'circle_of_fifths_app_root');

GoRouter buildCircleOfFifthsAppRouter({String? initialLocation}) {
  return GoRouter(
    navigatorKey: circleOfFifthsAppRootNavigatorKey,
    initialLocation: initialLocation ?? circleOfFifthsModule.entryLocation,
    routes: [circleOfFifthsModule.rootRoute],
    redirect: (context, state) {
      if (state.uri.path == '/') {
        return circleOfFifthsModule.entryLocation;
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
