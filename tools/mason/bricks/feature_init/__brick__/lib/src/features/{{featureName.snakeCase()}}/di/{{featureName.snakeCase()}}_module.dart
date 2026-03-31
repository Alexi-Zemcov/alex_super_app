import '../../../di/scope_module.dart';
import '../presentation/bloc/{{featureName.snakeCase()}}_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/single_child_widget.dart';

class {{featureName.pascalCase()}}Module extends ScopeModule {
  const {{featureName.pascalCase()}}Module();

  @override
  List<SingleChildWidget> get providers => [
    BlocProvider<{{featureName.pascalCase()}}Cubit>(
      create: (context) => {{featureName.pascalCase()}}Cubit()..init(),
    ),
  ];
}
