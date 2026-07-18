import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vac_dashboard_app/screens/homeScreens.dart';
import 'package:vac_dashboard_app/screens/welcomeScreens.dart';
import 'package:vac_dashboard_app/repositories/auth_repository.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
  });

  testWidgets('Logout success path', (tester) async {
    when(() => mockAuthRepository.getDecodedToken()).thenAnswer((_) async => null);
    when(() => mockAuthRepository.logout()).thenAnswer((_) async {});
    
    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(authRepository: mockAuthRepository),
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
    
    // Verify authRepository.logout() was called
    verify(() => mockAuthRepository.logout()).called(1);

    // Verify navigation to WelcomeScreens
    expect(find.byType(WelcomeScreens), findsOneWidget);
  });
}
