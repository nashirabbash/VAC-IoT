import 'package:flutter_test/flutter_test.dart';
import 'package:vac_dashboard_app/models/therapy_session.dart';

void main() {
  group('TherapySession.fromJson', () {
    test('parses full JSON with id', () {
      final json = {
        'id': 1,
        'sessionDate': '2026-07-02T00:00:00.000Z',
        'title': 'Terapi #1',
        'date': '2 Jul 2026',
        'mode': 'Intermiten',
        'duration': '1 jam 0 menit',
      };

      final session = TherapySession.fromJson(json);

      expect(session.id, 1);
      expect(session.sessionDate, '2026-07-02T00:00:00.000Z');
      expect(session.title, 'Terapi #1');
      expect(session.date, '2 Jul 2026');
      expect(session.mode, 'Intermiten');
      expect(session.duration, '1 jam 0 menit');
    });

    test('parses JSON with null id', () {
      final json = {
        'id': null,
        'sessionDate': '2026-07-02T00:00:00.000Z',
        'title': 'Terapi #1',
        'date': '2 Jul 2026',
        'mode': 'Kontinyu',
        'duration': '30 menit',
      };

      final session = TherapySession.fromJson(json);

      expect(session.id, isNull);
      expect(session.mode, 'Kontinyu');
    });

    test('parses JSON without id field', () {
      final json = {
        'sessionDate': '2026-07-02T00:00:00.000Z',
        'title': 'Terapi #1',
        'date': '2 Jul 2026',
        'mode': 'Intermiten',
        'duration': '5 menit',
      };

      final session = TherapySession.fromJson(json);

      expect(session.mode, 'Intermiten');
      expect(session.duration, '5 menit');
    });

    test('parses Kontinyu mode', () {
      final json = {
        'sessionDate': '2026-06-30T00:00:00.000Z',
        'title': 'Terapi #2',
        'date': '30 Jun 2026',
        'mode': 'Kontinyu',
        'duration': '2 jam 30 menit',
      };

      final session = TherapySession.fromJson(json);

      expect(session.mode, 'Kontinyu');
      expect(session.date, '30 Jun 2026');
    });

    test('parses short duration', () {
      final json = {
        'sessionDate': '2026-07-01T00:00:00.000Z',
        'title': 'Terapi #3',
        'date': '1 Jul 2026',
        'mode': 'Intermiten',
        'duration': '30 detik',
      };

      final session = TherapySession.fromJson(json);

      expect(session.duration, '30 detik');
    });
  });

  group('TherapySession.parsedDateTime', () {
    test('parses ISO string directly', () {
      const session = TherapySession(
        sessionDate: '2026-07-29T11:04:00.000',
        title: 'Kontinyu 125 mmHg',
        date: '29 Jul, 11:04',
        mode: 'Kontinyu',
        duration: '45 min',
      );

      expect(session.parsedDateTime, DateTime(2026, 7, 29, 11, 4));
    });

    test('parses date and time string fallback', () {
      const session = TherapySession(
        sessionDate: '2026-07-29',
        title: 'Kontinyu 125 mmHg',
        date: '29 Jul, 11:04',
        mode: 'Kontinyu',
        duration: '45 min',
      );

      expect(session.parsedDateTime, DateTime(2026, 7, 29, 11, 4));
    });
  });
}
