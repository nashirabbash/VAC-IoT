import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository {
  static const String _tokenKey = 'jwt_token';
  String? _cachedToken;
  bool _isInitialized = false;

  Future<void> _initCache() async {
    if (!_isInitialized) {
      final prefs = await SharedPreferences.getInstance();
      _cachedToken = prefs.getString(_tokenKey);
      _isInitialized = true;
    }
  }

  Future<void> saveToken(String token) async {
    _cachedToken = token;
    _isInitialized = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    await _initCache();
    return _cachedToken;
  }

  Future<void> clearToken() async {
    _cachedToken = null;
    _isInitialized = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
}
