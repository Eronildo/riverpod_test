import 'package:riverpod/riverpod.dart';

final counterStateNotifierProvider =
    StateNotifierProvider<CounterStateNotifier, int>(
  (ref) => CounterStateNotifier(),
);

class CounterStateNotifier extends StateNotifier<int> {
  CounterStateNotifier() : super(0);

  void increment() => state++;

  Future<void> decrement() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    state--;
  }
}
