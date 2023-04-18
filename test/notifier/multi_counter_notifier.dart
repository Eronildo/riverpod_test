import 'package:riverpod/riverpod.dart';

final multiCounterNotifierProvider =
    NotifierProvider<MultiCounterNotifier, int>(MultiCounterNotifier.new);

class MultiCounterNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void increment() {
    state++;
    state++;
  }
}
