import 'package:flutter/material.dart';
import 'package:vac_dashboard_app/asset/color_tokens.dart';

class AppGroupedList extends StatelessWidget {
  final List<Widget> children;
  final Color backgroundColor;
  final double borderRadius;

  const AppGroupedList({
    super.key,
    required this.children,
    this.backgroundColor = Colors.white,
    this.borderRadius = 26.0,
  });

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();

    // Automatically insert dividers between children
    final List<Widget> dividedChildren = [];
    for (int i = 0; i < children.length; i++) {
      if (i > 0) {
        dividedChildren.add(
          Padding(
            padding: const EdgeInsets.only(left: 16.0), // iOS-style divider indent
            child: Container(
              height: 1,
              color: context.colors.separatorsVibrant, // Separators-Vibrant
            ),
          ),
        );
      }
      dividedChildren.add(children[i]);
    }

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: backgroundColor == Colors.white 
            ? context.colors.backgroundsGroupedSecondary
            : backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: dividedChildren,
      ),
    );
  }
}

class AppGroupedListTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? detail;
  final Widget? leading;
  final Widget? trailing;
  final String? badgeLabel;
  final bool showCheckmark;
  final bool? showChevron;
  final VoidCallback? onTap;
  final double? height;
  final TextAlign textAlign;
  final bool isDestructive;

  const AppGroupedListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.detail,
    this.leading,
    this.trailing,
    this.badgeLabel,
    this.showCheckmark = false,
    this.showChevron,
    this.onTap,
    this.height,
    this.textAlign = TextAlign.start,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool effectiveShowChevron = showChevron ?? (onTap != null);
    
    // Determine min height: default to 68 if subtitle is present, otherwise 52
    final double minHeight = height ?? (subtitle != null ? 68.0 : 52.0);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: BoxConstraints(minHeight: minHeight),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Leading Widget
              if (leading != null) ...[
                leading!,
                const SizedBox(width: 12),
              ],

              // Title and Subtitle Column
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: textAlign == TextAlign.center
                      ? CrossAxisAlignment.stretch
                      : CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: textAlign,
                      style: TextStyle(
                        color: isDestructive ? context.colors.accentsRed : context.colors.labelsPrimary,
                        fontSize: 17,
                        fontFamily: 'SF Pro',
                        fontWeight: FontWeight.w400,
                        height: 1.29,
                        letterSpacing: -0.43,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: context.colors.labelsSecondary,
                          fontSize: 15,
                          fontFamily: 'SF Pro',
                          fontWeight: FontWeight.w400,
                          height: 1.33,
                          letterSpacing: -0.23,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Trailing Elements
              const SizedBox(width: 8),
              if (trailing != null)
                trailing!
              else
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Detail Text
                    if (detail != null)
                      Text(
                        detail!,
                        style: TextStyle(
                          color: context.colors.labelsSecondary,
                          fontSize: 17,
                          fontFamily: 'SF Pro',
                          fontWeight: FontWeight.w400,
                          height: 1.29,
                          letterSpacing: -0.43,
                        ),
                      ),
                    
                    // Badge (e.g. date badge)
                    if (badgeLabel != null) ...[
                      if (detail != null) const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                        decoration: ShapeDecoration(
                          color: context.colors.fillsTertiary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                        child: Text(
                          badgeLabel!,
                          style: TextStyle(
                            color: context.colors.labelsPrimary,
                            fontSize: 17,
                            fontFamily: 'SF Pro',
                            fontWeight: FontWeight.w400,
                            height: 1.29,
                            letterSpacing: -0.43,
                          ),
                        ),
                      ),
                    ],

                    // Blue Checkmark Icon
                    if (showCheckmark) ...[
                      if (detail != null || badgeLabel != null) const SizedBox(width: 8),
                      Icon(
                        Icons.check,
                        color: context.colors.accentsBlue,
                        size: 20,
                      ),
                    ],

                    // Grey Navigation Chevron Right
                    if (effectiveShowChevron) ...[
                      if (detail != null || badgeLabel != null || showCheckmark)
                        const SizedBox(width: 8),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: context.colors.labelsTertiary,
                        size: 20,
                      ),
                    ],
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
