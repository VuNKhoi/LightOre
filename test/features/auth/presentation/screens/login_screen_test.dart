import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lightore/features/auth/presentation/screens/login_screen.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../test_helpers.dart';

void main() {
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = createMockAuthRepository();
  });

  testWidgets('LoginScreen shows button and navigates on press',
      (tester) async {
    await pumpWidgetWithAuth(
      tester,
      const LoginScreen(),
      mockAuthRepository,
      const Scaffold(body: Text('Home Screen')),
    );

    expect(find.text('Continue to Home'), findsOneWidget);
    await tester.tap(find.text('Continue to Home'));
    await tester.pumpAndSettle();

    // Verify that the login logic called the repository
    verify(() => mockAuthRepository.setAuthenticated(true)).called(1);

    expect(find.text('Home Screen'), findsOneWidget);
  });
}
