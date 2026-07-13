import 'package:flutter/material.dart';
import 'package:vac_dashboard_app/component/card.dart';

class SectionHistory extends StatefulWidget {
  const SectionHistory({this.date = '', this.items = const [], super.key});

  final String date;
  final List<Map<String, String>> items;

  @override
  State<SectionHistory> createState() => _SectionHistoryState();
}

class _SectionHistoryState extends State<SectionHistory> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 16.0,
                top: 16.0,
                right: 16.0,
              ),
              child: Text(
                widget.date,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w400),
              ),
            ),
          ],
        ),
        ...widget.items.asMap().entries.map(
          (e) => _TimelineItem(
            isFirst: e.key == 0,
            isLast: e.key == widget.items.length - 1,
            child: HistoryCard(
              title: e.value['title'] ?? '',
              date: e.value['date'] ?? '',
              mode: e.value['mode'] ?? '',
              duration: e.value['duration'] ?? '',
            ),
          ),
        ),
      ],
    );
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({
    required this.child,
    this.isFirst = false,
    this.isLast = false,
  });

  final Widget child;
  final bool isFirst;
  final bool isLast;

  static const double _dotSize = 12;
  static const double _dotTopOffset = 16;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (!isFirst)
                    Container(
                      width: 2,
                      height: _dotTopOffset,
                      color: Colors.black26,
                    ),
                  if (isFirst) const SizedBox(height: _dotTopOffset),
                  Container(
                    width: _dotSize,
                    height: _dotSize,
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 101, 157, 255),
                      shape: BoxShape.circle,
                    ),
                  ),
                  if (!isLast)
                    Expanded(child: Container(width: 2, color: Colors.black26)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}
