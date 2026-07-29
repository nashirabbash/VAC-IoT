import 'package:flutter/material.dart';

Color modeBadgeColor(String mode) {
  switch (mode.trim().toLowerCase()) {
    case 'kontinyu':
    case 'continuous':
      return Colors.blue;
    case 'intermiten':
    case 'intermittent':
      return Colors.orange;
    default:
      return Colors.grey;
  }
}
