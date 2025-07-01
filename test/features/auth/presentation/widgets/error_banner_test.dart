import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lightore/features/auth/presentation/widgets/error_banner.dart';

void main() {
  testWidgets('ErrorBanner renders message', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: ErrorBanner(message: 'Error!')),
    ));
    expect(find.text('Error!'), findsOneWidget);
  });

  testWidgets('ErrorBanner renders nothing if message is null', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: ErrorBanner(message: null)),
    ));
    expect(find.byType(Text), findsNothing);
  });
}
