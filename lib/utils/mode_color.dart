import 'package:flutter/material.dart';

Color modeBadgeColor(String mode) =>
    {
      "Kontinyu": Colors.blue,
      "Intermiten": Colors.orange,
    }[mode] ??
    Colors.grey;
