import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

Future<void> pumpUntilDisappear(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 30),
}) async {
  bool timerDone = false;
  final timer =
      Timer(timeout, () => throw TimeoutException("Pump until has timed out"));
  while (timerDone != true) {
    await tester.pumpAndSettle();

    final found = tester.any(finder);
    if (!found) {
      timerDone = true;
    }
  }
  timer.cancel();
}
