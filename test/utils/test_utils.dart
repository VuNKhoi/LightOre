
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:your_app/app.dart';
import 'package:go_router/go_router.dart';

/// Pumps the full app with the given overrides.
Future<void> pumpAppWithOverrides(
  WidgetTester tester,
  List<Override> overrides,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: const MyApp(),
    ),
  );
  await tester.pump();
}

/// Navigates to a route using GoRouter.
Future<void> navigateTo(WidgetTester tester, String location) async {
  final state = tester.state<NavigatorState>(find.byType(Navigator));
  state.context.go(location);
}
