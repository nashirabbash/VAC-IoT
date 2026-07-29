import 'package:vac_dashboard_app/models/therapy_session.dart';
import 'package:vac_dashboard_app/db/database_helper.dart';
import 'package:vac_dashboard_app/services/therapy_sync_service.dart';

class TherapyReceiver {
  /// Transforms a raw BLE [payload] from the ESP into the shape expected by
  /// both the local SQLite DB and the REST API, then persists to SQLite (offline-first)
  /// and automatically triggers background sync to BE when online.
  static Future<TherapySession> save(Map<String, dynamic> rawPayload) async {
    final converted = _transform(rawPayload);
    
    // Save to local SQLite first (offline-first)
    final id = await DatabaseHelper.instance.insert(converted, isSynced: false);
    
    // Attempt background sync to BE
    TherapySyncService.instance.syncPendingSessions();

    return TherapySession(
      id: id,
      sessionDate: converted['sessionDate'] as String,
      title: converted['title'] as String,
      date: converted['date'] as String,
      mode: converted['mode'] as String,
      duration: converted['duration'] as String,
    );
  }

  static Map<String, dynamic> _transform(Map<String, dynamic> raw) {
    final startSec = (raw['start'] as num?)?.toInt() ?? 0;
    final endSec = (raw['end'] as num?)?.toInt() ?? startSec;
    final modeInt = (raw['mode'] as num?)?.toInt() ?? 0;
    final pres = (raw['pres'] as num?)?.toInt() ?? 0;

    final startDt = startSec > 1000000000
        ? DateTime.fromMillisecondsSinceEpoch(startSec * 1000, isUtc: true).toLocal()
        : DateTime.now();
    final durationSec = (endSec - startSec).abs();

    return {
      'sessionDate': _toDateKey(startDt),
      'title': '${_modeLabel(modeInt)} $pres mmHg',
      'date': _toDisplayDate(startDt),
      'mode': _modeLabel(modeInt),
      'duration': _formatDuration(durationSec),
    };
  }

  /// "2026-07-29"
  static String _toDateKey(DateTime dt) =>
      '${dt.year}-${_pad(dt.month)}-${_pad(dt.day)}';

  /// "29 Jul, 09:08"
  static String _toDisplayDate(DateTime dt) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${dt.day} ${months[dt.month]}, ${_pad(dt.hour)}:${_pad(dt.minute)}';
  }

  /// 0 → "Kontinyu", 1 → "Intermiten"
  static String _modeLabel(int mode) =>
      mode == 0 ? 'Kontinyu' : 'Intermiten';

  /// 2700 sec → "45 min" ; 45 sec → "0 min"
  static String _formatDuration(int totalSec) {
    final minutes = totalSec ~/ 60;
    return '$minutes min';
  }

  static String _pad(int n) => n.toString().padLeft(2, '0');
}
