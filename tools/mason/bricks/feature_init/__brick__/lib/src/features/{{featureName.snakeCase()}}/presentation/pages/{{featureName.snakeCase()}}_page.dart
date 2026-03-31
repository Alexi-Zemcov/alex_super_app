import 'package:flutter/material.dart';

class {{featureName.pascalCase()}}Page extends StatelessWidget {
  const {{featureName.pascalCase()}}Page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('{{featureName.pascalCase()}}'),
      ),
      body: const Center(
        child: Text('Page placeholder'),
      ),
    );
  }
}
