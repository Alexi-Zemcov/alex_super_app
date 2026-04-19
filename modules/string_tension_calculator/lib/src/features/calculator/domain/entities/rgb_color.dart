import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class RgbColor extends Equatable {
  const RgbColor({required this.red, required this.green, required this.blue});

  final int red;
  final int green;
  final int blue;

  Color toColor() => Color.fromARGB(255, red, green, blue);

  @override
  List<Object?> get props => [red, green, blue];
}
