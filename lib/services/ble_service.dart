import 'dart:async';
import 'dart:convert';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BleService {
  static const _deviceName = 'VAC-STECHOQ';
  static const _serviceUuid = '4fafc201-1fb5-459e-8fcc-c5c9c331914b';
  static const _syncUuid = 'beb5483e-36e1-4688-b7f5-ea07361b26a8';
  static const _therapyUuid = '6e400003-b5a3-f393-e0a9-e50e24dcca9e';

  final _controller = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get onTherapy => _controller.stream;

  StreamSubscription? _scanSub;
  BluetoothDevice? _device;
  bool _connecting = false;
  int? _lastStart;

  Future<void> startScan() async {
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

    _scanSub?.cancel();
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
    _scanSub = FlutterBluePlus.scanResults.listen((results) {
      for (final r in results) {
        if (r.device.platformName == _deviceName && !_connecting) {
          FlutterBluePlus.stopScan();
          _connect(r.device);
          break;
        }
      }
    });

    // Retry scan if nothing found
    FlutterBluePlus.isScanning.where((s) => s == false).first.then((_) {
      if (_device == null)
        Future.delayed(const Duration(seconds: 3), startScan);
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
      Future.delayed(const Duration(seconds: 3), startScan);
      return;
    }
    _connecting = false;

    device.connectionState.listen((state) {
      if (state == BluetoothConnectionState.disconnected) {
        _device = null;
        _lastStart = null;
        Future.delayed(const Duration(seconds: 5), startScan);
      }
    });

    final services = await device.discoverServices();
    for (final svc in services) {
      if (svc.uuid.toString().toLowerCase() != _serviceUuid) continue;
      for (final char in svc.characteristics) {
        final uuid = char.uuid.toString().toLowerCase();
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

  void dispose() {
    _scanSub?.cancel();
    _device?.disconnect();
    _controller.close();
  }
}
