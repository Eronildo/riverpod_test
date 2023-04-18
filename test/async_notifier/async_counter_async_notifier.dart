import 'dart:async';
import 'package:riverpod/riverpod.dart';

import 'async_notifier.dart';

final asyncCounterAsyncNotifierProvider =
    AsyncNotifierProvider<AsyncCounterAsyncNotifier, int>(
  AsyncCounterAsyncNotifier.new,
);

class AsyncCounterAsyncNotifier extends AsyncNotifier<int> {
  @override
  FutureOr<int> build() => 0;

  Future<void> increment() async {
    await Future<void>.delayed(const Duration(microseconds: 1));
    state = AsyncData(value + 1);
  }
}
