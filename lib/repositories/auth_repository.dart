// lib/repositories/auth_repository.dart
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository {
  static const _key = 'auth_status';

  Future<void> setAuthenticated(bool isAuthenticated) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, isAuthenticated);
  }

  Future<bool?> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key); // null means unknown
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
