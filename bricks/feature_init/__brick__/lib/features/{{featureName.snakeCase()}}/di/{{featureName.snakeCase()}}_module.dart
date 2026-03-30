import 'package:alex_super_app/app/di/scope_module.dart';
import 'package:alex_super_app/features/{{featureName.snakeCase()}}/presentation/bloc/{{featureName.snakeCase()}}_bloc.dart';
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
