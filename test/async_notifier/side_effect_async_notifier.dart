import 'dart:async';
import 'package:riverpod/riverpod.dart';

import '../provider/provider.dart';
import 'async_notifier.dart';

final sideEffectAsyncNotifierProvider =
    AsyncNotifierProviderFamily<SideEffectAsyncNotifier, int, int>(
  SideEffectAsyncNotifier.new,
);

class SideEffectAsyncNotifier extends FamilyAsyncNotifier<int, int> {
  @override
  FutureOr<int> build(int initialValue) => initialValue;

  Repository get repository => ref.watch(repositoryProvider);

  void increment() {
    repository.sideEffect();
    state = AsyncData(value + 1);
  }

  void incrementByRepository() =>
      state = AsyncData(repository.incrementCounter());
}
