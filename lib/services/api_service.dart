import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vac_dashboard_app/models/therapy_session.dart';
import 'package:vac_dashboard_app/network/api_interceptor.dart';

class ApiService {
  static const _baseUrl = 'http://192.168.1.35:3000/api';

  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? ApiInterceptor();

  Future<List<TherapySession>> getSessions({String? year}) async {
    final uri = Uri.parse('$_baseUrl/therapy-sessions').replace(
      queryParameters: year != null ? {'year': year} : null,
    );
    final res = await _client.get(uri);
    if (res.statusCode != 200) throw Exception('Failed to load sessions');
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final list = (body['data'] as List).cast<Map<String, dynamic>>();
    return list.map((m) => TherapySession.fromJson(m)).toList();
  }

  Future<TherapySession> createSession(Map<String, dynamic> payload) async {
    final uri = Uri.parse('$_baseUrl/therapy-sessions');
    final res = await _client.post(uri, body: jsonEncode(payload), headers: {
      'Content-Type': 'application/json',
    });
    if (res.statusCode != 200) throw Exception('Failed to save session');
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    return TherapySession.fromJson(body['data'] as Map<String, dynamic>);
  }
}

final apiService = ApiService();