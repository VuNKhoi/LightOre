import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lightore/features/auth/presentation/widgets/info_banner.dart';

void main() {
  testWidgets('InfoBanner renders message', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: InfoBanner(message: 'Info!')),
    ));
    expect(find.text('Info!'), findsOneWidget);
  });

  testWidgets('InfoBanner renders nothing if message is null', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: InfoBanner(message: null)),
    ));
    expect(find.byType(Text), findsNothing);
  });
}
