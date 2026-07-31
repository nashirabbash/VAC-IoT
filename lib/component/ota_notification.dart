import 'dart:async';

import 'package:flutter/material.dart';
import 'package:vac_dashboard_app/asset/color_tokens.dart';
import 'package:vac_dashboard_app/component/text.dart';

enum OtaNotifState {
  checking,
  downloading,
  flashing,
  rebooting,
  success,
  failed,
}

class OtaNotifConfig {
  final OtaNotifState state;

  /// 0.0–1.0. null = indeterminate (shimmer)
  final double? progress;

  /// Target chip label: "ESP32", "ATmega", "Nextion"
  final String device;

  const OtaNotifConfig({
    required this.state,
    this.progress,
    this.device = 'ESP32',
  });

  static OtaNotifConfig fromBleMessage(Map<String, dynamic> msg) {
    final type = msg['type'] as String? ?? '';
    final device = _resolveDevice(msg['device'] as String? ?? 'esp');

    switch (type) {
      case 'ota_progress':
        final written = (msg['written'] as num?)?.toInt() ?? 0;
        final total = (msg['total'] as num?)?.toInt() ?? 1;
        return OtaNotifConfig(
          state: OtaNotifState.downloading,
          progress: total > 0 ? written / total : 0,
          device: device,
        );
      case 'ota_status':
        final status = msg['status'] as String? ?? '';
        return OtaNotifConfig(state: _statusToState(status), device: device);
      case 'update_pending':
        final pending = msg['pending'] as bool? ?? false;
        return OtaNotifConfig(
          state: pending ? OtaNotifState.checking : OtaNotifState.success,
          device: device,
        );
      default:
        return const OtaNotifConfig(state: OtaNotifState.checking);
    }
  }

  static String _resolveDevice(String raw) {
    switch (raw.toLowerCase()) {
      case 'atm':
        return 'ATmega';
      case 'nex':
        return 'Nextion';
      default:
        return 'ESP32';
    }
  }

  static OtaNotifState _statusToState(String status) {
    switch (status) {
      case 'flashing':
        return OtaNotifState.flashing;
      case 'success':
        return OtaNotifState.success;
      case 'rebooting':
        return OtaNotifState.rebooting;
      case 'failed':
        return OtaNotifState.failed;
      default:
        return OtaNotifState.checking;
    }
  }
}

class _OtaStatePresentation {
  final String title;
  final String message;
  final IconData icon;
  final Color Function(AppColorTokenSet) accentColor;
  final bool showProgress;
  final bool isIndeterminate;
  final bool autoDismiss;

  const _OtaStatePresentation({
    required this.title,
    required this.message,
    required this.icon,
    required this.accentColor,
    this.showProgress = false,
    this.isIndeterminate = false,
    this.autoDismiss = false,
  });
}

_OtaStatePresentation _presentationFor(OtaNotifConfig config) {
  final device = config.device;
  switch (config.state) {
    case OtaNotifState.checking:
      return _OtaStatePresentation(
        title: 'Memeriksa Pembaruan',
        message: 'Menghubungi server untuk $device...',
        icon: Icons.cloud_sync_rounded,
        accentColor: (c) => c.accentsBlue,
        showProgress: true,
        isIndeterminate: true,
      );
    case OtaNotifState.downloading:
      final pct = config.progress != null
          ? '${(config.progress! * 100).toStringAsFixed(0)}%'
          : '...';
      return _OtaStatePresentation(
        title: 'Mengunduh Firmware',
        message: 'Firmware $device — $pct',
        icon: Icons.download_rounded,
        accentColor: (c) => c.accentsBlue,
        showProgress: true,
        isIndeterminate: config.progress == null,
      );
    case OtaNotifState.flashing:
      return _OtaStatePresentation(
        title: 'Flashing Firmware',
        message: 'Menulis ke $device, jangan matikan daya...',
        icon: Icons.bolt_rounded,
        accentColor: (c) => c.accentsOrange,
        showProgress: true,
        isIndeterminate: config.progress == null,
      );
    case OtaNotifState.rebooting:
      return _OtaStatePresentation(
        title: 'Merestart Perangkat',
        message: '$device akan restart sebentar...',
        icon: Icons.restart_alt_rounded,
        accentColor: (c) => c.accentsPurple,
        showProgress: true,
        isIndeterminate: true,
      );
    case OtaNotifState.success:
      return _OtaStatePresentation(
        title: 'Pembaruan Berhasil',
        message: '$device berhasil diperbarui.',
        icon: Icons.check_circle_rounded,
        accentColor: (c) => c.accentsGreen,
        showProgress: false,
        autoDismiss: true,
      );
    case OtaNotifState.failed:
      return _OtaStatePresentation(
        title: 'Pembaruan Gagal',
        message: 'Gagal memperbarui $device. Coba lagi.',
        icon: Icons.error_rounded,
        accentColor: (c) => c.accentsRed,
        showProgress: false,
        autoDismiss: false,
      );
  }
}

