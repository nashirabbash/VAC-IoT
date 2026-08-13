import 'package:vac_dashboard_app/db/database_helper.dart';
import 'package:vac_dashboard_app/services/api_service.dart';
import 'package:vac_dashboard_app/services/log_service.dart';

class AuditSyncService {
  final ApiService _apiService;
  final DatabaseHelper _dbHelper;

  AuditSyncService({
    ApiService? apiService,
    DatabaseHelper? dbHelper,
  })  : _apiService = apiService ?? ApiService(),
        _dbHelper = dbHelper ?? DatabaseHelper.instance;

  static final AuditSyncService instance = AuditSyncService();

  Future<void> syncPendingAuditLogs() async {
    try {
      final unsynced = await _dbHelper.getUnsyncedAuditLogs();
      if (unsynced.isEmpty) return;

      LogService.log('[AUDIT SYNC] Syncing ${unsynced.length} pending audit log(s)...');
      final ids = unsynced.map((r) => r['id'] as int).toList();

      final payloads = unsynced.map((r) => {
        'userId': r['user_id'],
        'username': r['username'],
        'hospitalName': r['hospital_name'],
        'deviceId': r['device_id'],
        'action': r['action'],
        'details': r['details'],
        'timestamp': r['timestamp'],
      }).toList();

      await _apiService.postAuditLogs(payloads);
      await _dbHelper.markAuditLogsAsSynced(ids);
      LogService.log('[AUDIT SYNC] Successfully synced ${unsynced.length} audit log(s)');
    } catch (e) {
      LogService.log('[AUDIT SYNC] Sync error (will retry later): $e');
    }
  }
}
