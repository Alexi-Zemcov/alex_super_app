import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/{{featureName.snakeCase()}}_bloc.dart';

class {{featureName.pascalCase()}}Page extends StatelessWidget {
  const {{featureName.pascalCase()}}Page({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => {{featureName.pascalCase()}}Cubit()..init(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('{{featureName.pascalCase()}}'),
        ),
        body: const Center(
          child: Text('Page placeholder'),
        ),
      ),
    );
  }
}

