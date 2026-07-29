import 'dart:async';

import 'package:flutter/material.dart';
import 'package:vac_dashboard_app/component/ota_notification.dart';
import 'package:vac_dashboard_app/services/ble_service.dart';

/// Global singleton that wires BLE OTA events → [OtaNotificationOverlay].
///
/// Call [init] once with the app's [GlobalKey<NavigatorState>] before
/// any route is pushed. Then call [enable]/[disable] from screens that
/// should suppress the banner (WelcomeScreens, ScanScreen).
class OtaBannerService {
  OtaBannerService._();
  static final instance = OtaBannerService._();

  GlobalKey<NavigatorState>? _navigatorKey;
  StreamSubscription<Map<String, dynamic>>? _sub;
  bool _enabled = true;

  void init(GlobalKey<NavigatorState> key) {
    _navigatorKey = key;
    _sub?.cancel();
    _sub = bleService.onMessage
        .where(
          (m) => const {'ota_progress', 'ota_status', 'update_pending'}
              .contains(m['type']),
        )
        .listen(_onOtaMessage);
  }

  void enable() => _enabled = true;

  void disable() {
    _enabled = false;
    _dismissOverlay();
  }

  void _onOtaMessage(Map<String, dynamic> msg) {
    if (!_enabled) return;
    final overlay = _navigatorKey?.currentState?.overlay;
    if (overlay == null) return;
    final config = OtaNotifConfig.fromBleMessage(msg);
    OtaNotificationOverlay.showOnOverlay(overlay, config);
  }

  void _dismissOverlay() => OtaNotificationOverlay.dismiss();
}
