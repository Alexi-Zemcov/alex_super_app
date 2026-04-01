import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppModuleDescriptor {
  AppModuleDescriptor({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.entryLocation,
    required this.rootRoute,
  });

  final String id;
  final String title;
  final String description;
  final IconData icon;
  final String entryLocation;
  final RouteBase rootRoute;
}
