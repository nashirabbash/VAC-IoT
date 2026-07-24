import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:vac_dashboard_app/models/device_credentials.dart';

class AuthRepository {
  static const String _tokenKey = 'jwt_token';
  static const String _deviceIdKey = 'device_id';
  static const String _authPinKey = 'auth_pin';
  final _storage = const FlutterSecureStorage();
  String? _cachedToken;
  bool _isInitialized = false;

  Future<void> _initCache() async {
    if (!_isInitialized) {
      _cachedToken = await _storage.read(key: _tokenKey);
      _isInitialized = true;
    }
  }

  Future<void> saveToken(String token) async {
    _cachedToken = token;
    _isInitialized = true;
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    await _initCache();
    return _cachedToken;
  }

  Future<void> clearToken() async {
    _cachedToken = null;
    _isInitialized = true;
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _deviceIdKey);
    await _storage.delete(key: _authPinKey);
  }

  Future<void> saveDeviceConfig(DeviceCredentials credentials) async {
    await _storage.write(key: _deviceIdKey, value: credentials.deviceId);
    await _storage.write(key: _authPinKey, value: credentials.authPin);
  }

  Future<String?> getDeviceId() async {
    return await _storage.read(key: _deviceIdKey);
  }

  Future<String?> getAuthPin() async {
    return await _storage.read(key: _authPinKey);
  }

  Future<Map<String, dynamic>?> getDecodedToken() async {
    final token = await getToken();
    if (token == null) return null;
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      return jsonDecode(decoded) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }
}
