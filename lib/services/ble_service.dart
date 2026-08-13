import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:vac_dashboard_app/models/therapy_session.dart';
import 'package:vac_dashboard_app/repositories/auth_repository.dart';
import 'package:vac_dashboard_app/services/therapy_receiver.dart';
import 'package:vac_dashboard_app/services/log_service.dart';

class BleService {
  static const _serviceUuid = '4fafc201-1fb5-459e-8fcc-c5c9c331914b';
  static const _rxUuid = 'c083b0f6-bb21-4f15-8120-d4f13b28b7e2';
  static const _txUuid = '6e400003-b5a3-f393-e0a9-e50e24dcca9e';

  final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get onMessage => _messageController.stream;

  final _connectionStateController = StreamController<bool>.broadcast();
  Stream<bool> get onConnectionStateChanged => _connectionStateController.stream;

  final _wifiStatusController = StreamController<String>.broadcast();
  Stream<String> get onWifiStatusChanged => _wifiStatusController.stream;

  final _heartbeatTimeoutController = StreamController<bool>.broadcast();
  Stream<bool> get onHeartbeatTimeout => _heartbeatTimeoutController.stream;

  DateTime? _lastPacketTime;
  DateTime? get lastPacketTime => _lastPacketTime;
  Timer? _heartbeatTimer;
  bool _isHeartbeatTimeout = false;
  bool get isHeartbeatTimeout => _isHeartbeatTimeout;

  BluetoothCharacteristic? _rxChar;
  BluetoothCharacteristic? _txChar;
  StreamSubscription? _txCharSub;

  String _wifiStatus = 'DISCONNECTED';
  String get wifiStatus => _wifiStatus;
  String? _connectedSsid;
  String? get connectedSsid => _connectedSsid;

  StreamSubscription? _scanSub;
  StreamSubscription? _isScanningSub;
  BluetoothDevice? _device;

  bool _connecting = false;
  int? _lastStart;
  bool _isConnected = false;
  bool _shouldAutoReconnect = true;
  bool isExplicitlyDisconnected = false;

  final AuthRepository _authRepository;

  BleService({AuthRepository? authRepository}) : _authRepository = authRepository ?? AuthRepository();

  bool get isConnected => _isConnected;

  // Request BT permissions and turn on adapter.
  // Call once at app startup (before runApp) so the system dialog appears
  // during the native splash, not during QR scan.
  static Future<void> initBluetooth() async {
    if (await FlutterBluePlus.isSupported == false) return;

    // flutter_blue_plus triggers the OS permission dialog automatically on
    // first adapter state access on Android 12+ / iOS.
    final state = await FlutterBluePlus.adapterState.first;
    if (state != BluetoothAdapterState.on) {
      try {
        await FlutterBluePlus.turnOn();
      } catch (_) {
        // User declined or platform doesn't support turnOn (iOS) — fine.
      }
    }
  }

  void _updateConnectionState(bool connected) {
    if (_isConnected != connected) {
      _isConnected = connected;
      LogService.log('[BLE] Connection state changed: connected=$connected');
      _connectionStateController.add(connected);
      if (connected) {
        _lastPacketTime = DateTime.now();
        _isHeartbeatTimeout = false;
        _startHeartbeatTimer();
      } else {
        _stopHeartbeatTimer();
        _lastPacketTime = null;
        if (_isHeartbeatTimeout) {
          _isHeartbeatTimeout = false;
          _heartbeatTimeoutController.add(false);
        }
      }
    }
  }

