import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vac_dashboard_app/services/heartbeat_alarm_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HeartbeatAlarmService Unit Tests', () {
    test('singleton instance exists', () {
      expect(HeartbeatAlarmService.instance, isNotNull);
    });

    testWidgets('init registers navigator key without throwing', (tester) async {
      final navKey = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navKey,
          home: const Scaffold(body: Text('Test')),
        ),
      );

      expect(() => HeartbeatAlarmService.instance.init(navKey), returnsNormally);
    });

    test('enable and disable methods update state without throwing', () {
      expect(() => HeartbeatAlarmService.instance.disable(), returnsNormally);
      expect(() => HeartbeatAlarmService.instance.enable(), returnsNormally);
    });
  });
}
