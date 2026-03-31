import 'package:flutter/material.dart';

class AppModuleDescriptor {
  const AppModuleDescriptor({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.rootPageBuilder,
  });

  final String id;
  final String title;
  final String description;
  final IconData icon;
  final WidgetBuilder rootPageBuilder;
}
