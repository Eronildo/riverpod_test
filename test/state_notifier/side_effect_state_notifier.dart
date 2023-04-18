import 'package:riverpod/riverpod.dart';

import '../provider/provider.dart';

final sideEffectStateNotifierProvider =
    StateNotifierProvider<SideEffectStateNotifier, int>(
  (ref) => SideEffectStateNotifier(repository: ref.watch(repositoryProvider)),
);

class SideEffectStateNotifier extends StateNotifier<int> {
  SideEffectStateNotifier({required this.repository}) : super(0);

  final Repository repository;

  void increment() {
    repository.sideEffect();
    state++;
  }

  void incrementByRepository() => state = repository.incrementCounter();
}
