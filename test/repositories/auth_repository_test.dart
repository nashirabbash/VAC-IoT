import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:vac_dashboard_app/repositories/auth_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
  });

  group('AuthRepository.getDeviceCredentials', () {
    test('returns null when no token or storage exists', () async {
      final repo = AuthRepository();
      final creds = await repo.getDeviceCredentials();
      expect(creds, isNull);
    });

    test('returns null when token is invalid or has no deviceId', () async {
      final repo = AuthRepository();
      final token = await repo.getToken();
      expect(token, isNull);
      final decoded = await repo.getDecodedToken();
      expect(decoded, isNull);
    });
  });
}
