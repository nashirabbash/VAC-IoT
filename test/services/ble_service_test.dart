import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:vac_dashboard_app/services/ble_service.dart';

void main() {
  group('BleService Unit Tests', () {
    late BleService service;

    setUp(() {
      service = BleService();
    });

    tearDown(() {
      service.dispose();
    });

    test('onMessage stream exists and accepts subscriptions', () async {
      expect(service.onMessage, isNotNull);
      expect(service.onMessage.isBroadcast, isTrue);
    });

    test('send returns false when not connected to _rxChar', () async {
      final res = await service.send('auth', {'pin': '123456'});
      expect(res, isFalse);
    });

    test('sendWifiConfig returns false when not connected', () async {
      final res = await service.sendWifiConfig('TestSSID', 'password');
      expect(res, isFalse);
    });

    test('disconnectWifi sets wifiStatus to DISCONNECTED', () async {
      final res = await service.disconnectWifi();
      expect(res, isFalse); // Not connected to RX char
      expect(service.wifiStatus, 'DISCONNECTED');
    });

    test('onTherapy returns a broadcast stream', () {
      expect(service.onTherapy, isNotNull);
      expect(service.onTherapy.isBroadcast, isTrue);
    });

    group('String cleaning & JSON parsing', () {
      test('cleanBleString strips null bytes \\x00 and control characters', () {
        final bytes = utf8.encode('hello\x00world\x01\x02\x7F');
        final result = BleService.cleanBleString(bytes);
        expect(result, 'helloworld');
      });

      test('cleanBleString preserves valid JSON whitespace (\\t, \\n, \\r)', () {
        final raw = '{\n\t"key": "value",\r\n"status": "OK"\n}\x00';
        final bytes = utf8.encode(raw);
        final result = BleService.cleanBleString(bytes);
        expect(result, '{\n\t"key": "value",\r\n"status": "OK"\n}');
        final decoded = jsonDecode(result);
        expect(decoded['key'], 'value');
        expect(decoded['status'], 'OK');
      });
    });

    group('handleIncomingBytes & stream emissions', () {
      test('emits parsed JSON to onMessage stream including null byte payloads', () async {
        final rawJson = '{"type": "status_update", "battery": 85}\x00\x00';
        final bytes = utf8.encode(rawJson);

        expectLater(
          service.onMessage,
          emits({'type': 'status_update', 'battery': 85}),
        );

        service.handleIncomingBytes(bytes);
      });

      test('updates wifiStatus and emits to onWifiStatusChanged on status packet', () async {
        final rawJson = '{"type": "wifi_status", "status": "CONNECTED", "ssid": "MyWiFi"}\x00';
        final bytes = utf8.encode(rawJson);

        expectLater(service.onWifiStatusChanged, emits('CONNECTED'));

        service.handleIncomingBytes(bytes);

        await Future.delayed(Duration.zero);
        expect(service.wifiStatus, 'CONNECTED');
        expect(service.connectedSsid, 'MyWiFi');
      });

      test('emits therapy events to onTherapy stream', () async {
        final rawJson = '{"type": "therapy_event", "start": 1700000000, "duration": 300}';
        final bytes = utf8.encode(rawJson);

        expectLater(
          service.onTherapy,
          emits({'type': 'therapy_event', 'start': 1700000000, 'duration': 300}),
        );

        service.handleIncomingBytes(bytes);
      });

      test('ignores empty or malformed bytes gracefully', () async {
        bool emitted = false;
        final sub = service.onMessage.listen((_) => emitted = true);

        service.handleIncomingBytes([]);
        service.handleIncomingBytes(utf8.encode('\x00\x00'));
        service.handleIncomingBytes(utf8.encode('{invalid_json'));

        await Future.delayed(const Duration(milliseconds: 10));
        expect(emitted, isFalse);
        await sub.cancel();
      });
    });

    group('Heartbeat Liveness & Disconnection Safety', () {
      test('onHeartbeatTimeout stream exists and is broadcast', () {
        expect(service.onHeartbeatTimeout, isNotNull);
        expect(service.onHeartbeatTimeout.isBroadcast, isTrue);
        expect(service.isHeartbeatTimeout, isFalse);
      });

      test('handleIncomingBytes updates lastPacketTime', () {
        expect(service.lastPacketTime, isNull);
        service.handleIncomingBytes(utf8.encode('{"type":"ping"}'));
        expect(service.lastPacketTime, isNotNull);
      });

      test('clears heartbeatTimeout when incoming bytes are received', () async {
        service.handleIncomingBytes(utf8.encode('{"type":"telemetry"}'));
        expect(service.isHeartbeatTimeout, isFalse);

        // Simulate incoming byte clearing existing timeout
        service.handleIncomingBytes(utf8.encode('{"type":"ping"}'));
        expect(service.isHeartbeatTimeout, isFalse);
      });
    });
  });
}

