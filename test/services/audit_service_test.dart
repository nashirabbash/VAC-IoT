import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vac_dashboard_app/db/database_helper.dart';
import 'package:vac_dashboard_app/services/audit_service.dart';
import 'package:vac_dashboard_app/services/audit_sync_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuditService & AuditSyncService Unit Tests', () {
    late DatabaseHelper dbHelper;

    setUp(() {
      FlutterSecureStorage.setMockInitialValues({});
      dbHelper = DatabaseHelper.withStorage(const FlutterSecureStorage());
    });

    test('AuditActions constants are defined correctly', () {
      expect(AuditActions.viewSession, 'VIEW_SESSION');
      expect(AuditActions.bindDevice, 'BIND_DEVICE');
      expect(AuditActions.exportReport, 'EXPORT_REPORT');
      expect(AuditActions.bleDisconnect, 'BLE_DISCONNECT');
    });

    test('AuditService singleton instance exists', () {
      expect(AuditService.instance, isNotNull);
    });

    test('AuditSyncService singleton instance exists', () {
      expect(AuditSyncService.instance, isNotNull);
    });
  });
}
