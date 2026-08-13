import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vac_dashboard_app/component/heartbeat_notification.dart';
import 'package:vac_dashboard_app/services/ble_service.dart';

/// Singleton service connecting [BleService] heartbeat timeout events
/// to the global [HeartbeatNotificationOverlay] banner and audio alert.
class HeartbeatAlarmService {
  HeartbeatAlarmService._();
  static final instance = HeartbeatAlarmService._();

  GlobalKey<NavigatorState>? _navigatorKey;
  StreamSubscription<bool>? _sub;
  Timer? _audioTimer;
  bool _enabled = true;

  void init(GlobalKey<NavigatorState> key) {
    _navigatorKey = key;
    _sub?.cancel();
    _sub = bleService.onHeartbeatTimeout.listen(_onHeartbeatTimeout);
  }

  void enable() => _enabled = true;

  void disable() {
    _enabled = false;
    _dismissAlarm();
  }

  void _onHeartbeatTimeout(bool isTimeout) {
    if (!_enabled) return;
    if (isTimeout) {
      _showAlarm();
    } else {
      _dismissAlarm();
    }
  }

  void _showAlarm() {
    final overlay = _navigatorKey?.currentState?.overlay;
    if (overlay != null) {
      HeartbeatNotificationOverlay.showOnOverlay(overlay);
    }
    _startAudioWarning();
  }

  void _dismissAlarm() {
    HeartbeatNotificationOverlay.dismiss();
    _stopAudioWarning();
  }

  // ponytail: SystemSound.play() used for audio warning -> upgrade to audioplayers package for custom siren audio file.
  void _startAudioWarning() {
    _stopAudioWarning();
    SystemSound.play(SystemSoundType.alert);
    _audioTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      SystemSound.play(SystemSoundType.alert);
    });
  }

  void _stopAudioWarning() {
    _audioTimer?.cancel();
    _audioTimer = null;
  }
}
