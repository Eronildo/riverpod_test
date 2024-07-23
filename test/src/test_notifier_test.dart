import 'dart:async';

import 'package:mocktail/mocktail.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_test/riverpod_test.dart';
import 'package:test/test.dart';

import '../mocks/mocks.dart';
import '../notifier/notifier.dart';
import '../provider/provider.dart';

void main() {
  group('testNotifier', () {
    group('CounterNotifier', () {
      testNotifier<CounterNotifier, int>(
        'expect [] when nothing is called',
        provider: counterNotifierProvider,
        expect: () => <int>[],
      );

      testNotifier<CounterNotifier, int>(
        'expect [1] when increment is called',
        provider: counterNotifierProvider,
        act: (notifier) => notifier.increment(),
        expect: () => <int>[1],
      );

      testNotifier<CounterNotifier, int>(
        'expect [1, 2] when increment is called multiple times',
        provider: counterNotifierProvider,
        act: (notifier) => notifier
          ..increment()
          ..increment(),
        expect: () => <int>[1, 2],
      );

      testNotifier<CounterNotifier, int>(
        'expect [3] when increment is called and seed is 2',
        provider: counterNotifierProvider,
        seed: 2,
        act: (notifier) => notifier.increment(),
        expect: () => <int>[3],
      );

      test('fails immediately when expectation is incorrect', () async {
        const expectedError = 'Expected: [2]\n'
            '  Actual: [1]\n'
            '   Which: at location [0] is <1> instead of <2>\n'
            '\n'
            '==== diff ========================================\n'
            '\n'
            // ignore: lines_longer_than_80_chars
            '\x1B[90m[\x1B[0m\x1B[31m[-2-]\x1B[0m\x1B[32m{+1+}\x1B[0m\x1B[90m]\x1B[0m\n'
            '\n'
            '==== end diff ====================================\n';
        try {
          await notifierTest<CounterNotifier, int>(
            provider: counterNotifierProvider,
            act: (notifier) => notifier.increment(),
            expect: () => <int>[2],
            errors: Exception.new,
          );
        } catch (e) {
          expect((e as TestFailure).message, expectedError);
        }
      });

      test(
        'fails immediately when '
        'uncaught exception occurs within notifier',
        () async {
          try {
            await notifierTest<ErrorCounterNotifier, int>(
              provider: errorNotifierProvider,
              act: (notifier) => notifier.increment(),
              expect: () => <int>[1],
            );
          } catch (e) {
            expect(e, isA<CounterNotifierError>());
          }
        },
      );

      test('fails immediately when exception occurs in act', () async {
        final exception = Exception('oops');

        try {
          await notifierTest<ErrorCounterNotifier, int>(
            provider: errorNotifierProvider,
            act: (_) => throw exception,
            expect: () => [1],
          );
        } catch (e) {
          expect(e, equals(exception));
        }
      });
    });

    group('AsyncCounterNotifier', () {
      testNotifier<AsyncCounterNotifier, int>(
        'expect [] when nothing is called',
        provider: asyncCounterNotifierProvider,
        expect: () => <int>[],
      );

      testNotifier<AsyncCounterNotifier, int>(
        'expect [1] when increment is called',
        provider: asyncCounterNotifierProvider,
        act: (notifier) => notifier.increment(),
        expect: () => <int>[1],
      );

      testNotifier<AsyncCounterNotifier, int>(
        'expect [1, 2] when increment is called multiple '
        'times with async act',
        provider: asyncCounterNotifierProvider,
        act: (notifier) async {
          await notifier.increment();
          await notifier.increment();
        },
        expect: () => <int>[1, 2],
      );
    });

    group('DelayedCounterNotifier', () {
      testNotifier<DelayedCounterNotifier, int>(
        'expect [] when nothing is called',
        provider: delayedCounterNotifierProvider,
        expect: () => <int>[],
      );

      testNotifier<DelayedCounterNotifier, int>(
        'expect [] when increment is called without wait',
        provider: delayedCounterNotifierProvider,
        act: (notifier) => notifier.increment(),
        expect: () => <int>[],
      );

      testNotifier<DelayedCounterNotifier, int>(
        'expect [1] when increment is called with wait',
        provider: delayedCounterNotifierProvider,
        act: (notifier) => notifier.increment(),
        wait: const Duration(milliseconds: 300),
        expect: () => <int>[1],
      );
    });

    group('MultiCounterNotifier', () {
      testNotifier<MultiCounterNotifier, int>(
        'expect [] when nothing is called',
        provider: multiCounterNotifierProvider,
        expect: () => <int>[],
      );

      testNotifier<MultiCounterNotifier, int>(
        'expect [1, 2] when increment is called',
        provider: multiCounterNotifierProvider,
        act: (notifier) => notifier.increment(),
        expect: () => <int>[1, 2],
      );

      testNotifier<MultiCounterNotifier, int>(
        'expect [1, 2, 3, 4] when increment is called '
        'multiple times',
        provider: multiCounterNotifierProvider,
        act: (notifier) => notifier
          ..increment()
          ..increment(),
        expect: () => <int>[1, 2, 3, 4],
      );
    });

    group('ComplexNotifier', () {
      testNotifier<ComplexNotifier, ComplexState>(
        'expect [] when nothing is called',
        provider: complexNotifierProvider,
        expect: () => <Matcher>[],
      );

      testNotifier<ComplexNotifier, ComplexState>(
        'expect [ComplexStateB] when emitB is called',
        provider: complexNotifierProvider,
        act: (notifier) => notifier.setComplexStateB(),
        expect: () => [isA<ComplexStateB>()],
      );
    });

    group('SideEffectCounterNotifier', () {
      late MockRepository repository;
      final overrides = <Override>[];

      setUp(() {
        repository = MockRepository();
        overrides.add(repositoryProvider.overrideWithValue(repository));
        when(repository.sideEffect).thenReturn(null);
      });

      testNotifier<SideEffectCounterNotifier, int>(
        'expect [] when nothing is called',
        provider: sideEffectCounterNotifierProvider,
        overrides: overrides,
        expect: () => <int>[],
        tearDown: overrides.clear,
      );

      testNotifier<SideEffectCounterNotifier, int>(
        'expect [10] when incrementByRepository is called',
        setUp: () => when(repository.incrementCounter).thenReturn(10),
        provider: sideEffectCounterNotifierProvider,
        overrides: overrides,
        act: (notifier) => notifier.incrementByRepository(),
        expect: () => <int>[10],
        verify: (_) => verify(repository.incrementCounter).called(1),
        tearDown: overrides.clear,
      );

      testNotifier<SideEffectCounterNotifier, int>(
        'does not require an expect',
        provider: sideEffectCounterNotifierProvider,
        overrides: overrides,
        act: (notifier) => notifier.increment(),
        verify: (_) => verify(repository.sideEffect).called(1),
        tearDown: overrides.clear,
      );

      test('fails immediately when verify is incorrect', () async {
        const expectedError = '''Expected: <2>\n  Actual: <1>\nUnexpected number of calls\n''';
        try {
          await notifierTest<SideEffectCounterNotifier, int>(
            provider: sideEffectCounterNotifierProvider,
            overrides: overrides,
            act: (notifier) => notifier.increment(),
            verify: (_) => verify(repository.sideEffect).called(2),
            tearDown: overrides.clear,
          );
        } catch (e) {
          expect((e as TestFailure).message, expectedError);
        }
      });

      test('shows equality warning when strings are identical', () async {
        const expectedError = '''Expected: [Instance of 'ComplexStateA']
  Actual: [Instance of 'ComplexStateA']
   Which: at location [0] is <Instance of 'ComplexStateA'> instead of <Instance of 'ComplexStateA'>\n
WARNING: Please ensure state instances extend Equatable, override == and hashCode, or implement Comparable.
Alternatively, consider using Matchers in the expect of the testNotifier rather than concrete state instances.\n''';
        try {
          await notifierTest<ComplexNotifier, ComplexState>(
            provider: complexNotifierProvider,
            act: (notifier) => notifier.setComplexStateA(),
            expect: () => <ComplexState>[ComplexStateA()],
          );
        } catch (e) {
          expect((e as TestFailure).message, expectedError);
        }
      });
    });

    group('ExceptionNotifier', () {
      final exception = Exception('oops');

      testNotifier<ExceptionNotifier, int>(
        'errors supports matchers',
        provider: exceptionNotifierProvider,
        act: (notifier) => notifier.throwException(exception),
        errors: () => contains(exception),
      );

      testNotifier<ExceptionNotifier, int>(
        'captures uncaught exceptions',
        provider: exceptionNotifierProvider,
        act: (notifier) => notifier.throwException(exception),
        errors: () => <Matcher>[equals(exception)],
      );
    });

    group('CounterAutoDisposeNotifier', () {
      testNotifier<CounterAutoDisposeNotifier, int>(
        'expect [] when nothing is called',
        provider: counterAutoDisposeNotifierProvider,
        expect: () => <int>[],
      );

      testNotifier<CounterAutoDisposeNotifier, int>(
        'expect [1] when increment is called',
        provider: counterAutoDisposeNotifierProvider,
        act: (notifier) => notifier.increment(),
        expect: () => <int>[1],
      );

      testNotifier<CounterAutoDisposeNotifier, int>(
        'expect [1, 2] when increment is called multiple times',
        provider: counterAutoDisposeNotifierProvider,
        act: (notifier) => notifier
          ..increment()
          ..increment(),
        expect: () => <int>[1, 2],
      );

      testNotifier<CounterAutoDisposeNotifier, int>(
        'expect [3] when increment is called and seed is 2',
        provider: counterAutoDisposeNotifierProvider,
        seed: 2,
        act: (notifier) => notifier.increment(),
        expect: () => <int>[3],
      );
    });

    group('CounterFamilyNotifier', () {
      testNotifier<CounterFamilyNotifier, int>(
        'expect [] when nothing is called',
        provider: counterFamilyNotifierProvider(0),
        expect: () => <int>[],
      );

      testNotifier<CounterFamilyNotifier, int>(
        'expect [1] when increment is called',
        provider: counterFamilyNotifierProvider(0),
        act: (notifier) => notifier.increment(),
        expect: () => <int>[1],
      );

      testNotifier<CounterFamilyNotifier, int>(
        'expect [1, 2] when increment is called multiple times',
        provider: counterFamilyNotifierProvider(0),
        act: (notifier) => notifier
          ..increment()
          ..increment(),
        expect: () => <int>[1, 2],
      );

      testNotifier<CounterFamilyNotifier, int>(
        'expect [3] when increment is called and seed is 2',
        provider: counterFamilyNotifierProvider(0),
        seed: 2,
        act: (notifier) => notifier.increment(),
        expect: () => <int>[3],
      );
    });

    group('CounterAutoDisposeFamilyNotifier', () {
      testNotifier<CounterAutoDisposeFamilyNotifier, int>(
        'expect [] when nothing is called',
        provider: counterAutoDisposeFamilyNotifierProvider(0),
        expect: () => <int>[],
      );

      testNotifier<CounterAutoDisposeFamilyNotifier, int>(
        'expect [1] when increment is called',
        provider: counterAutoDisposeFamilyNotifierProvider(0),
        act: (notifier) => notifier.increment(),
        expect: () => <int>[1],
      );

      testNotifier<CounterAutoDisposeFamilyNotifier, int>(
        'expect [1, 2] when increment is called multiple times',
        provider: counterAutoDisposeFamilyNotifierProvider(0),
        act: (notifier) => notifier
          ..increment()
          ..increment(),
        expect: () => <int>[1, 2],
      );

      testNotifier<CounterAutoDisposeFamilyNotifier, int>(
        'expect [3] when increment is called and seed is 2',
        provider: counterAutoDisposeFamilyNotifierProvider(0),
        seed: 2,
        act: (notifier) => notifier.increment(),
        expect: () => <int>[3],
      );
    });
  });
}
