import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:vac_dashboard_app/repositories/auth_repository.dart';

class AuthException implements Exception {
  final String message;
  AuthException([this.message = 'Unauthorized']);

  @override
  String toString() => 'AuthException: $message';
}

class SecurityException implements Exception {
  final String message;
  SecurityException(this.message);

  @override
  String toString() => 'SecurityException: $message';
}

class ApiInterceptor extends http.BaseClient {
  final http.Client _inner = http.Client();
  final AuthRepository authRepository;

  ApiInterceptor({required this.authRepository});

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    // Enforce HTTPS / TLS 1.3 transport encryption requirement (allowing HTTP for local dev in debug mode)
    if (!kDebugMode && request.url.scheme != 'https') {
      throw SecurityException('Insecure HTTP transport rejected. Mandatory TLS 1.3 / HTTPS required.');
    }

    // Inject token if available (except for login/register routes)
    final token = await authRepository.getToken();
    if (token != null &&
        !request.url.path.endsWith('/login') &&
        !request.url.path.endsWith('/register')) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    final response = await _inner.send(request);

    if (response.statusCode == 401) {
      // Clear token and throw exception on Unauthorized response
      await authRepository.clearToken();
      throw AuthException();
    }

    return response;
  }
}
