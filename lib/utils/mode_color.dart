import 'package:flutter/material.dart';

Color modeBadgeColor(String mode) =>
    {
      "Hard": Colors.red,
      "Medium": Colors.orange,
      "Easy": Colors.green,
    }[mode] ??
    Colors.blue;
