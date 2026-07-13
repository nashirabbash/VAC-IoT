import 'package:http/http.dart' as http;
import 'package:vac_dashboard_app/repositories/auth_repository.dart';

class AuthException implements Exception {
  final String message;
  AuthException([this.message = 'Unauthorized']);

  @override
  String toString() => 'AuthException: $message';
}

class ApiInterceptor extends http.BaseClient {
  final http.Client _inner = http.Client();
  final AuthRepository authRepository;

  ApiInterceptor({required this.authRepository});

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    // Inject token if available (except for login/register routes)
    final token = await authRepository.getToken();
    if (token != null &&
        !request.url.path.contains('/login') &&
        !request.url.path.contains('/register')) {
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
