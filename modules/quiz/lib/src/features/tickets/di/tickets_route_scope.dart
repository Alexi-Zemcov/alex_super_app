import 'package:flutter/widgets.dart';
import 'package:quiz/src/features/tickets/di/tickets_module.dart';
import 'package:quiz/src/features/tickets/presentation/screens/tickets/tickets_screen.dart';
import 'package:scoped_di/scoped_di.dart';

class TicketsRouteScope extends StatelessWidget {
  const TicketsRouteScope({super.key});

  @override
  Widget build(BuildContext context) {
    return const RouteScope(modules: [TicketsModule()], child: TicketsScreen());
  }
}
