import 'package:flutter/material.dart';
import 'package:module_contracts/module_contracts.dart';
import 'package:vocal_warmup/src/navigation/vocal_warmup_routes.dart';

final vocalWarmupModule = AppModuleDescriptor(
  id: 'vocal_warmup',
  title: 'Распевка',
  description: 'Определение диапазона и короткие вокальные распевки.',
  icon: Icons.graphic_eq_rounded,
  entryLocation: vocalWarmupEntryLocation,
  rootRoute: vocalWarmupModuleRootRoute,
);
