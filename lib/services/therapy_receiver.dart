import 'package:vac_dashboard_app/models/therapy_session.dart';
import 'package:vac_dashboard_app/services/api_service.dart';
import 'package:vac_dashboard_app/db/database_helper.dart';

class TherapyReceiver {
  static Future<TherapySession> save(Map<String, dynamic> payload) async {
    await DatabaseHelper.instance.insert(payload);
    final session = await apiService.createSession(payload);
    return session;
  }
}
