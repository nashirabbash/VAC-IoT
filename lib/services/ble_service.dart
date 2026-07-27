import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:vac_dashboard_app/repositories/auth_repository.dart';

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

  void _updateConnectionState(bool connected) {
    if (_isConnected != connected) {
      _isConnected = connected;
      _connectionStateController.add(connected);
    }
  }

  Future<void> startScan({bool force = false}) async {
    if (isExplicitlyDisconnected && !force) return;
    if (force) {
      isExplicitlyDisconnected = false;
    }
    _shouldAutoReconnect = true;
    final creds = await _authRepository.getDeviceCredentials();
    if (creds == null) return;
    final deviceId = creds.deviceId;

    if (await FlutterBluePlus.isSupported == false) return;

    // Wait for BT adapter to be on
    await FlutterBluePlus.adapterState
        .where((s) => s == BluetoothAdapterState.on)
        .first
        .timeout(
          const Duration(seconds: 10),
          onTimeout: () => BluetoothAdapterState.off,
        );

    if (await FlutterBluePlus.adapterState.first != BluetoothAdapterState.on) {
      return;
    }

    _updateConnectionState(false);
    _scanSub?.cancel();
    _isScanningSub?.cancel();

    // Filter scan by our specific Service UUID for reliability
    await FlutterBluePlus.startScan(
      withServices: [Guid(_serviceUuid)],
      timeout: const Duration(seconds: 15),
    );

    _scanSub = FlutterBluePlus.scanResults.listen((results) {
      for (final r in results) {
        final name = r.device.platformName.isNotEmpty
            ? r.device.platformName
            : r.advertisementData.advName;
        if (name == deviceId && !_connecting) {
          FlutterBluePlus.stopScan();
          _connect(r.device);
          break;
        }
      }
    });

    // Retry scan if nothing found
    _isScanningSub = FlutterBluePlus.isScanning.listen((isScanning) {
      if (!isScanning && _device == null && !_connecting) {
        Future.delayed(const Duration(seconds: 3), () {
          if (_device == null && !_connecting) startScan();
        });
      }
    });
  }

  Future<void> _connect(BluetoothDevice device) async {
    _connecting = true;
    _device = device;
    try {
      await device.connect(
        autoConnect: false,
        timeout: const Duration(seconds: 10),
      );
    } catch (_) {
      _connecting = false;
      _device = null;
      _updateConnectionState(false);
      Future.delayed(const Duration(seconds: 3), startScan);
      return;
    }
    _connecting = false;
    _updateConnectionState(true);

    device.connectionState.listen((state) {
      if (state == BluetoothConnectionState.disconnected) {
        _device = null;
        _rxChar = null;
        _txChar = null;
        _txCharSub?.cancel();
        _lastStart = null;
        _updateConnectionState(false);
        // Auto reconnect silently only if not explicitly disconnected by user
        if (_shouldAutoReconnect) {
          Future.delayed(const Duration(seconds: 5), startScan);
        }
      }
    });

    final creds = await _authRepository.getDeviceCredentials();
    final authPin = creds?.authPin;

    final services = await device.discoverServices();
    for (final svc in services) {
      if (svc.uuid.toString().toLowerCase() != _serviceUuid) continue;

      for (final char in svc.characteristics) {
        final uuid = char.uuid.toString().toLowerCase();
        if (uuid == _rxUuid) {
          _rxChar = char;
        } else if (uuid == _txUuid) {
          _txChar = char;
        }
      }

      // Listen to _txChar.onValueReceived FIRST before sending commands
      if (_txChar != null) {
        try {
          await _txChar!.setNotifyValue(true);
          _txCharSub?.cancel();
          _txCharSub = _txChar!.onValueReceived.listen(handleIncomingBytes);
        } catch (_) {}
      }

      // Automatically send authentication JSON command if authPin exists
      if (authPin != null && authPin.isNotEmpty) {
        await send('auth', {'pin': authPin});
      }

      // Time sync
      final ts = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      await send('time_sync', {'timestamp': ts});

      break;
    }
  }

  Future<bool> send(String type, [Map<String, dynamic>? payload]) async {
    if (_rxChar == null) return false;
    final map = <String, dynamic>{
      ...?payload,
      'type': type,
    };
    final jsonString = jsonEncode(map);
    try {
      await _rxChar!.write(utf8.encode(jsonString), withoutResponse: false);
      return true;
    } catch (_) {
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
    try {
      final str = cleanBleString(bytes);
      if (str.isEmpty) return;
      final data = jsonDecode(str);
      if (data is Map<String, dynamic>) {
        if (data['type'] == 'wifi_status' || data.containsKey('status')) {
          final statusStr = data['status']?.toString();
          if (statusStr != null) {
            _wifiStatus = statusStr;
            _wifiStatusController.add(statusStr);
          }
          if (data['ssid'] != null) {
            _connectedSsid = data['ssid']?.toString();
          }
        }
        _messageController.add(data);
      }
    } catch (_) {}
  }

  Future<String> readWifiStatus() async {
    await send('get_status');
    return _wifiStatus;
  }

  Future<bool> sendWifiConfig(String ssid, String password) async {
    _connectedSsid = ssid;
    return send('wifi_config', {'ssid': ssid, 'password': password});
  }

  Future<bool> disconnectWifi() async {
    _connectedSsid = null;
    _wifiStatus = 'DISCONNECTED';
    _wifiStatusController.add('DISCONNECTED');
    return send('wifi_disconnect');
  }

  Stream<Map<String, dynamic>> get onTherapy {
    return onMessage.where((msg) {
      final type = msg['type'] as String?;
      final start = msg['start'] as int?;
      if (type == 'therapy_event' || type == 'therapy' || start != null) {
        if (start != null) {
          if (start == _lastStart) return false;
          _lastStart = start;
        }
        return true;
      }
      return false;
    });
  }

  void disconnect() {
    _shouldAutoReconnect = false;
    isExplicitlyDisconnected = true;
    _device?.disconnect();
  }

  void dispose() {
    _scanSub?.cancel();
    _isScanningSub?.cancel();
    _txCharSub?.cancel();
    _device?.disconnect();
    _messageController.close();
    _connectionStateController.close();
    _wifiStatusController.close();
  }
}

final bleService = BleService();
