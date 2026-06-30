import 'package:flutter/material.dart';

class SplitButton extends StatefulWidget {
  const SplitButton({
    required this.label,
    required this.menuItems,
    this.onPressed,
    this.onSelected,
  });

  final String label;
  final VoidCallback? onPressed;
  final List<PopupMenuEntry<String>> menuItems;
  final void Function(String)? onSelected;

  @override
  State<SplitButton> createState() => _SplitButtonState();
}

class _SplitButtonState extends State<SplitButton> {
  bool _isOpen = false;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: widget.onPressed,
      style: OutlinedButton.styleFrom(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(999)),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.label),
          const SizedBox(width: 4),
          Theme(
            data: Theme.of(context).copyWith(
              popupMenuTheme: const PopupMenuThemeData(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
              ),
            ),
            child: PopupMenuButton<String>(
              offset: const Offset(0, 36),
              onOpened: () => setState(() => _isOpen = true),
              onCanceled: () => setState(() => _isOpen = false),
              onSelected: (val) {
                setState(() => _isOpen = false);
                widget.onSelected?.call(val);
              },
              itemBuilder: (_) => widget.menuItems,
              child: Icon(
                _isOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
