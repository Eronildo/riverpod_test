import 'dart:async';
import 'package:riverpod/riverpod.dart';

import 'async_notifier.dart';

final errorCountAsyncNotifierProvider =
    AsyncNotifierProvider<ErrorCountAsyncNotifier, int>(
  ErrorCountAsyncNotifier.new,
);

class ErrorCountAsyncNotifier extends AsyncNotifier<int> {
  @override
  FutureOr<int> build() => 0;

  void increment() {
    state = AsyncData(value + 1);
    throw ErrorCounterNotifierError();
  }
}

class ErrorCounterNotifierError extends Error {}
