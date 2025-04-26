import 'dart:async';
import 'package:riverpod/riverpod.dart';

import 'async_notifier.dart';

final counterStreamNotifierProvider =
    StreamNotifierProviderFamily<CounterStreamNotifier, int, int>(
  CounterStreamNotifier.new,
);

class CounterStreamNotifier extends FamilyStreamNotifier<int, int> {
  @override
  Stream<int> build(int initialValue) => Stream.value(initialValue);

  void increment() => state = AsyncData(value + 1);
}