/// Sliding notification banner for OTA update events.
///
/// Usage — place an [OtaNotificationOverlay] at the top of your widget tree
/// (e.g., inside a [Stack] above the scaffold body), then call
/// [OtaNotificationOverlay.show(context, config)] from your BLE listener.
///
/// Example:
/// ```dart
/// bleService.onMessage
///   .where((m) => ['ota_progress','ota_status','update_pending'].contains(m['type']))
///   .listen((msg) {
///     final config = OtaNotifConfig.fromBleMessage(msg);
///     OtaNotificationOverlay.show(context, config);
///   });
/// ```
class OtaNotificationOverlay extends StatefulWidget {
  final OtaNotifConfig config;
  final VoidCallback? onDismiss;

  const OtaNotificationOverlay({
    super.key,
    required this.config,
    this.onDismiss,
  });

  static OverlayEntry? _entry;
  static final _configNotifier = ValueNotifier<OtaNotifConfig?>(null);

  static void show(BuildContext context, OtaNotifConfig config) {
    showOnOverlay(Overlay.of(context), config);
  }

  /// Insert (or replace) the banner using an [OverlayState] directly.
  /// Use this from services/singletons that have no [BuildContext].
  ///
  /// If a banner is already visible, only the config is updated — the
  /// slide-in animation does NOT replay. Progress bar animates in-place.
  static void showOnOverlay(OverlayState overlay, OtaNotifConfig config) {
    _configNotifier.value = config;

    if (_entry != null) return; // already showing — notifier update is enough

    _entry = OverlayEntry(
      builder: (_) => ValueListenableBuilder<OtaNotifConfig?>(
        valueListenable: _configNotifier,
        builder: (_, cfg, _) {
          if (cfg == null) return const SizedBox.shrink();
          return _OtaNotificationBanner(config: cfg, onDismiss: dismiss);
        },
      ),
    );
    overlay.insert(_entry!);
  }

  static void dismiss() {
    _entry?.remove();
    _entry = null;
    _configNotifier.value = null;
  }

  @override
  State<OtaNotificationOverlay> createState() => _OtaNotificationOverlayState();
}

class _OtaNotificationOverlayState extends State<OtaNotificationOverlay> {
  @override
  Widget build(BuildContext context) {
    return _OtaNotificationBanner(
      config: widget.config,
      onDismiss: widget.onDismiss,
    );
  }
}

class _OtaNotificationBanner extends StatefulWidget {
  final OtaNotifConfig config;
  final VoidCallback? onDismiss;

  const _OtaNotificationBanner({required this.config, this.onDismiss});

  @override
  State<_OtaNotificationBanner> createState() => _OtaNotificationBannerState();
}

