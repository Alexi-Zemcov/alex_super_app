import 'package:flutter/widgets.dart';
import 'package:scoped_di/scoped_di.dart';
import 'package:vocal_warmup/src/features/warmup/di/warmup_module.dart';
import 'package:vocal_warmup/src/features/warmup/presentation/screens/warmup/warmup_screen.dart';

class WarmupRouteScope extends StatelessWidget {
  const WarmupRouteScope({super.key});

  @override
  Widget build(BuildContext context) {
    return const RouteScope(modules: [WarmupModule()], child: WarmupScreen());
  }
}
