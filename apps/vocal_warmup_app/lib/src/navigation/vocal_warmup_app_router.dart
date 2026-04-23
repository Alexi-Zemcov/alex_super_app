import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vocal_warmup/vocal_warmup.dart';

final GlobalKey<NavigatorState> vocalWarmupAppRootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'vocal_warmup_app_root');

GoRouter buildVocalWarmupAppRouter({String? initialLocation}) {
  return GoRouter(
    navigatorKey: vocalWarmupAppRootNavigatorKey,
    initialLocation: initialLocation ?? vocalWarmupModule.entryLocation,
    routes: [vocalWarmupModule.rootRoute],
    redirect: (context, state) {
      if (state.uri.path == '/') {
        return vocalWarmupModule.entryLocation;
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