class _OtaNotificationBannerState extends State<_OtaNotificationBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slide;
  late Animation<double> _fade;
  Timer? _autoDismissTimer;
  Timer? _shimmerTimer;
  double _shimmerValue = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
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
    _scheduleAutoDismiss();
    _startShimmer();
  }

  @override
  void didUpdateWidget(covariant _OtaNotificationBanner old) {
    super.didUpdateWidget(old);
    if (old.config.state != widget.config.state ||
        old.config.progress != widget.config.progress) {
      _autoDismissTimer?.cancel();
      _scheduleAutoDismiss();
    }
  }

  void _scheduleAutoDismiss() {
    final pres = _presentationFor(widget.config);
    if (pres.autoDismiss) {
      _autoDismissTimer = Timer(const Duration(seconds: 3), _dismiss);
    }
  }

  void _startShimmer() {
    _shimmerTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      if (!mounted) return;
      setState(() {
        _shimmerValue = (_shimmerValue + 0.03) % 1.0;
      });
    });
  }

  void _dismiss() {
    _controller.reverse().then((_) => widget.onDismiss?.call());
  }

  @override
  void dispose() {
    _autoDismissTimer?.cancel();
    _shimmerTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pres = _presentationFor(widget.config);
    final colors = context.colors;
    final accent = pres.accentColor(colors);
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
            child: GestureDetector(
              onVerticalDragEnd: (d) {
                if (d.primaryVelocity != null && d.primaryVelocity! < -100) {
                  _dismiss();
                }
              },
              onTap: widget.config.state == OtaNotifState.failed
                  ? _dismiss
                  : null,
              child: _NotificationCard(
                pres: pres,
                config: widget.config,
                accent: accent,
                isDark: isDark,
                shimmerValue: _shimmerValue,
                colors: colors,
                onDismiss:
                    pres.autoDismiss ||
                        widget.config.state == OtaNotifState.failed
                    ? _dismiss
                    : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final _OtaStatePresentation pres;
  final OtaNotifConfig config;
  final Color accent;
  final bool isDark;
  final double shimmerValue;
  final AppColorTokenSet colors;
  final VoidCallback? onDismiss;

  const _NotificationCard({
    required this.pres,
    required this.config,
    required this.accent,
    required this.isDark,
    required this.shimmerValue,
    required this.colors,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? colors.backgroundsPrimaryElevated
            : colors.backgroundsPrimary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.45)
                : Colors.black.withValues(alpha: 0.10),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: accent.withValues(alpha: isDark ? 0.18 : 0.10),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _IconBubble(accent: accent, icon: pres.icon, isDark: isDark),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: AppText(
                        pres.title,
                        type: AppTextType.subheadline,
                        fontWeight: FontWeight.w600,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _DeviceChip(
                      label: config.device,
                      accent: accent,
                      isDark: isDark,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                AppText(
                  pres.message,
                  type: AppTextType.caption1,
                  color: AppTextColor.secondary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (pres.showProgress) ...[
                  const SizedBox(height: 10),
                  _ProgressTrack(
                    progress: config.progress,
                    accent: accent,
                    isDark: isDark,
                    isIndeterminate: pres.isIndeterminate,
                    shimmerValue: shimmerValue,
                    colors: colors,
                  ),
                ],
              ],
            ),
          ),
          if (onDismiss != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onDismiss,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.fillsTertiary,
                ),
                child: Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: colors.labelsSecondary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _IconBubble extends StatelessWidget {
  final Color accent;
  final IconData icon;
  final bool isDark;

  const _IconBubble({
    required this.accent,
    required this.icon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: accent.withValues(alpha: isDark ? 0.20 : 0.12),
      ),
      child: Icon(icon, color: accent, size: 22),
    );
  }
}

class _DeviceChip extends StatelessWidget {
  final String label;
  final Color accent;
  final bool isDark;

  const _DeviceChip({
    required this.label,
    required this.accent,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: isDark ? 0.18 : 0.10),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: accent,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _ProgressTrack extends StatelessWidget {
  final double? progress;
  final Color accent;
  final bool isDark;
  final bool isIndeterminate;
  final double shimmerValue;
  final AppColorTokenSet colors;

  const _ProgressTrack({
    required this.progress,
    required this.accent,
    required this.isDark,
    required this.isIndeterminate,
    required this.shimmerValue,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final trackWidth = constraints.maxWidth;

        return SizedBox(
          height: 4,
          child: Stack(
            children: [
              // Track background
              Container(
                width: trackWidth,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.fillsPrimary,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              if (isIndeterminate)
                _IndeterminateBar(
                  trackWidth: trackWidth,
                  accent: accent,
                  shimmerValue: shimmerValue,
                )
              else
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  width: trackWidth * (progress ?? 0).clamp(0.0, 1.0),
                  height: 4,
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _IndeterminateBar extends StatelessWidget {
  final double trackWidth;
  final Color accent;
  final double shimmerValue;

  const _IndeterminateBar({
    required this.trackWidth,
    required this.accent,
    required this.shimmerValue,
  });

  @override
  Widget build(BuildContext context) {
    const barFraction = 0.40;
    final barWidth = trackWidth * barFraction;

    // Single pass: 0→1 maps to bar going from -barWidth to trackWidth
    final offset = shimmerValue * (trackWidth + barWidth) - barWidth;

    return Positioned(
      left: offset,
      child: Container(
        width: barWidth,
        height: 4,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          gradient: LinearGradient(
            colors: [
              accent.withValues(alpha: 0),
              accent,
              accent.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
  }
}
