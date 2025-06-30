import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lightore/repositories/auth_repository.dart';

void main() {
  late AuthRepository authRepository;
  late SharedPreferences sharedPreferences;

  setUp(() async {
    SharedPreferences.setMockInitialValues(
        {}); // Clear mock storage before each test
    sharedPreferences = await SharedPreferences.getInstance();
    authRepository = AuthRepository();
  });

  group('AuthRepository Tests', () {
    test('setAuthenticated stores the correct value and returns success',
        () async {
      final resultTrue = await authRepository.setAuthenticated(true);
      expect(resultTrue, true);
      expect(sharedPreferences.getBool('auth_status'), true);

      final resultFalse = await authRepository.setAuthenticated(false);
      expect(resultFalse, true);
      expect(sharedPreferences.getBool('auth_status'), false);
    });

    test('isAuthenticated retrieves the correct value', () async {
      await sharedPreferences.setBool('auth_status', true);
      expect(await authRepository.isAuthenticated(), true);

      await sharedPreferences.setBool('auth_status', false);
      expect(await authRepository.isAuthenticated(), false);

      await sharedPreferences.remove('auth_status');
      expect(await authRepository.isAuthenticated(), null);
    });

    test('clear removes the auth_status key and returns success', () async {
      await sharedPreferences.setBool('auth_status', true);
      final result = await authRepository.clear();
      expect(result, true);
      expect(sharedPreferences.getBool('auth_status'), null);
    });
  });
}
