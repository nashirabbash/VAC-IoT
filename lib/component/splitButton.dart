import 'package:flutter/material.dart';
import 'package:vac_dashboard_app/component/menu.dart';
import 'package:vac_dashboard_app/asset/color_tokens.dart';

enum SplitButtonSize { xsmall, small, medium, large, xlarge }

enum SplitButtonVariant { primary, secondary, outline, elevated }

class SplitButton extends StatefulWidget {
  final String label;
  final IconData? icon; // Optional leading icon
  final SplitButtonSize size;
  final SplitButtonVariant variant;
  final VoidCallback? onPressed;
  final List<Widget> menuItems; // List of items for the dropdown menu

  const SplitButton({
    super.key,
    required this.label,
    this.icon,
    this.size = SplitButtonSize.medium,
    this.variant = SplitButtonVariant.primary,
    this.onPressed,
    required this.menuItems,
  });

  @override
  State<SplitButton> createState() => _SplitButtonState();
}

class _SplitButtonState extends State<SplitButton> {
  final GlobalKey _dropdownKey = GlobalKey();

  double get _height {
    switch (widget.size) {
      case SplitButtonSize.xsmall:
        return 32.0;
      case SplitButtonSize.small:
        return 36.0;
      case SplitButtonSize.medium:
        return 40.0;
      case SplitButtonSize.large:
        return 48.0;
      case SplitButtonSize.xlarge:
        return 56.0;
    }
  }

  double get _fontSize {
    switch (widget.size) {
      case SplitButtonSize.xsmall:
        return 12.0;
      case SplitButtonSize.small:
        return 14.0;
      case SplitButtonSize.medium:
        return 16.0;
      case SplitButtonSize.large:
      case SplitButtonSize.xlarge:
        return 16.0;
    }
  }

  double get _iconSize {
    switch (widget.size) {
      case SplitButtonSize.xsmall:
        return 16.0;
      case SplitButtonSize.small:
      case SplitButtonSize.medium:
        return 20.0;
      case SplitButtonSize.large:
      case SplitButtonSize.xlarge:
        return 24.0;
    }
  }

  double get _dropdownWidth {
    switch (widget.size) {
      case SplitButtonSize.xsmall:
        return 32.0;
      case SplitButtonSize.small:
        return 36.0;
      case SplitButtonSize.medium:
        return 40.0;
      case SplitButtonSize.large:
        return 48.0;
      case SplitButtonSize.xlarge:
        return 56.0;
    }
  }

  Color _backgroundColor(BuildContext context) {
    switch (widget.variant) {
      case SplitButtonVariant.primary:
        return context.colors.accentsBlue;
      case SplitButtonVariant.secondary:
        return context.colors.fillsSecondary;
      case SplitButtonVariant.outline:
        return Colors.transparent;
      case SplitButtonVariant.elevated:
        return context.colors.backgroundsPrimary;
    }
  }

  Color _foregroundColor(BuildContext context) {
    switch (widget.variant) {
      case SplitButtonVariant.primary:
        return context.colors.graysWhite;
      case SplitButtonVariant.secondary:
        return context.colors.labelsPrimary;
      case SplitButtonVariant.outline:
        return context.colors.labelsPrimary;
      case SplitButtonVariant.elevated:
        return context.colors.accentsBlue;
    }
  }

  BoxBorder? _border(BuildContext context) {
    if (widget.variant == SplitButtonVariant.outline) {
      return Border.all(color: context.colors.separatorsOpaque, width: 1);
    }
    return null;
  }

  List<BoxShadow>? _boxShadow(BuildContext context) {
    if (widget.variant == SplitButtonVariant.elevated) {
      return [
        BoxShadow(
          color: const Color(0x4C000000).withValues(
            alpha: Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.15,
          ),
          blurRadius: 3,
          offset: const Offset(0, 1),
        ),
        BoxShadow(
          color: const Color(0x26000000).withValues(
            alpha: Theme.of(context).brightness == Brightness.dark ? 0.2 : 0.08,
          ),
          blurRadius: 8,
          offset: const Offset(0, 4),
          spreadRadius: 3,
        ),
      ];
    }
    return null;
  }

  void _showDropdownMenu() {
    final RenderBox renderBox =
        _dropdownKey.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    showDialog(
      context: context,
      barrierColor: Colors.transparent, // Non-dimming barrier
      builder: (context) {
        return Stack(
          children: [
            // Tap detector outside the menu to dismiss it
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                behavior: HitTestBehavior.opaque,
              ),
            ),
            // Menu aligned below the split button (aligning dropdown part)
            Positioned(
              top: offset.dy + size.height + 8, // Directly below the dropdown
              left:
                  offset.dx +
                  size.width -
                  180, // Right-aligned with the dropdown
              child: Material(
                color: Colors.transparent,
                child: AppContextMenu(width: 180, children: widget.menuItems),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = _height;
    final radiusOuter = height / 2;
    const radiusInner = 4.0;

    final Color bgColor = _backgroundColor(context);
    final Color fgColor = _foregroundColor(context);
    final BoxBorder? bdr = _border(context);
    final List<BoxShadow>? shd = _boxShadow(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Main Button (Left)
        Container(
          height: height,
          decoration: BoxDecoration(
            color: bgColor,
            border: bdr,
            boxShadow: shd,
            borderRadius: BorderRadius.horizontal(
              left: Radius.circular(radiusOuter),
              right: const Radius.circular(radiusInner),
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onPressed,
              borderRadius: BorderRadius.horizontal(
                left: Radius.circular(radiusOuter),
                right: const Radius.circular(radiusInner),
              ),
              splashColor: fgColor.withValues(alpha: 0.1),
              highlightColor: fgColor.withValues(alpha: 0.1),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: radiusOuter * 0.75),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(widget.icon, size: _iconSize, color: fgColor),
                      SizedBox(width: height * 0.2),
                    ],
                    Text(
                      widget.label,
                      style: TextStyle(
                        color: fgColor,
                        fontSize: _fontSize,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 2), // Gap between parts
        // Dropdown Button (Right)
        Container(
          key: _dropdownKey,
          height: height,
          width: _dropdownWidth,
          decoration: BoxDecoration(
            color: bgColor,
            border: bdr,
            boxShadow: shd,
            borderRadius: BorderRadius.horizontal(
              left: const Radius.circular(radiusInner),
              right: Radius.circular(radiusOuter),
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _showDropdownMenu,
              borderRadius: BorderRadius.horizontal(
                left: const Radius.circular(radiusInner),
                right: Radius.circular(radiusOuter),
              ),
              splashColor: fgColor.withValues(alpha: 0.1),
              highlightColor: fgColor.withValues(alpha: 0.1),
              child: Center(
                child: Icon(
                  Icons.arrow_drop_down,
                  color: fgColor,
                  size: _iconSize,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
