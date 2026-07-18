import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vac_dashboard_app/screens/homeScreens.dart';
import 'package:vac_dashboard_app/screens/welcomeScreens.dart';
import 'package:vac_dashboard_app/repositories/auth_repository.dart';
import 'package:vac_dashboard_app/services/api_service.dart';

class MockAuthRepository extends Mock implements AuthRepository {}
class MockApiService extends Mock implements ApiService {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late MockApiService mockApiService;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockApiService = MockApiService();
  });

  testWidgets('Logout success path', (tester) async {
    when(() => mockAuthRepository.getDecodedToken()).thenAnswer((_) async => null);
    when(() => mockApiService.logout()).thenAnswer((_) async {});
    when(() => mockAuthRepository.clearToken()).thenAnswer((_) async {});
    
    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(
          authRepository: mockAuthRepository,
          apiService: mockApiService,
        ),
      ),
    );
    await tester.pump();

    // The avatar has a tooltip 'Account Actions'
    final avatarFinder = find.byTooltip('Account Actions');
    expect(avatarFinder, findsOneWidget);
    
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
    verify(() => mockAuthRepository.clearToken()).called(1);

    // Verify navigation to WelcomeScreens
    expect(find.byType(WelcomeScreens), findsOneWidget);
  });
}
