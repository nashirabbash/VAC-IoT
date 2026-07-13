import 'package:vac_dashboard_app/models/therapy_session.dart';
import 'package:vac_dashboard_app/services/api_service.dart';

class TherapyReceiver {
  static Future<TherapySession> save(Map<String, dynamic> payload) async {
    final session = await apiService.createSession(payload);
    return session;
  }
}