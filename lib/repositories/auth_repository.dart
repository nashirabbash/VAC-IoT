import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:vac_dashboard_app/models/device_credentials.dart';

class AuthRepository {
  static const String _tokenKey = 'jwt_token';
  static const String _deviceIdKey = 'device_id';
  static const String _authPinKey = 'auth_pin';
  static const String _usernameKey = 'username';
  final _storage = const FlutterSecureStorage();
  String? _cachedToken;
  String? _cachedUsername;
  bool _isInitialized = false;

  Future<void> _initCache() async {
    if (!_isInitialized) {
      _cachedToken = await _storage.read(key: _tokenKey);
      _cachedUsername = await _storage.read(key: _usernameKey);
      _isInitialized = true;
    }
  }

  Future<void> saveToken(String token) async {
    await _initCache();
    _cachedToken = token;
    _isInitialized = true;
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    await _initCache();
    return _cachedToken;
  }

  Future<void> saveUsername(String username) async {
    _cachedUsername = username;
    await _storage.write(key: _usernameKey, value: username);
  }

  Future<String?> getUsername() async {
    await _initCache();
    if (_cachedUsername != null && _cachedUsername!.isNotEmpty) {
      return _cachedUsername;
    }
    final decoded = await getDecodedToken();
    if (decoded != null) {
      final tokenUsername = (decoded['username'] ??
              decoded['name'] ??
              decoded['sub'] ??
              (decoded['user'] is Map ? decoded['user']['username'] : null))
          ?.toString();
      if (tokenUsername != null && tokenUsername.isNotEmpty) {
        await saveUsername(tokenUsername);
        return tokenUsername;
      }
    }
    return null;
  }

  static String getInitials(String? username) {
    if (username == null || username.trim().isEmpty) return 'U';
    final cleaned = username.trim();
    final parts =
        cleaned.split(RegExp(r'[\s_.\-]+')).where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return cleaned[0].toUpperCase();
  }

  Future<void> clearToken() async {
    _cachedToken = null;
    _cachedUsername = null;
    _isInitialized = true;
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _deviceIdKey);
    await _storage.delete(key: _authPinKey);
    await _storage.delete(key: _usernameKey);
  }

  Future<void> saveDeviceConfig(DeviceCredentials credentials) async {
    await _storage.write(key: _deviceIdKey, value: credentials.deviceId);
    await _storage.write(key: _authPinKey, value: credentials.authPin);
  }

  /// Retrieves the saved [DeviceCredentials] from secure storage.
  ///
  /// **Side Effect (Self-Healing Fallback)**: If secure storage is empty (e.g. after fresh login),
  /// this method checks the decoded JWT token payload for a `deviceId`. If found, it automatically
  /// persists the extracted credentials to secure storage via [saveDeviceConfig] so future reads
  /// are fast and consistent across app restarts.
  Future<DeviceCredentials?> getDeviceCredentials() async {
    final deviceId = await _storage.read(key: _deviceIdKey);
    final authPin = await _storage.read(key: _authPinKey);
    if (deviceId != null && deviceId.isNotEmpty) {
      return DeviceCredentials(deviceId: deviceId, authPin: authPin ?? '');
    }

    // Fallback: check JWT token payload if stored deviceId is missing
    final decoded = await getDecodedToken();
    if (decoded != null) {
      final tokenDeviceId =
          (decoded['deviceId'] ?? decoded['device_id'])?.toString();
      if (tokenDeviceId != null && tokenDeviceId.isNotEmpty) {
        final tokenAuthPin =
            (decoded['authPin'] ?? decoded['pin'] ?? '')?.toString() ?? '';
        final creds = DeviceCredentials(
          deviceId: tokenDeviceId,
          authPin: tokenAuthPin,
        );
        await saveDeviceConfig(creds);
        return creds;
      }
    }
    return null;
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
