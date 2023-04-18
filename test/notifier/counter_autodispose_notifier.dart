import 'package:riverpod/riverpod.dart';

final counterAutoDisposeNotifierProvider =
    AutoDisposeNotifierProvider<CounterAutoDisposeNotifier, int>(
  CounterAutoDisposeNotifier.new,
);

class CounterAutoDisposeNotifier extends AutoDisposeNotifier<int> {
  @override
  int build() => 0;

  void increment() => state++;
}
