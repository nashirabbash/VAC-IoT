import 'package:flutter/material.dart';
import 'package:vac_dashboard_app/component/mode_badge.dart';
import 'package:vac_dashboard_app/utils/text_styles.dart';

class HistoryBottomSheet extends StatelessWidget {
  const HistoryBottomSheet({
    required this.title,
    required this.date,
    required this.mode,
    required this.duration,
    super.key,
  });

  final String title;
  final String date;
  final String mode;
  final String duration;

  static void show(
    BuildContext context, {
    required String title,
    required String date,
    required String mode,
    required String duration,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => HistoryBottomSheet(
        title: title,
        date: date,
        mode: mode,
        duration: duration,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.sheetTitle),
                    const SizedBox(height: 8),
                    Text(date, style: AppTextStyles.bodyMuted),
                    const SizedBox(height: 4),
                    Text(duration, style: AppTextStyles.bodySemiBold),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              ModeBadge(mode: mode),
              const SizedBox(height: 16),
            ],
          ),
        ],
      ),
    );
  }
}
