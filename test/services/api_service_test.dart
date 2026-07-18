import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:vac_dashboard_app/services/api_service.dart';
import 'package:vac_dashboard_app/repositories/auth_repository.dart';

class MockHttpClient extends Mock implements http.Client {}
class MockAuthRepository extends Mock implements AuthRepository {}

class FakeUri extends Fake implements Uri {}

void main() {
  late MockHttpClient mockClient;
  late MockAuthRepository mockAuthRepository;
  late ApiService api;

  setUpAll(() {
    registerFallbackValue(FakeUri());
  });

  setUp(() {
    mockClient = MockHttpClient();
    mockAuthRepository = MockAuthRepository();
    api = ApiService(client: mockClient, authRepository: mockAuthRepository);
  });

  group('ApiService.getSessions', () {
    test('returns sessions on 200', () async {
      when(() => mockClient.get(any())).thenAnswer(
        (_) async => http.Response(
          jsonEncode({
            'status': 'ok',
            'data': [
              {
                'id': 1,
                'sessionDate': '2026-07-02T00:00:00.000Z',
                'title': 'Terapi #1',
                'date': '2 Jul 2026',
                'mode': 'Intermiten',
                'duration': '1 jam 0 menit',
              },
              {
                'id': 2,
                'sessionDate': '2026-06-30T00:00:00.000Z',
                'title': 'Terapi #2',
                'date': '30 Jun 2026',
                'mode': 'Kontinyu',
                'duration': '30 menit',
              },
            ],
          }),
          200,
        ),
      );

      final sessions = await api.getSessions();

      expect(sessions.length, 2);
      expect(sessions[0].id, 1);
      expect(sessions[0].mode, 'Intermiten');
      expect(sessions[1].id, 2);
      expect(sessions[1].mode, 'Kontinyu');
    });

    test('returns empty list when no sessions', () async {
      when(() => mockClient.get(any())).thenAnswer(
        (_) async =>
            http.Response(jsonEncode({'status': 'ok', 'data': []}), 200),
      );

      final sessions = await api.getSessions();

      expect(sessions, isEmpty);
    });

    test('throws on non-200 response', () async {
      when(
        () => mockClient.get(any()),
      ).thenAnswer((_) async => http.Response('Server error', 500));

      expect(() => api.getSessions(), throwsA(isA<Exception>()));
    });
  });

  group('ApiService.createSession', () {
    test('creates session and returns parsed result', () async {
      when(
        () => mockClient.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer(
        (_) async => http.Response(
          jsonEncode({
            'status': 'ok',
            'data': {
              'id': 1,
              'sessionDate': '2026-07-02T00:00:00.000Z',
              'title': 'Terapi #1',
              'date': '2 Jul 2026',
              'mode': 'Intermiten',
              'duration': '1 jam 0 menit',
            },
          }),
          200,
        ),
      );

      final session = await api.createSession({
        'start': 1751436000,
        'end': 1751439600,
        'mode': 1,
      });

      expect(session.id, 1);
      expect(session.title, 'Terapi #1');
      expect(session.mode, 'Intermiten');
      expect(session.duration, '1 jam 0 menit');
    });

    test('throws on non-200 response', () async {
      when(
        () => mockClient.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async => http.Response('Bad request', 400));

      expect(
        () => api.createSession({'start': 1, 'end': 2, 'mode': 1}),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('ApiService.logout', () {
    test('sends POST to /auth/logout and succeeds on 200', () async {
      when(
        () => mockClient.post(
          any(),
          headers: any(named: 'headers'),
        ),
      ).thenAnswer(
        (_) async => http.Response(jsonEncode({'status': 'ok'}), 200),
      );
      when(() => mockAuthRepository.clearToken()).thenAnswer((_) async {});

      await expectLater(api.logout(), completes);
      
      verify(() => mockClient.post(
        any(that: predicate<Uri>((uri) => uri.path.endsWith('/auth/logout'))),
        headers: any(named: 'headers'),
      )).called(1);
    });

    test('throws on non-200/201/204 response', () async {
      when(
        () => mockClient.post(
          any(),
          headers: any(named: 'headers'),
        ),
      ).thenAnswer((_) async => http.Response('{"error": {"message": "Unauthorized"}}', 401));

      expect(
        () => api.logout(),
        throwsA(isA<Exception>()),
      );
    });
  });
}
