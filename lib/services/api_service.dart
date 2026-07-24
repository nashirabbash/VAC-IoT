import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vac_dashboard_app/models/therapy_session.dart';
import 'package:vac_dashboard_app/models/register_dto.dart';
import 'package:vac_dashboard_app/models/device_credentials.dart';
import 'package:vac_dashboard_app/network/api_interceptor.dart';
import 'package:vac_dashboard_app/repositories/auth_repository.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

class ApiService {
  static const _baseUrl = 'http://192.168.1.35:3000/api';

  final http.Client _client;
  final AuthRepository _authRepository;

  ApiService._(this._client, this._authRepository);

  factory ApiService({http.Client? client, AuthRepository? authRepository}) {
    final authRepo = authRepository ?? AuthRepository();
    return ApiService._(
      client ?? ApiInterceptor(authRepository: authRepo),
      authRepo,
    );
  }

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

  Future<void> login(String username, String password) async {
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
    final token = (body['data'] != null ? body['data']['token'] : body['token']) as String;
    await _authRepository.saveToken(token);
  }

  Future<void> register(RegisterDto dto) async {
    final uri = Uri.parse('$_baseUrl/auth/register');
    final res = await _client.post(
      uri,
      body: jsonEncode(dto.toJson()),
      headers: {'Content-Type': 'application/json'},
    );
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode != 201 && res.statusCode != 200) {
      throw Exception(body['message'] ?? 'Failed to register');
    }
    final token = body['data'] != null ? body['data']['token'] : body['token'];
    if (token != null) {
      await _authRepository.saveToken(token as String);
    }
    if (dto.qrKey != null) {
      await _saveDeviceCredentials(dto.qrKey!);
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
      await _authRepository.saveToken(newToken as String);
    }

    await _saveDeviceCredentials(qrKey);
  }

  Future<void> logout() async {
    final uri = Uri.parse('$_baseUrl/auth/logout');
    final res = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
    );
    if (res.statusCode != 200 && res.statusCode != 201 && res.statusCode != 204) {
      throw ApiException('Failed to logout');
    }
    await _authRepository.clearToken();
  }

  Future<void> _saveDeviceCredentials(String qrKey) async {
    final creds = DeviceCredentials.tryParseQrKey(qrKey);
    if (creds != null) {
      await _authRepository.saveDeviceConfig(creds);
    }
  }
}

final apiService = ApiService();
