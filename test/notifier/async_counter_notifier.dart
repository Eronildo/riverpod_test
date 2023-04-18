import 'package:riverpod/riverpod.dart';

final asyncCounterNotifierProvider =
    NotifierProvider<AsyncCounterNotifier, int>(AsyncCounterNotifier.new);

class AsyncCounterNotifier extends Notifier<int> {
  @override
  int build() => 0;

  Future<void> increment() async {
    await Future<void>.delayed(const Duration(microseconds: 1));
    state++;
  }
}
