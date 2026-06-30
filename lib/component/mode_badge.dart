import 'package:flutter/material.dart';
import 'package:vac_dashboard_app/utils/mode_color.dart';

class ModeBadge extends StatelessWidget {
  const ModeBadge({required this.mode, super.key});

  final String mode;

  @override
  Widget build(BuildContext context) {
    return Badge(
      textStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      label: Text(mode),
      backgroundColor: modeBadgeColor(mode),
    );
  }
}
