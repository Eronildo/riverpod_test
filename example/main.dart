import 'dart:async';

import 'package:mocktail/mocktail.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_test/riverpod_test.dart';
import 'package:test/test.dart';

class MockRepository extends Mock implements Repository {}

void main() {
  mainProvider();
  mainNotifier();
  mainResultProvider();
  mainStateNotifier();
}

void mainProvider() {
  group('counterProvider', () {
    testProvider<int>(
      'expect [0]',
      provider: counterProvider,
      expect: () => const <int>[0],
    );
  });

  group('counterRepositoryProvider', () {
    final mockRepository = MockRepository();

    testProvider<int>(
      'expect [5] from repository',
      overrides: [repositoryProvider.overrideWithValue(mockRepository)],
      setUp: () => when(mockRepository.incrementCounter).thenReturn(5),
      provider: counterRepositoryProvider,
      expect: () => const <int>[5],
    );
  });
}

void mainNotifier() {
  group('counterNotifierProvider', () {
    testNotifier<CounterNotifier, int>(
      'expect [1] when increment is called',
      provider: counterNotifierProvider,
      act: (notifier) => notifier.increment(),
      expect: () => const <int>[1],
    );

    testAsyncNotifier<CounterAsyncNotifier, int>(
      'expect [AsyncData(2)] when increment is called with seed: AsyncData(1)',
      provider: counterAsyncNotifierProvider,
      seed: const AsyncData(1),
      act: (notifier) => notifier.increment(),
      expect: () => [const AsyncData(2)],
    );

    testAsyncNotifier<CounterStreamNotifier, int>(
      'expect [AsyncData(2)] when increment is called with seed: AsyncData(1)',
      provider: counterStreamNotifierProvider,
      seed: const AsyncData(1),
      act: (notifier) => notifier.increment(),
      expect: () => [const AsyncData(2)],
    );
  });
}

void mainResultProvider() {
  testResultProvider<Repository>(
    'expect [1] when incrementCounter is called',
    provider: repositoryProvider,
    act: (result) => result.incrementCounter(),
    expect: () => [1],
  );
}

void mainStateNotifier() {
  testStateNotifier(
    'expect [1, 2] when increment is called twice',
    provider: counterStateNotifierProvider,
    act: (notifier) => notifier
      ..increment()
      ..increment(),
    expect: () => [1, 2],
  );
}

final counterProvider = Provider<int>((ref) => 0);

final counterRepositoryProvider =
    Provider<int>((ref) => ref.watch(repositoryProvider).incrementCounter());

final counterNotifierProvider =
    NotifierProvider<CounterNotifier, int>(CounterNotifier.new);

final counterAsyncNotifierProvider =
    AsyncNotifierProvider<CounterAsyncNotifier, int>(CounterAsyncNotifier.new);

final counterStreamNotifierProvider =
    StreamNotifierProvider<CounterStreamNotifier, int>(
        CounterStreamNotifier.new);

final repositoryProvider = Provider<Repository>((ref) => Repository());

final counterStateNotifierProvider =
    StateNotifierProvider<CounterStateNotifier, int>(
  (ref) => CounterStateNotifier(),
);

class CounterNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void increment() => state++;
}

class CounterAsyncNotifier extends AsyncNotifier<int> {
  @override
  FutureOr<int> build() => 0;

  void increment() => state = AsyncData(state.value! + 1);
}

class CounterStreamNotifier extends StreamNotifier<int> {
  @override
  Stream<int> build() async* {
    yield 0;
  }

  void increment() => state = AsyncData(state.value! + 1);
}

class Repository {
  int incrementCounter() => 1;
}

class CounterStateNotifier extends StateNotifier<int> {
  CounterStateNotifier() : super(0);

  void increment() => state++;
}
