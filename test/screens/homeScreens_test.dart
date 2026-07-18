import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vac_dashboard_app/screens/homeScreens.dart';
import 'package:vac_dashboard_app/screens/welcomeScreens.dart';
import 'package:vac_dashboard_app/services/api_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:vac_dashboard_app/repositories/auth_repository.dart';

class MockApiService extends Mock implements ApiService {}

void main() {
  late MockApiService mockApiService;

  setUpAll(() {
    FlutterSecureStorage.setMockInitialValues({});
  });

  setUp(() {
    mockApiService = MockApiService();
    apiService = mockApiService;
  });

  testWidgets('Logout success path', (tester) async {
    when(() => mockApiService.logout()).thenAnswer((_) async {});
    
    await tester.pumpWidget(
      const MaterialApp(
        home: HomeScreen(),
      ),
    );
    await tester.pump();

    // The avatar has a tooltip 'Account Actions'
    final avatarFinder = find.byTooltip('Account Actions');
    expect(avatarFinder, findsOneWidget);
    
    // Provide a token before logout
    await AuthRepository().saveToken('fake_token');
    expect(await AuthRepository().getToken(), 'fake_token');

    // Tap the avatar
    await tester.tap(avatarFinder);
    await tester.pump();

    // Verify the menu opens
    final logoutButtonFinder = find.text('Log out');
    expect(logoutButtonFinder, findsOneWidget);

    // Tap Log out
    await tester.tap(logoutButtonFinder);
    
    // Give it enough time for the async methods and navigation animation
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));
    
    // Verify apiService.logout() was called
    verify(() => mockApiService.logout()).called(1);

    // Verify token was cleared
    expect(await AuthRepository().getToken(), null);

    // Verify navigation to WelcomeScreens
    expect(find.byType(WelcomeScreens), findsOneWidget);
  });
}
