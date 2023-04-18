import 'dart:async';
import 'package:riverpod/riverpod.dart';

import 'async_notifier.dart';

final counterAsyncNotifierProvider =
    AsyncNotifierProviderFamily<CounterAsyncNotifier, int, int>(
  CounterAsyncNotifier.new,
);

class CounterAsyncNotifier extends FamilyAsyncNotifier<int, int> {
  @override
  FutureOr<int> build(int initialValue) => initialValue;

  void increment() => state = AsyncData(value + 1);
}
