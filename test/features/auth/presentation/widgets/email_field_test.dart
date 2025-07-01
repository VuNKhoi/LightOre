import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lightore/features/auth/presentation/widgets/email_field.dart';

void main() {
  testWidgets('EmailField renders and validates', (tester) async {
    String value = '';
    bool cleared = false;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: EmailField(
          value: value,
          onChanged: (v) => value = v,
          onClearMessages: () => cleared = true,
        ),
      ),
    ));
    expect(find.byType(TextFormField), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), 'test');
    expect(value, 'test');
    expect(cleared, isTrue);
  });
}
