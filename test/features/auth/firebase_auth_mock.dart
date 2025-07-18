// test/features/auth/helpers/firebase_auth_mock.dart
// Helper to provide a mock FirebaseAuth for AuthRepository tests
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockUserCredential extends Mock implements UserCredential {}
class MockUser extends Mock implements User {}
