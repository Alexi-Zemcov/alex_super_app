import 'package:circle_of_fifths/src/navigation/circle_of_fifths_routes.dart';
import 'package:flutter/material.dart';
import 'package:module_contracts/module_contracts.dart';

final circleOfFifthsModule = AppModuleDescriptor(
  id: 'circle_of_fifths',
  title: 'Circle of Fifths',
  description: 'Интерактивный круг квинт с аккордами, настройками и MIDI.',
  icon: Icons.music_note_rounded,
  entryLocation: circleEntryLocation,
  rootRoute: circleOfFifthsModuleRootRoute,
);
