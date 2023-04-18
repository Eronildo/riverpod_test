import 'package:riverpod/riverpod.dart';

import '../provider/provider.dart';

final sideEffectCounterNotifierProvider =
    NotifierProvider<SideEffectCounterNotifier, int>(
  SideEffectCounterNotifier.new,
);

class SideEffectCounterNotifier extends Notifier<int> {
  @override
  int build() => 0;

  Repository get repository => ref.watch(repositoryProvider);

  void increment() {
    repository.sideEffect();
    state++;
  }

  void incrementByRepository() => state = repository.incrementCounter();
}
