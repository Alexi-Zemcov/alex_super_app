import 'package:flutter/widgets.dart';
import 'package:scoped_di/scoped_di.dart';
import 'package:vocal_warmup/src/features/range_detection/di/range_flow_module.dart';
import 'package:vocal_warmup/src/features/range_detection/presentation/screens/range_flow/range_flow_screen.dart';

class RangeFlowRouteScope extends StatelessWidget {
  const RangeFlowRouteScope({super.key});

  @override
  Widget build(BuildContext context) {
    return const RouteScope(
      modules: [RangeFlowModule()],
      child: RangeFlowScreen(),
    );
  }
}
