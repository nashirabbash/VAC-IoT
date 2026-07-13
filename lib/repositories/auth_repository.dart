import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthRepository {
  static const String _tokenKey = 'jwt_token';
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
