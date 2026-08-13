import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vac_dashboard_app/db/database_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DatabaseHelper & SQLCipher Encryption Key Unit Tests', () {
    late DatabaseHelper dbHelper;

    setUp(() {
      FlutterSecureStorage.setMockInitialValues({});
      dbHelper = DatabaseHelper.withStorage(const FlutterSecureStorage());
    });

    test('getOrCreateEncryptionKey generates and persists a valid key', () async {
      final key1 = await dbHelper.getOrCreateEncryptionKey();
      expect(key1, isNotEmpty);
      expect(key1.length, greaterThanOrEqualTo(32));

      // Second call should return the same persisted key
      final key2 = await dbHelper.getOrCreateEncryptionKey();
      expect(key2, equals(key1));
    });

    test('DatabaseHelper.instance singleton exists', () {
      expect(DatabaseHelper.instance, isNotNull);
    });
  });
}
