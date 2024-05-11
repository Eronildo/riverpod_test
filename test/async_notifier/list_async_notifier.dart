import 'dart:async';
import 'package:riverpod/riverpod.dart';

final listAsyncNotifierProvider =
    AsyncNotifierProvider<ListAsyncNotifier, List<int>>(
  ListAsyncNotifier.new,
);

class ListAsyncNotifier extends AsyncNotifier<List<int>> {
  @override
  FutureOr<List<int>> build() => [];

  Future<void> getFromRepository() async {
    await Future<void>.delayed(const Duration(microseconds: 1));
    state = AsyncData([]);
  }
}
