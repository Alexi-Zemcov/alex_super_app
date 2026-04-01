import 'package:circle_of_fifths/src/features/circle/di/circle_module.dart';
import 'package:circle_of_fifths/src/features/circle/presentation/screens/circle/circle_screen.dart';
import 'package:flutter/widgets.dart';
import 'package:scoped_di/scoped_di.dart';

class CircleRouteScope extends StatelessWidget {
  const CircleRouteScope({super.key});

  @override
  Widget build(BuildContext context) {
    return const RouteScope(modules: [CircleModule()], child: CircleScreen());
  }
}
