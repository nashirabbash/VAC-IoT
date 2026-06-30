import 'package:flutter/material.dart';
import 'package:vac_dashboard_app/component/bottomSheet.dart';
import 'package:vac_dashboard_app/component/mode_badge.dart';
import 'package:vac_dashboard_app/utils/text_styles.dart';

class HistoryCard extends StatefulWidget {
  const HistoryCard({
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

  @override
  State<HistoryCard> createState() => _HistoryCardState();
}

class _HistoryCardState extends State<HistoryCard> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      onTap: () => HistoryBottomSheet.show(
        context,
        title: widget.title,
        date: widget.date,
        mode: widget.mode,
        duration: widget.duration,
      ),
      child: Card(
        shadowColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.title, style: AppTextStyles.cardTitle),
                      Text(widget.date, style: AppTextStyles.bodyMedium),
                      Text(widget.duration, style: AppTextStyles.bodySemiBold),
                    ],
                  ),
                  ModeBadge(mode: widget.mode),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
