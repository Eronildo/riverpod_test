import 'package:riverpod/riverpod.dart';

final errorNotifierProvider =
    NotifierProvider<ErrorCounterNotifier, int>(ErrorCounterNotifier.new);

class ErrorCounterNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void increment() {
    state++;
    throw CounterNotifierError();
  }
}

class CounterNotifierError extends Error {}
