// lib/repositories/auth_repository.dart
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository {
  static const _key = 'auth_status';

  /// Returns true if the value was set successfully, false otherwise.
  /// TODO: Consider returning a Result/Either type for richer error handling.
  Future<bool> setAuthenticated(bool isAuthenticated) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setBool(_key, isAuthenticated);
    } catch (_) {
      return false;
    }
  }

  Future<bool?> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key); // null means unknown
  }

  /// Returns true if the value was cleared successfully, false otherwise.
  /// TODO: Consider returning a Result/Either type for richer error handling.
  Future<bool> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_key);
    } catch (_) {
      return false;
    }
  }
}