  void _startHeartbeatTimer() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (!_isConnected || _lastPacketTime == null) return;
      final elapsedSeconds = DateTime.now().difference(_lastPacketTime!).inSeconds;
      if (elapsedSeconds >= 5 && !_isHeartbeatTimeout) {
        _isHeartbeatTimeout = true;
        LogService.log('[BLE] Heartbeat timeout detected! ($elapsedSeconds s silence)');
        _heartbeatTimeoutController.add(true);
      }
    });
  }

  void _stopHeartbeatTimer() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  Future<void> startScan({bool force = false}) async {
    LogService.log('[BLE] startScan requested (force: $force, isConnected: $isConnected, isExplicitlyDisconnected: $isExplicitlyDisconnected)');
    if (isConnected && !force) return;
    if (isExplicitlyDisconnected && !force) return;
    if (force) {
      isExplicitlyDisconnected = false;
    }
    _shouldAutoReconnect = true;
    final creds = await _authRepository.getDeviceCredentials();
    if (creds == null) {
      LogService.log('[BLE] startScan aborted: no device credentials saved');
      return;
    }
    final deviceId = creds.deviceId;

    if (await FlutterBluePlus.isSupported == false) {
      LogService.log('[BLE] FlutterBluePlus is not supported');
      return;
    }

    // Wait for BT adapter to be on
    await FlutterBluePlus.adapterState
        .where((s) => s == BluetoothAdapterState.on)
        .first
        .timeout(
          const Duration(seconds: 10),
          onTimeout: () => BluetoothAdapterState.off,
        );

    if (await FlutterBluePlus.adapterState.first != BluetoothAdapterState.on) {
      LogService.log('[BLE] startScan aborted: Bluetooth adapter is OFF');
      return;
    }

    if (!isConnected) {
      _updateConnectionState(false);
    }
    _scanSub?.cancel();
    _isScanningSub?.cancel();

    LogService.log('[BLE] Scanning for deviceId: $deviceId');
    _scanSub = FlutterBluePlus.scanResults.listen((results) {
      for (final r in results) {
        final name = r.device.platformName.isNotEmpty
            ? r.device.platformName
            : r.advertisementData.advName;
        if (name == deviceId && !_connecting && !isConnected) {
          LogService.log('[BLE] Found matching device: $name (${r.device.remoteId}). Connecting...');
          FlutterBluePlus.stopScan();
          _connect(r.device);
          break;
        }
      }
    });

    // Retry scan if nothing found
    _isScanningSub = FlutterBluePlus.isScanning.listen((isScanning) {
      LogService.log('[BLE] isScanning status: $isScanning');
      if (!isScanning && _device == null && !_connecting && !isConnected) {
        Future.delayed(const Duration(seconds: 3), () {
          if (_device == null && !_connecting && !isConnected) startScan();
        });
      }
    });

    try {
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 15),
      );
    } catch (e) {
      LogService.log('[BLE] startScan error: $e');
    }
  }

  Future<void> _connect(BluetoothDevice device) async {
    _connecting = true;
    _device = device;
    LogService.log('[BLE] Attempting connection to device ${device.remoteId} (${device.platformName})');
    try {
      await device.connect(
        autoConnect: false,
        timeout: const Duration(seconds: 10),
      );
    } catch (e) {
      LogService.log('[BLE] Connection failed with error: $e');
      _connecting = false;
      _device = null;
      _updateConnectionState(false);
      Future.delayed(const Duration(seconds: 3), startScan);
      return;
    }
    _connecting = false;
    LogService.log('[BLE] Connection established with ${device.remoteId}');
    _updateConnectionState(true);
    _startRssiMonitoring(device);

    device.connectionState.listen((state) {
      LogService.log('[BLE] Device raw connection state event: $state for ${device.remoteId}');
      if (state == BluetoothConnectionState.disconnected) {
        LogService.log('[BLE] Disconnected from device (explicit: $isExplicitlyDisconnected, autoReconnect: $_shouldAutoReconnect)');
        _stopRssiMonitoring();
        _device = null;
        _rxChar = null;
        _txChar = null;
        _txCharSub?.cancel();
        _lastStart = null;
        _updateConnectionState(false);
        // Auto reconnect silently only if not explicitly disconnected by user
        if (_shouldAutoReconnect) {
          LogService.log('[BLE] Scheduling auto-reconnect scan in 5s');
          Future.delayed(const Duration(seconds: 5), startScan);
        }
      }
    });

    final creds = await _authRepository.getDeviceCredentials();
    final authPin = creds?.authPin;

    LogService.log('[BLE] Discovering services...');
    final services = await device.discoverServices();
    for (final svc in services) {
      if (svc.uuid.toString().toLowerCase() != _serviceUuid) continue;

      LogService.log('[BLE] Matching target service found: ${svc.uuid}');
      for (final char in svc.characteristics) {
        final uuid = char.uuid.toString().toLowerCase();
        if (uuid == _rxUuid) {
          _rxChar = char;
          LogService.log('[BLE] RX Characteristic bound: $uuid');
        } else if (uuid == _txUuid) {
          _txChar = char;
          LogService.log('[BLE] TX Characteristic bound: $uuid');
        }
      }

      // Listen to _txChar.onValueReceived FIRST before sending commands
      if (_txChar != null) {
        try {
          await _txChar!.setNotifyValue(true);
          _txCharSub?.cancel();
          _txCharSub = _txChar!.onValueReceived.listen(handleIncomingBytes);
          LogService.log('[BLE] TX Notify enabled successfully');
        } catch (e) {
          LogService.log('[BLE] Error enabling TX notify: $e');
        }
      }

      // Automatically send authentication JSON command if authPin exists
      if (authPin != null && authPin.isNotEmpty) {
        LogService.log('[BLE] Sending auth pin...');
        await send('auth', {'pin': authPin});
      }

      // Time sync
      final ts = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      LogService.log('[BLE] Sending time_sync ($ts)...');
      await send('time_sync', {'timestamp': ts});

      break;
    }
  }

  Future<bool> send(String type, [Map<String, dynamic>? payload]) async {
    if (_rxChar == null) {
      LogService.log('[BLE] send failed: _rxChar is null (type=$type)');
      return false;
    }
    final map = <String, dynamic>{
      ...?payload,
      'type': type,
    };
    final jsonString = jsonEncode(map);
    LogService.log('[BLE] Sending GATT payload: $jsonString');
    try {
      final withoutResp = _rxChar!.properties.writeWithoutResponse;
      await _rxChar!.write(utf8.encode(jsonString), withoutResponse: withoutResp);
      LogService.log('[BLE] GATT payload sent successfully (type=$type, withoutResponse=$withoutResp)');
      return true;
    } catch (e) {
      LogService.log('[BLE] send GATT write exception: $e (type=$type)');
      return false;
    }
  }

  @visibleForTesting
  static String cleanBleString(List<int> bytes) {
    if (bytes.isEmpty) return '';
    final raw = utf8.decode(bytes, allowMalformed: true);
    return raw.replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F-\x9F]'), '').trim();
  }

  @visibleForTesting
  void handleIncomingBytes(List<int> bytes) {
    if (bytes.isEmpty) return;
    _lastPacketTime = DateTime.now();
    if (_isHeartbeatTimeout) {
      _isHeartbeatTimeout = false;
      LogService.log('[BLE] Heartbeat packet received, clearing timeout');
      _heartbeatTimeoutController.add(false);
    }
    try {
      final str = cleanBleString(bytes);
      if (str.isEmpty) return;
      LogService.log('[BLE] Incoming GATT data: $str');
      final data = jsonDecode(str);
      if (data is Map<String, dynamic>) {
        if (data['type'] == 'wifi_status' || data.containsKey('status')) {
          final statusStr = data['status']?.toString();
          if (statusStr != null) {
            _wifiStatus = statusStr;
            LogService.log('[BLE] Updated wifiStatus to: $_wifiStatus');
            _wifiStatusController.add(statusStr);
          }
          if (data['ssid'] != null) {
            _connectedSsid = data['ssid']?.toString();
            LogService.log('[BLE] Updated connectedSsid to: $_connectedSsid');
          }
        }
        final type = data['type'] as String?;
        final start = (data['start'] as num?)?.toInt();
        if (type == 'therapy_event' || type == 'therapy' || start != null) {
          if (start != null && start != _lastStart) {
            _lastStart = start;
            TherapyReceiver.save(data).catchError((e) {
              LogService.log('[BLE] Global therapy receiver save error: $e');
              return const TherapySession(
                sessionDate: '',
                title: '',
                date: '',
                mode: '',
                duration: '',
              );
            });
          }
        }
        _messageController.add(data);
      }
    } catch (e) {
      LogService.log('[BLE] handleIncomingBytes decode error: $e');
    }
  }

  Future<String> readWifiStatus() async {
    LogService.log('[BLE] readWifiStatus requested');
    await send('get_status');
    return _wifiStatus;
  }

  Future<bool> sendWifiConfig(String ssid, String password) async {
    LogService.log('[BLE] sendWifiConfig requested for SSID: $ssid');
    _connectedSsid = ssid;
    return send('wifi_config', {'ssid': ssid, 'password': password});
  }

  Future<bool> disconnectWifi() async {
    LogService.log('[BLE] disconnectWifi requested');
    _connectedSsid = null;
    _wifiStatus = 'DISCONNECTED';
    _wifiStatusController.add('DISCONNECTED');
    return send('wifi_disconnect');
  }

  Stream<Map<String, dynamic>> get onTherapy {
    return onMessage.where((msg) {
      final type = msg['type'] as String?;
      final start = (msg['start'] as num?)?.toInt();
      return type == 'therapy_event' || type == 'therapy' || start != null;
    });
  }

  // ponytail: Relying on native BLE link supervision timeout for out-of-range disconnects to prevent GATT 133 collisions.
  void _startRssiMonitoring(BluetoothDevice device) {}

  void _stopRssiMonitoring() {}

  void disconnect() {
    LogService.log('[BLE] Explicit disconnect requested');
    _stopRssiMonitoring();
    _shouldAutoReconnect = false;
    isExplicitlyDisconnected = true;
    _device?.disconnect();
  }

  /// Call after login so the next startScan() is not blocked
  /// by the isExplicitlyDisconnected guard set during logout.
  void resetForNewSession() {
    LogService.log('[BLE] Resetting BLE state for new session');
    isExplicitlyDisconnected = false;
    _shouldAutoReconnect = true;
  }

  void dispose() {
    LogService.log('[BLE] Disposing BleService');
    _stopHeartbeatTimer();
    _stopRssiMonitoring();
    _scanSub?.cancel();
    _isScanningSub?.cancel();
    _txCharSub?.cancel();
    _device?.disconnect();
    _messageController.close();
    _connectionStateController.close();
    _wifiStatusController.close();
    _heartbeatTimeoutController.close();
  }
}

final bleService = BleService();
