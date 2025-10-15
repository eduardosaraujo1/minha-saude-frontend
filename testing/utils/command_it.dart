import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// command_it initializes a timer when a command is disposed
/// This causes issues with viewModel disposal during test teardown
/// So we pump a dummy widget and wait a bit
Future<int> waitForDispose(WidgetTester tester) async {
  await tester.pumpWidget(SizedBox());
  return await tester.pumpAndSettle(const Duration(milliseconds: 100));
}
