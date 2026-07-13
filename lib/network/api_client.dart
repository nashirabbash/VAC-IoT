import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:vac_dashboard_app/repository/auth_repository.dart';
import 'package:vac_dashboard_app/main.dart';
import 'package:vac_dashboard_app/screens/welcomeScreens.dart';

class ApiClient extends http.BaseClient {
  final http.Client _inner = http.Client();

  // Change this base URL based on your server
  static const String baseUrl = 'http://10.0.2.2:3000/api'; 

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    // 1. Check if token exists
    final token = await AuthRepository.instance.getToken();
    
    // 2. Inject Authorization Header
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    
    // Add default JSON headers if not present
    if (!request.headers.containsKey('Content-Type')) {
      request.headers['Content-Type'] = 'application/json';
    }

    // 3. Send the request
    final response = await _inner.send(request);

    // 4. Global 401 Unauthorized Interception
    if (response.statusCode == 401) {
      await _handleUnauthorized();
    }

    return response;
  }

  Future<void> _handleUnauthorized() async {
    // Clear the token locally
    await AuthRepository.instance.clearToken();
    
    // Navigate back to WelcomeScreens using the global navigator key
    if (navigatorKey.currentContext != null) {
      Navigator.of(navigatorKey.currentContext!).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const WelcomeScreens()),
        (route) => false, // Remove all previous routes
      );
    }
  }
}

// A global singleton instance for the app to use
final apiClient = ApiClient();
