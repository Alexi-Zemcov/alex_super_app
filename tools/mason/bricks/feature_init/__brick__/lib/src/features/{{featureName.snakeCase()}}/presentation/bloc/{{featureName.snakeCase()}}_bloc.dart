import 'package:flutter_bloc/flutter_bloc.dart';

class {{featureName.pascalCase()}}State {
  const {{featureName.pascalCase()}}State();
}

class {{featureName.pascalCase()}}Cubit extends Cubit<{{featureName.pascalCase()}}State> {
  {{featureName.pascalCase()}}Cubit() : super(const {{featureName.pascalCase()}}State());

  /// Place for initialization / load events.
  void init() {}
}

