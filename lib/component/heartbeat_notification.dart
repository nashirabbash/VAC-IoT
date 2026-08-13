import 'package:flutter/material.dart';
import 'package:vac_dashboard_app/asset/color_tokens.dart';
import 'package:vac_dashboard_app/component/text.dart';

class HeartbeatNotificationOverlay extends StatefulWidget {
  final VoidCallback? onDismiss;

  const HeartbeatNotificationOverlay({
    super.key,
    this.onDismiss,
  });

  static OverlayEntry? _entry;

  static void showOnOverlay(OverlayState overlay) {
    if (_entry != null) return;

    _entry = OverlayEntry(
      builder: (_) => const HeartbeatNotificationOverlay(),
    );
    overlay.insert(_entry!);
  }

  static void dismiss() {
    _entry?.remove();
    _entry = null;
  }

  @override
  State<HeartbeatNotificationOverlay> createState() => _HeartbeatNotificationOverlayState();
}

class _HeartbeatNotificationOverlayState extends State<HeartbeatNotificationOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slide;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, -1.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _fade = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Positioned(
      top: MediaQuery.of(context).padding.top + 12,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _fade,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark
                    ? colors.backgroundsPrimaryElevated
                    : colors.backgroundsPrimary,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: colors.accentsRed,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors.accentsRed.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors.accentsRed.withValues(alpha: 0.15),
                    ),
                    child: Icon(
                      Icons.bluetooth_disabled_rounded,
                      color: colors.accentsRed,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppText(
                          'KONEKSI TERPUTUS',
                          type: AppTextType.subheadline,
                          fontWeight: FontWeight.bold,
                          color: AppTextColor.primary,
                        ),
                        const SizedBox(height: 2),
                        AppText(
                          'Perangkat VAC STECHOQ tidak mengirim data (>5 detik). Harap periksa koneksi.',
                          type: AppTextType.caption1,
                          color: AppTextColor.secondary,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
