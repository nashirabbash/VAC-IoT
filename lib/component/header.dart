import 'package:flutter/material.dart';
import 'package:vac_dashboard_app/component/splitButton.dart';
import 'package:vac_dashboard_app/utils/text_styles.dart';

class Header extends StatefulWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
  const Header({
    required this.title,
    this.splitButtonLabel = 'Action',
    this.onSplitButtonPressed,
    this.onSplitDropdownPressed,
    this.splitMenuItems = const [],
    this.scrollController,
    this.onYearSelected,
    super.key,
  });

  final String title;
  final String splitButtonLabel;
  final VoidCallback? onSplitButtonPressed;
  final VoidCallback? onSplitDropdownPressed;
  final List<PopupMenuEntry<String>> splitMenuItems;
  final ScrollController? scrollController;
  final void Function(String)? onYearSelected;

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    widget.scrollController?.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.scrollController?.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    final scrolled = (widget.scrollController?.offset ?? 0) > 0;
    if (scrolled != _isScrolled) setState(() => _isScrolled = scrolled);
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: _isScrolled
          ? Colors.white.withValues(alpha: 0.92)
          : Colors.transparent,
      centerTitle: false,
      elevation: _isScrolled ? 1 : 0,
      title: Text(widget.title, style: AppTextStyles.headerTitle),
      actions: [
        SplitButton(
          label: widget.splitButtonLabel,
          onPressed: widget.onSplitButtonPressed,
          menuItems: widget.splitMenuItems,
          onSelected: widget.onYearSelected,
        ),
        const SizedBox(width: 16),
      ],
    );
  }
}
