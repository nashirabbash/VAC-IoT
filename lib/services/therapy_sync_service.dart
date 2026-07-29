import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:vac_dashboard_app/db/database_helper.dart';
import 'package:vac_dashboard_app/services/api_service.dart';

class TherapySyncService {
  static final TherapySyncService instance = TherapySyncService._internal();
  TherapySyncService._internal();

  bool _isSyncing = false;

  /// Syncs all unsynced local SQLite therapy sessions to the backend API.
  /// Safe to call anytime (app startup, online event, background interval).
  Future<void> syncPendingSessions() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      final unsynced = await DatabaseHelper.instance.getUnsynced();
      if (unsynced.isEmpty) {
        _isSyncing = false;
        return;
      }

      debugPrint('Syncing ${unsynced.length} pending therapy sessions to BE...');

      for (final item in unsynced) {
        final id = item['id'] as int?;
        if (id == null) continue;

        final payload = {
          'sessionDate': item['session_date'],
          'title': item['title'],
          'date': item['date'],
          'mode': item['mode'],
          'duration': item['duration'],
        };

        try {
          await apiService.createSession(payload);
          await DatabaseHelper.instance.markAsSynced(id);
          debugPrint('Session #$id successfully synced to BE.');
        } catch (e) {
          debugPrint('Failed to sync session #$id to BE: $e');
          // Skip to next item if network/auth fails for this item
        }
      }
    } catch (e) {
      debugPrint('Error in syncPendingSessions: $e');
    } finally {
      _isSyncing = false;
    }
  }
}
