import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vac_dashboard_app/screens/deviceScreens.dart';
import 'package:vac_dashboard_app/screens/wifiScreens.dart';
import 'package:vac_dashboard_app/services/ble_service.dart';

void main() {
  group('WifiBottomSheet & DeviceScreen UI Migration Tests', () {
    tearDown(() {
      bleService.disconnectWifi();
    });

    testWidgets('DeviceScreen reflects Wi-Fi status reactively', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DeviceScreen(),
        ),
      );

      // Initially DISCONNECTED
      expect(find.text('Not Connected'), findsOneWidget);

      // Simulate incoming BLE message with CONNECTED status
      bleService.handleIncomingBytes([
        ...'{ "type": "wifi_status", "status": "CONNECTED", "ssid": "HomeWiFi" }'.codeUnits,
        0,
      ]);

      await tester.pump();

      expect(find.text('Connected'), findsOneWidget);
    });

    testWidgets('WifiBottomSheet displays connected UI when wifiStatus is CONNECTED', (WidgetTester tester) async {
      bleService.handleIncomingBytes([
        ...'{ "type": "wifi_status", "status": "CONNECTED", "ssid": "TestRouter" }'.codeUnits,
        0,
      ]);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WifiBottomSheet(),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Device Connected'), findsOneWidget);
      expect(find.text('Disconnect Wifi'), findsOneWidget);
    });

    testWidgets('WifiBottomSheet displays form UI when not connected', (WidgetTester tester) async {
      bleService.disconnectWifi();

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WifiBottomSheet(),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Wi-Fi Setup'), findsOneWidget);
      expect(find.text('Connect Wi-Fi'), findsNWidgets(2));
    });

    testWidgets('WifiBottomSheet transitions state reactively when onWifiStatusChanged emits', (WidgetTester tester) async {
      bleService.disconnectWifi();

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WifiBottomSheet(),
          ),
        ),
      );

      await tester.pump();

      // Form initially visible
      expect(find.text('Wi-Fi Setup'), findsOneWidget);

      // Simulate BLE stream emitting CONNECTED status
      bleService.handleIncomingBytes([
        ...'{ "type": "wifi_status", "status": "CONNECTED", "ssid": "OfficeNet" }'.codeUnits,
        0,
      ]);

      await tester.pumpAndSettle();

      expect(find.text('Device Connected'), findsOneWidget);
      expect(find.text('Your VAC device is online and synchronized via OfficeNet.'), findsOneWidget);
    });

    testWidgets('WifiBottomSheet transitions to form UI when DISCONNECTED status is emitted', (WidgetTester tester) async {
      bleService.handleIncomingBytes([
        ...'{ "type": "wifi_status", "status": "CONNECTED", "ssid": "OfficeNet" }'.codeUnits,
        0,
      ]);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WifiBottomSheet(),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Device Connected'), findsOneWidget);

      // Emit DISCONNECTED status
      bleService.handleIncomingBytes([
        ...'{ "type": "wifi_status", "status": "DISCONNECTED" }'.codeUnits,
        0,
      ]);

      await tester.pumpAndSettle();

      expect(find.text('Wi-Fi Setup'), findsOneWidget);
      expect(find.text('Device Connected'), findsNothing);
    });

    testWidgets('WifiBottomSheet displays error message when FAILED status is emitted', (WidgetTester tester) async {
      bleService.disconnectWifi();

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WifiBottomSheet(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Emit FAILED status
      bleService.handleIncomingBytes([
        ...'{ "type": "wifi_status", "status": "FAILED" }'.codeUnits,
        0,
      ]);

      await tester.pumpAndSettle();

      expect(find.text('Failed to connect to Wi-Fi. Please check credentials.'), findsOneWidget);
      expect(find.text('Wi-Fi Setup'), findsOneWidget);
    });
  });
}
