import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vac_dashboard_app/models/therapy_session.dart';
import 'package:vac_dashboard_app/network/api_interceptor.dart';
import 'package:vac_dashboard_app/repositories/auth_repository.dart';

class ApiService {
  static const _baseUrl = 'http://192.168.1.35:3000/api';

  final http.Client _client;

  ApiService({http.Client? client})
    : _client = client ?? ApiInterceptor(authRepository: AuthRepository());

  Future<List<TherapySession>> getSessions({String? year}) async {
    final uri = Uri.parse(
      '$_baseUrl/therapy-sessions',
    ).replace(queryParameters: year != null ? {'year': year} : null);
    final res = await _client.get(uri);
    if (res.statusCode != 200) throw Exception('Failed to load sessions');
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final list = (body['data'] as List).cast<Map<String, dynamic>>();
    return list.map((m) => TherapySession.fromJson(m)).toList();
  }

  Future<TherapySession> createSession(Map<String, dynamic> payload) async {
    final uri = Uri.parse('$_baseUrl/therapy-sessions');
    final res = await _client.post(
      uri,
      body: jsonEncode(payload),
      headers: {'Content-Type': 'application/json'},
    );
    if (res.statusCode != 200) throw Exception('Failed to save session');
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    return TherapySession.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<String> login(String username, String password) async {
    final uri = Uri.parse('$_baseUrl/auth/login');
    final res = await _client.post(
      uri,
      body: jsonEncode({'username': username, 'password': password}),
      headers: {'Content-Type': 'application/json'},
    );
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode != 200) {
      throw Exception(body['message'] ?? 'Failed to login');
    }
    return (body['data'] != null ? body['data']['token'] : body['token'])
        as String;
  }

  Future<void> register(
    String username,
    String password,
    String hospitalName,
  ) async {
    final uri = Uri.parse('$_baseUrl/auth/register');
    final res = await _client.post(
      uri,
      body: jsonEncode({
        'username': username,
        'password': password,
        'hospitalName': hospitalName,
      }),
      headers: {'Content-Type': 'application/json'},
    );
    if (res.statusCode != 201 && res.statusCode != 200) {
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      throw Exception(body['message'] ?? 'Failed to register');
    }
  }

  Future<void> bindDevice(String qrKey) async {
    final uri = Uri.parse('$_baseUrl/device/bind');
    final res = await _client.post(
      uri,
      body: jsonEncode({'qrKey': qrKey}),
      headers: {'Content-Type': 'application/json'},
    );
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception(body['message'] ?? 'Failed to bind device');
    }
    // API returns new token
    final newToken = body['data'] != null
        ? body['data']['token']
        : body['token'];
    if (newToken != null) {
      await AuthRepository().saveToken(newToken as String);
    }
  }

  Future<void> logout() async {
    final uri = Uri.parse('$_baseUrl/auth/logout');
    final res = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
    );
    if (res.statusCode != 200 && res.statusCode != 201 && res.statusCode != 204) {
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      final errObj = body['error'] ?? body;
      final errMsg = _parseErrorMessage(errObj['summary'] ?? errObj['message']);
      throw Exception(errMsg ?? 'Failed to logout');
    }
  }
}

final apiService = ApiService();
