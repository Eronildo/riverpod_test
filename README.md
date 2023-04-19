<p align="center">
<a href="https://pub.dev/packages/riverpod_test"><img src="https://img.shields.io/pub/v/riverpod_test.svg?color=blue" alt="Pub"></a>
<a href="https://github.com/Eronildo/riverpod_test"><img src="https://img.shields.io/github/stars/Eronildo/riverpod_test.svg?style=flat&logo=github&colorB=blue&label=stars" alt="Star on Github"></a>
<a href="https://docs.flutter.dev/development/data-and-backend/state-mgmt/options#riverpod"><img src="https://img.shields.io/badge/flutter-website-deepskyblue.svg" alt="Flutter Website"></a>
<a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-purple.svg" alt="License: MIT"></a>
<a href="https://github.com/rrousselGit/riverpod"><img src="https://img.shields.io/pub/v/riverpod.svg?label=riverpod&color=blue)](https://pub.dartlang.org/packages/riverpod" alt="Bloc Library"></a>
</p>

---

## Package

Package is a port of `felangel`'s `bloc_test`, modified to work with Riverpod Providers.\
Increase code coverage by testing all riverpod providers.

## Installation

Add to dev dependencies inside pubspec_yaml:

```yaml
dev_dependencies:
  riverpod_test: [version]
```

## Usage

`testProvider`

```dart
import 'package:riverpod_test.dart';

testProvider(
  'expect [0]',
  provider: counterProvider,
  expect: () => [0],
);

final counterProvider = Provider<int>((ref) => 0);
```

`testNotifier`

```dart
testNotifier(
  'expect [2] when increment is called twice and skip: 1',
  provider: counterNotifierProvider,
  act: (notifier) => notifier
      ..increment()
      ..increment(),
  skip: 1,
  expect: () => [2],
);

final counterNotifierProvider =
    NotifierProvider<CounterNotifier, int>(CounterNotifier.new);

class CounterNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void increment() => state++;
}

```

`testAsyncNotifier`

```dart
testAsyncNotifier<CounterAsyncNotifier, int>(
  'expect [AsyncData(1)] when call increment',
  provider: counterAsyncNotifierProvider(0),
  act: (notifier) => notifier.increment(),
  expect: () => <AsyncValue<int>>[const AsyncData(1)],
);

testAsyncNotifier(
  'verify if mockRepository sideEffect is called',
  provider: sideEffectAsyncNotifierProvider(1),
  overrides: [repositoryProvider.overrideWithValue(mockRepository)],
  act: (notifier) => notifier.increment(),
  verify: (_) => verify(mockRepository.sideEffect).called(1),
);

final counterAsyncNotifierProvider =
    AsyncNotifierProviderFamily<CounterAsyncNotifier, int, int>(
  CounterAsyncNotifier.new,
);

class CounterAsyncNotifier extends FamilyAsyncNotifier<int, int> {
  @override
  FutureOr<int> build(int initialValue) => initialValue;

  void increment() => state = AsyncData(value + 1);
}

class MockRepository extends Mock implements Repository {}

final sideEffectAsyncNotifierProvider =
    AsyncNotifierProviderFamily<SideEffectAsyncNotifier, int, int>(
  SideEffectAsyncNotifier.new,
);

class SideEffectAsyncNotifier extends FamilyAsyncNotifier<int, int> {
  @override
  FutureOr<int> build(int initialValue) => initialValue;

  Repository get repository => ref.watch(repositoryProvider);

  void increment() {
    repository.sideEffect();
    state = AsyncData(value + 1);
  }
}
```

`testResultProvider`

```dart
testResultProvider<Repository>(
  'expect [1] when incrementCounter is called',
  provider: repositoryProvider,
  act: (result) => result.incrementCounter(),
  expect: () => [1],
);

final repositoryProvider = Provider<Repository>((ref) => Repository());

class Repository {
  int incrementCounter() => 1;
}

```

`testStateNotifier`

```dart
testStateNotifier<CounterStateNotifier, int>(
  'expect [0] when decrement is called and seed: 1',
  provider: counterStateNotifierProvider,
  act: (notifier) => notifier.decrement(),
  seed: 1,
  wait: const Duration(milliseconds: 100),
  expect: () => <int>[0],
);

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

```