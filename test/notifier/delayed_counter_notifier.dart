import 'package:riverpod/riverpod.dart';

final delayedCounterNotifierProvider =
    NotifierProvider<DelayedCounterNotifier, int>(DelayedCounterNotifier.new);

class DelayedCounterNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void increment() {
    Future<void>.delayed(const Duration(milliseconds: 300), () {
      if (ref.exists(delayedCounterNotifierProvider)) {
        state++;
      }
    });
  }
}
