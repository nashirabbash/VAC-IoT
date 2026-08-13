import 'package:vac_dashboard_app/db/database_helper.dart';
import 'package:vac_dashboard_app/repositories/auth_repository.dart';
import 'package:vac_dashboard_app/services/log_service.dart';
import 'package:vac_dashboard_app/services/audit_sync_service.dart';

class AuditActions {
  static const String viewSession = 'VIEW_SESSION';
  static const String bindDevice = 'BIND_DEVICE';
  static const String exportReport = 'EXPORT_REPORT';
  static const String bleDisconnect = 'BLE_DISCONNECT';
}

class AuditService {
  final AuthRepository _authRepository;
  final DatabaseHelper _dbHelper;

  AuditService({
    AuthRepository? authRepository,
    DatabaseHelper? dbHelper,
  })  : _authRepository = authRepository ?? AuthRepository(),
        _dbHelper = dbHelper ?? DatabaseHelper.instance;

  static final AuditService instance = AuditService();

  Future<void> logAction({
    required String action,
    String? details,
    String? deviceId,
  }) async {
    try {
      final creds = await _authRepository.getDeviceCredentials();
      final targetDeviceId = deviceId ?? creds?.deviceId;
      final timestamp = DateTime.now().toUtc().toIso8601String();

      final row = {
        'userId': null,
        'username': null,
        'hospitalName': null,
        'deviceId': targetDeviceId,
        'action': action,
        'details': details,
        'timestamp': timestamp,
        'isSynced': false,
      };

      await _dbHelper.insertAuditLog(row);
      LogService.log('[AUDIT] Action logged: $action (device: $targetDeviceId)');

      // Attempt background sync
      AuditSyncService.instance.syncPendingAuditLogs().catchError((_) {});
    } catch (e) {
      LogService.log('[AUDIT] Failed to record audit log: $e');
    }
  }
}
