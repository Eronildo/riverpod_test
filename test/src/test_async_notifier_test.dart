import 'dart:async';

import 'package:mocktail/mocktail.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_test/riverpod_test.dart';
import 'package:test/test.dart';

import '../async_notifier/async_notifier.dart';
import '../mocks/mocks.dart';
import '../provider/provider.dart';

void main() {
  group('testAsyncNotifier', () {
    group('CounterAsyncNotifier', () {
      testAsyncNotifier<CounterAsyncNotifier, int>(
        'supports matchers (contains)',
        provider: counterAsyncNotifierProvider(0),
        act: (notifier) => notifier.increment(),
        expect: () => contains(const AsyncData(1)),
      );

      testAsyncNotifier<CounterAsyncNotifier, int>(
        'supports matchers (containsAll)',
        provider: counterAsyncNotifierProvider(0),
        act: (notifier) => notifier
          ..increment()
          ..increment(),
        expect: () => containsAll(
          <AsyncValue<int>>[
            const AsyncData(1),
            const AsyncData(2),
          ],
        ),
      );

      testAsyncNotifier<CounterAsyncNotifier, int>(
        'supports matchers (containsAllInOrder)',
        provider: counterAsyncNotifierProvider(0),
        act: (notifier) => notifier
          ..increment()
          ..increment(),
        expect: () => containsAllInOrder(
          <AsyncValue<int>>[
            const AsyncData(1),
            const AsyncData(2),
          ],
        ),
      );

      testAsyncNotifier<CounterAsyncNotifier, int>(
        'expect [] when nothing is called',
        provider: counterAsyncNotifierProvider(0),
        expect: () => const <AsyncValue<int>>[],
      );

      testAsyncNotifier<CounterAsyncNotifier, int>(
        'expect [AsyncData(1)] when call increment',
        provider: counterAsyncNotifierProvider(0),
        act: (notifier) => notifier.increment(),
        expect: () => <AsyncValue<int>>[const AsyncData(1)],
      );

      testAsyncNotifier<CounterAsyncNotifier, int>(
        'expect [AsyncData(1)] when call increment with async act',
        provider: counterAsyncNotifierProvider(0),
        act: (notifier) async {
          await Future<void>.delayed(const Duration(seconds: 1));
          notifier.increment();
        },
        expect: () => <AsyncValue<int>>[const AsyncData(1)],
      );

      testAsyncNotifier<CounterAsyncNotifier, int>(
        'expect [AsyncData(1), AsyncData(2)] when call increment multiple times'
        ' with async act',
        provider: counterAsyncNotifierProvider(0),
        act: (notifier) async {
          notifier.increment();
          await Future<void>.delayed(const Duration(milliseconds: 10));
          notifier.increment();
        },
        expect: () => <AsyncValue<int>>[const AsyncData(1), const AsyncData(2)],
      );

      testAsyncNotifier<CounterAsyncNotifier, int>(
        'expect [AsyncData(2)] when call increment twice and skip: 1',
        provider: counterAsyncNotifierProvider(0),
        act: (notifier) => notifier
          ..increment()
          ..increment(),
        skip: 1,
        expect: () => <AsyncValue<int>>[const AsyncData(2)],
      );

      testAsyncNotifier<CounterAsyncNotifier, int>(
        'expect [AsyncData(11)] when call increment and seed: AsyncData(10)',
        provider: counterAsyncNotifierProvider(0),
        act: (notifier) => notifier.increment(),
        seed: const AsyncData(10),
        expect: () => contains(const AsyncData(11)),
      );

      test('fails immediately when expectation is incorrect', () async {
        const expectedError =
            'Expected: [AsyncData<int>:AsyncData<int>(value: 2)]\n'
            '  Actual: [AsyncData<int>:AsyncData<int>(value: 1)]\n'
            '   Which: at location [0] is '
            'AsyncData<int>:<AsyncData<int>(value: 1)> instead of '
            'AsyncData<int>:<AsyncData<int>(value: 2)>\n'
            '\n'
            '==== diff ========================================\n'
            '\n'
            '\x1B[90m[AsyncData<int>(value: '
            '\x1B[0m\x1B[31m[-2-]\x1B[0m\x1B[32m{+1+}\x1B[0m\x1B[90m)]\x1B[0m\n'
            '\n'
            '==== end diff ====================================\n';
        late Object actualError;
        final completer = Completer<void>();
        await runZonedGuarded(
          () async {
            unawaited(
              asyncNotifierTest<CounterAsyncNotifier, int>(
                provider: counterAsyncNotifierProvider(0),
                act: (notifier) => notifier.increment(),
                expect: () => <AsyncValue<int>>[const AsyncData<int>(2)],
                errors: Exception.new,
              ).then((_) => completer.complete()),
            );
            await completer.future;
          },
          (Object error, _) {
            actualError = error;
            if (!completer.isCompleted) completer.complete();
          },
        );
        expect((actualError as TestFailure).message, expectedError);
      });

      test(
        'fails immediately when '
        'uncaught exception occurs within notifier',
        () async {
          late Object actualError;
          final completer = Completer<void>();
          await runZonedGuarded(
            () async {
              unawaited(
                asyncNotifierTest<ErrorCountAsyncNotifier, int>(
                  provider: errorCountAsyncNotifierProvider,
                  act: (notifier) => notifier.increment(),
                  expect: () => <AsyncValue<int>>[const AsyncData<int>(1)],
                ).then((_) => completer.complete()),
              );
              await completer.future;
            },
            (Object error, _) {
              actualError = error;
              if (!completer.isCompleted) completer.complete();
            },
          );
          expect(actualError, isA<ErrorCounterNotifierError>());
        },
      );

      test('fails immediately when exception occurs in act', () async {
        final exception = Exception('oops');
        late Object actualError;
        final completer = Completer<void>();
        await runZonedGuarded(
          () async {
            unawaited(
              asyncNotifierTest<ErrorCountAsyncNotifier, int>(
                provider: errorCountAsyncNotifierProvider,
                act: (_) => throw exception,
                expect: () => [const AsyncData<int>(1)],
              ).then((_) => completer.complete()),
            );
            await completer.future;
          },
          (Object error, _) {
            actualError = error;
            if (!completer.isCompleted) completer.complete();
          },
        );
        expect(actualError, exception);
      });
    });

    group('AsyncCounterAsyncNotifier', () {
      testAsyncNotifier<AsyncCounterAsyncNotifier, int>(
        'expect [] when nothing is called',
        provider: asyncCounterAsyncNotifierProvider,
        expect: () => const <AsyncValue<int>>[],
      );

      testAsyncNotifier<AsyncCounterAsyncNotifier, int>(
        'expect [AsyncData(1)] when increment is called',
        provider: asyncCounterAsyncNotifierProvider,
        act: (notifier) => notifier.increment(),
        expect: () => const <AsyncValue<int>>[AsyncData(1)],
      );

      testAsyncNotifier<AsyncCounterAsyncNotifier, int>(
        'expect [AsyncData(1), AsyncData(2)] when increment is called multiple '
        'times with async act',
        provider: asyncCounterAsyncNotifierProvider,
        act: (notifier) async {
          await notifier.increment();
          await Future<void>.delayed(const Duration(milliseconds: 10));
          await notifier.increment();
        },
        expect: () => const <AsyncValue<int>>[AsyncData(1), AsyncData(2)],
      );

      testAsyncNotifier<AsyncCounterAsyncNotifier, int>(
        'expect [AsyncData(2)] when increment is called twice and skip: 1',
        provider: asyncCounterAsyncNotifierProvider,
        skip: 1,
        act: (notifier) => notifier
          ..increment()
          ..increment(),
        expect: () => const <AsyncValue<int>>[AsyncData(2)],
      );

      testAsyncNotifier<AsyncCounterAsyncNotifier, int>(
        'expect [AsyncData(11)] when increment is called '
        'and seed: AsyncData(10)',
        provider: asyncCounterAsyncNotifierProvider,
        seed: const AsyncData(10),
        act: (notifier) => notifier.increment(),
        expect: () => const <AsyncValue<int>>[AsyncData(11)],
      );
    });

    group('DebounceCounterNotifier', () {
      testAsyncNotifier<DebounceCounterNotifier, int>(
        'expect [] when nothing is called',
        provider: debounceCounterAsyncNotifierProvider,
        expect: () => const <AsyncValue<int>>[],
      );

      testAsyncNotifier<DebounceCounterNotifier, int>(
        'expect [AsyncData(1)] when increment is called',
        provider: debounceCounterAsyncNotifierProvider,
        act: (notifier) => notifier.increment(),
        wait: const Duration(milliseconds: 300),
        expect: () => const <AsyncValue<int>>[AsyncData(1)],
      );

      testAsyncNotifier<DebounceCounterNotifier, int>(
        'expect [AsyncData(2)] when increment is called twice and skip: 1',
        provider: debounceCounterAsyncNotifierProvider,
        act: (notifier) async {
          await notifier.increment();
          await Future<void>.delayed(const Duration(milliseconds: 305));
          await notifier.increment();
        },
        skip: 1,
        wait: const Duration(milliseconds: 300),
        expect: () => const <AsyncValue<int>>[AsyncData(2)],
      );

      testAsyncNotifier<DebounceCounterNotifier, int>(
        'expect [AsyncData(11)] when increment is called with '
        'seed: AsyncData(10)',
        provider: debounceCounterAsyncNotifierProvider,
        act: (notifier) => notifier.increment(),
        seed: const AsyncData(10),
        wait: const Duration(milliseconds: 300),
        expect: () => const <AsyncValue<int>>[AsyncData(11)],
      );
    });

    group('MultiCounterAsyncNotifier', () {
      testAsyncNotifier<MultiCounterAsyncNotifier, int>(
        'expect [] when nothing is called',
        provider: multiCounterAsyncNotifierProvider,
        expect: () => const <AsyncValue<int>>[],
      );

      testAsyncNotifier<MultiCounterAsyncNotifier, int>(
        'expect [AsyncData(1), AsyncData(2)] when increment is called',
        provider: multiCounterAsyncNotifierProvider,
        act: (notifier) => notifier.increment(),
        expect: () => const <AsyncValue<int>>[AsyncData(1), AsyncData(2)],
      );

      testAsyncNotifier<MultiCounterAsyncNotifier, int>(
        'expect [AsyncData(1), AsyncData(2), AsyncData(3), AsyncData(4)] when '
        'increment is called multiple times with async act',
        provider: multiCounterAsyncNotifierProvider,
        act: (notifier) async {
          notifier.increment();
          await Future<void>.delayed(const Duration(milliseconds: 10));
          notifier.increment();
        },
        expect: () => const <AsyncValue<int>>[
          AsyncData(1),
          AsyncData(2),
          AsyncData(3),
          AsyncData(4),
        ],
      );

      testAsyncNotifier<MultiCounterAsyncNotifier, int>(
        'expect [AsyncData(4)] when increment is called twice and skip: 3',
        provider: multiCounterAsyncNotifierProvider,
        act: (notifier) => notifier
          ..increment()
          ..increment(),
        skip: 3,
        expect: () => const <AsyncValue<int>>[AsyncData(4)],
      );

      testAsyncNotifier<MultiCounterAsyncNotifier, int>(
        'expect [AsyncData(11), AsyncData(12)] when increment is called '
        'with seed: AsyncData(10)',
        provider: multiCounterAsyncNotifierProvider,
        act: (notifier) => notifier.increment(),
        seed: const AsyncData(10),
        expect: () => const <AsyncValue<int>>[AsyncData(11), AsyncData(12)],
      );
    });

    group('ExceptionAsyncNotifier', () {
      final exception = Exception('oops');

      testAsyncNotifier<ExceptionAsyncNotifier, int>(
        'errors supports matchers',
        provider: exceptionAsyncNotifierProvider(1),
        act: (notifier) => notifier.throwException(exception),
        errors: () => contains(exception),
      );

      testAsyncNotifier<ExceptionAsyncNotifier, int>(
        'captures uncaught exceptions',
        provider: exceptionAsyncNotifierProvider(5),
        act: (notifier) => notifier.throwException(exception),
        errors: () => <Matcher>[equals(exception)],
      );
    });

    group('SideEffectAsyncNotifier', () {
      late MockRepository repository;
      final overrides = <Override>[];

      setUp(() {
        repository = MockRepository();
        overrides.add(repositoryProvider.overrideWithValue(repository));
      });

      testAsyncNotifier<SideEffectAsyncNotifier, int>(
        'expect [AsyncData(2)]',
        provider: sideEffectAsyncNotifierProvider(1),
        setUp: () => when(repository.sideEffect).thenReturn(null),
        overrides: overrides,
        act: (notifier) => notifier.increment(),
        expect: () => <AsyncValue<int>>[const AsyncData(2)],
        tearDown: overrides.clear,
      );

      testAsyncNotifier<SideEffectAsyncNotifier, int>(
        'expect [AsyncData(10)]',
        provider: sideEffectAsyncNotifierProvider(1),
        overrides: overrides,
        setUp: () => when(repository.incrementCounter).thenReturn(10),
        act: (notifier) => notifier.incrementByRepository(),
        expect: () => <AsyncValue<int>>[const AsyncData(10)],
        tearDown: overrides.clear,
      );

      test('fails immediately when verify is incorrect', () async {
        const expectedError =
            '''Expected: <2>\n  Actual: <1>\nUnexpected number of calls\n''';
        late Object actualError;
        final completer = Completer<void>();
        await runZonedGuarded(
          () async {
            unawaited(
              asyncNotifierTest<SideEffectAsyncNotifier, int>(
                provider: sideEffectAsyncNotifierProvider(1),
                overrides: overrides,
                act: (notifier) => notifier.increment(),
                verify: (_) => verify(repository.sideEffect).called(2),
                tearDown: overrides.clear,
              ).then((_) => completer.complete()),
            );
            await completer.future;
          },
          (Object error, _) {
            actualError = error;
            if (!completer.isCompleted) completer.complete();
          },
        );
        expect((actualError as TestFailure).message, expectedError);
      });

      test('shows equality warning when strings are identical', () async {
        const expectedError =
            '''Expected: [\n            AsyncData<ComplexState>:AsyncData<ComplexState>(value: Instance of 'ComplexStateA')\n          ]
  Actual: [\n            AsyncData<ComplexState>:AsyncData<ComplexState>(value: Instance of 'ComplexStateA')\n          ]
   Which: at location [0] is AsyncData<ComplexState>:<AsyncData<ComplexState>(value: Instance of 'ComplexStateA')> instead of AsyncData<ComplexState>:<AsyncData<ComplexState>(value: Instance of 'ComplexStateA')>\n
WARNING: Please ensure state instances extend Equatable, override == and hashCode, or implement Comparable.
Alternatively, consider using Matchers in the expect of the testAsyncNotifier rather than concrete state instances.\n''';
        late Object actualError;
        final completer = Completer<void>();
        await runZonedGuarded(
          () async {
            unawaited(
              asyncNotifierTest<ComplexAsyncNotifier, ComplexState>(
                provider: complexAsyncNotifierProvider,
                act: (notifier) => notifier.setComplexStateA(),
                expect: () => <AsyncValue<ComplexState>>[
                  AsyncData(ComplexStateA()),
                ],
              ).then((_) => completer.complete()),
            );
            await completer.future;
          },
          (Object error, _) {
            actualError = error;
            completer.complete();
          },
        );
        expect((actualError as TestFailure).message, expectedError);
      });
    });
  });

  group('tearDown', () {
    late int tearDownCallCount;
    AsyncValue<int>? state;

    setUp(() {
      tearDownCallCount = 0;
    });

    tearDown(() {
      expect(tearDownCallCount, equals(1));
    });

    testAsyncNotifier<CounterAsyncNotifier, int>(
      'is called after the test is run',
      provider: counterAsyncNotifierProvider(0),
      act: (notifier) => notifier.increment(),
      expect: () => contains(const AsyncData(1)),
      // ignore: invalid_use_of_protected_member
      verify: (notifier) => state = notifier.state,
      tearDown: () {
        tearDownCallCount++;
        expect(state, equals(const AsyncData(1)));
      },
    );
  });
}
