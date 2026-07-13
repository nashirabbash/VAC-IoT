import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:vac_dashboard_app/repositories/auth_repository.dart';
import 'package:vac_dashboard_app/main.dart'; // to get navigatorKey
import 'package:vac_dashboard_app/screens/welcomeScreens.dart';

class ApiInterceptor extends http.BaseClient {
  final http.Client _inner = http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    // Inject token if available (except for login/register routes)
    final token = await authRepository.getToken();
    if (token != null && !request.url.path.contains('/login') && !request.url.path.contains('/register')) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    final response = await _inner.send(request);

    if (response.statusCode == 401) {
      // Clear token and force logout on Unauthorized response
      await authRepository.clearToken();
      _forceLogout();
    }

    return response;
  }

  void _forceLogout() {
    if (navigatorKey.currentState != null) {
      navigatorKey.currentState!.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const WelcomeScreens()),
        (route) => false,
      );
    }
  }
}
