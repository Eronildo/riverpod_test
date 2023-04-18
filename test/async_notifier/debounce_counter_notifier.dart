import 'dart:async';
import 'package:riverpod/riverpod.dart';

import 'async_notifier.dart';

final debounceCounterAsyncNotifierProvider =
    AsyncNotifierProvider<DebounceCounterNotifier, int>(
  DebounceCounterNotifier.new,
);

class DebounceCounterNotifier extends AsyncNotifier<int> {
  @override
  FutureOr<int> build() => 0;

  Future<void> increment() async {
    await ref.debounce(const Duration(milliseconds: 300));
    state = AsyncData(value + 1);
  }
}

extension RefExtension on Ref {
  Future<void> debounce(Duration duration) {
    final completer = Completer<void>();
    final timer = Timer(duration, () {
      if (!completer.isCompleted) completer.complete();
    });

    onDispose(() {
      timer.cancel();
      if (!completer.isCompleted) {
        completer.completeError(StateError('cancelled'));
      }
    });

    return completer.future;
  }
}
