import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lightore/features/auth/presentation/widgets/password_field.dart';

void main() {
  testWidgets('PasswordField renders and validates', (tester) async {
    String value = '';
    bool cleared = false;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: PasswordField(
          value: value,
          onChanged: (v) => value = v,
          onClearMessages: () => cleared = true,
        ),
      ),
    ));
    expect(find.byType(TextFormField), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), 'secret');
    expect(value, 'secret');
    expect(cleared, isTrue);
  });
}
