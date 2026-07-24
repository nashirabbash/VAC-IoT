import 'dart:async';
import 'dart:convert';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:vac_dashboard_app/repositories/auth_repository.dart';

class BleService {
  static const _serviceUuid = '4fafc201-1fb5-459e-8fcc-c5c9c331914b';
  static const _syncUuid = 'beb5483e-36e1-4688-b7f5-ea07361b26a8';
  static const _therapyUuid = '6e400003-b5a3-f393-e0a9-e50e24dcca9e';
  static const _authUuid = '8f4c0228-4447-4cf0-8a7c-dc9f4007f35a';

  final _controller = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get onTherapy => _controller.stream;

  final _connectionStateController = StreamController<bool>.broadcast();
  Stream<bool> get onConnectionStateChanged => _connectionStateController.stream;

  StreamSubscription? _scanSub;
  StreamSubscription? _isScanningSub;
  BluetoothDevice? _device;
  bool _connecting = false;
  int? _lastStart;
  bool _isConnected = false;

  final AuthRepository _authRepository;

  BleService({AuthRepository? authRepository}) : _authRepository = authRepository ?? AuthRepository();

  bool get isConnected => _isConnected;

  void _updateConnectionState(bool connected) {
    if (_isConnected != connected) {
      _isConnected = connected;
      _connectionStateController.add(connected);
    }
  }

  Future<void> startScan() async {
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

    if (await FlutterBluePlus.adapterState.first != BluetoothAdapterState.on)
      return;

    _updateConnectionState(false);
    _scanSub?.cancel();
    _isScanningSub?.cancel();
    
    // Filter scan by device name
    await FlutterBluePlus.startScan(
      withNames: [deviceId],
      timeout: const Duration(seconds: 15)
    );
    
    _scanSub = FlutterBluePlus.scanResults.listen((results) {
      for (final r in results) {
        if (r.device.platformName == deviceId && !_connecting) {
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
        _lastStart = null;
        _updateConnectionState(false);
        // Auto reconnect silently
        Future.delayed(const Duration(seconds: 5), startScan);
      }
    });

    final creds = await _authRepository.getDeviceCredentials();
    final authPin = creds?.authPin;

    final services = await device.discoverServices();
    for (final svc in services) {
      if (svc.uuid.toString().toLowerCase() != _serviceUuid) continue;
      for (final char in svc.characteristics) {
        final uuid = char.uuid.toString().toLowerCase();
        
        if (uuid == _authUuid && authPin != null) {
          // Priority 1: Write AUTH_PIN within the 5s window
          await char.write(utf8.encode(authPin), withoutResponse: false);
        }

        if (uuid == _syncUuid) {
          // Write current Unix timestamp so ESP32 knows real time
          final ts = DateTime.now().millisecondsSinceEpoch ~/ 1000;
          await char.write(utf8.encode(ts.toString()), withoutResponse: false);
        }
        
        if (uuid == _therapyUuid) {
          await char.setNotifyValue(true);
          char.lastValueStream.listen((bytes) {
            if (bytes.isEmpty) return;
            try {
              final data =
                  jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
              final start = data['start'] as int?;
              if (start == null) return;
              if (start == _lastStart) return;
              _lastStart = start;
              _controller.add(data);
            } catch (_) {}
          });
        }
      }
      break;
    }
  }

  void disconnect() {
    _device?.disconnect();
  }

  void dispose() {
    _scanSub?.cancel();
    _isScanningSub?.cancel();
    _device?.disconnect();
    _controller.close();
    _connectionStateController.close();
  }
}

final bleService = BleService();
