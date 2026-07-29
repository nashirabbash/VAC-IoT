import 'package:flutter/material.dart';

Color modeBadgeColor(String mode) {
  final normalized = mode.trim().toLowerCase();
  if (normalized == 'kontinyu' || normalized == 'continuous') return Colors.blue;
  if (normalized == 'intermiten' || normalized == 'intermittent') return Colors.orange;
  return Colors.grey;
}
