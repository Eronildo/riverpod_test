import 'dart:async';
import 'package:riverpod/riverpod.dart';

import 'async_notifier.dart';

final multiCounterAsyncNotifierProvider =
    AsyncNotifierProvider<MultiCounterAsyncNotifier, int>(
  MultiCounterAsyncNotifier.new,
);

class MultiCounterAsyncNotifier extends AsyncNotifier<int> {
  @override
  FutureOr<int> build() => 0;

  void increment() {
    state = AsyncData(value + 1);
    state = AsyncData(value + 1);
  }
}
