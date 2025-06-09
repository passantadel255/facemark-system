import 'package:flutter/material.dart';

HexColor(String hexColorString) {
  final hexCode = hexColorString.replaceAll('#', '');
  return Color(int.parse('FF$hexCode', radix: 16));
}