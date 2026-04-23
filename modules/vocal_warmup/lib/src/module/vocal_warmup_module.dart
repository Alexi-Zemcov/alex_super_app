import 'package:flutter/material.dart';
import 'package:module_contracts/module_contracts.dart';
import 'package:vocal_warmup/src/navigation/vocal_warmup_routes.dart';

final vocalWarmupModule = AppModuleDescriptor(
  id: 'vocal_warmup',
  title: 'Распевка',
  description: 'Разминка голоса по полутонам с выбором упражнения и диапазона.',
  icon: Icons.record_voice_over_rounded,
  entryLocation: vocalWarmupEntryLocation,
  rootRoute: vocalWarmupModuleRootRoute,
);
