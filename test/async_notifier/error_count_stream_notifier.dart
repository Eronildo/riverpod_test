import 'dart:async';
import 'package:riverpod/riverpod.dart';

import 'async_notifier.dart';

final errorCountStreamNotifierProvider =
    StreamNotifierProvider<ErrorCountStreamNotifier, int>(
  ErrorCountStreamNotifier.new,
);

class ErrorCountStreamNotifier extends StreamNotifier<int> {
  @override
  Stream<int> build() => Stream.value(0);

  void increment() {
    state = AsyncData(value + 1);
    throw ErrorCounterStreamNotifierError();
  }
}

class ErrorCounterStreamNotifierError extends Error {}
