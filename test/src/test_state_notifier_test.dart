import 'package:mocktail/mocktail.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_test/riverpod_test.dart';
import 'package:test/test.dart';

import '../mocks/mocks.dart';
import '../provider/provider.dart';
import '../state_notifier/state_notifier.dart';

void main() {
  group('testStateNotifier', () {
    group('CounterStateNotifier', () {
      testStateNotifier<CounterStateNotifier, int>(
        'expect [1]',
        provider: counterStateNotifierProvider,
        act: (notifier) => notifier.increment(),
        expect: () => <int>[1],
      );

      testStateNotifier<CounterStateNotifier, int>(
        'expect [0] when decrement is called and seed: 1',
        provider: counterStateNotifierProvider,
        act: (notifier) => notifier.decrement(),
        seed: 1,
        wait: const Duration(milliseconds: 100),
        expect: () => <int>[0],
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
          await stateNotifierTest<CounterStateNotifier, int>(
            provider: counterStateNotifierProvider,
            act: (notifier) => notifier.increment(),
            expect: () => <int>[2],
            errors: Exception.new,
          );
        } catch (e) {
          expect((e as TestFailure).message, equals(expectedError));
        }
      });
    });

    group('ExceptionStateNotifier', () {
      final exception = Exception('oops');

      testStateNotifier<ExceptionStateNotifier, int>(
        'errors supports matchers',
        provider: exceptionStateNotifierProvider,
        act: (notifier) => notifier.throwException(exception),
        errors: () => contains(exception),
      );

      testStateNotifier<ExceptionStateNotifier, int>(
        'captures uncaught exceptions',
        provider: exceptionStateNotifierProvider,
        act: (notifier) => notifier.throwException(exception),
        errors: () => <Matcher>[equals(exception)],
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

      testStateNotifier<SideEffectStateNotifier, int>(
        'expect [] when nothing is called',
        provider: sideEffectStateNotifierProvider,
        overrides: overrides,
        expect: () => <int>[],
        tearDown: overrides.clear,
      );

      testStateNotifier<SideEffectStateNotifier, int>(
        'expect [10] when incrementByRepository is called',
        setUp: () => when(repository.incrementCounter).thenReturn(10),
        provider: sideEffectStateNotifierProvider,
        overrides: overrides,
        act: (notifier) => notifier.incrementByRepository(),
        expect: () => <int>[10],
        verify: () => verify(repository.incrementCounter).called(1),
        tearDown: overrides.clear,
      );

      testStateNotifier<SideEffectStateNotifier, int>(
        'does not require an expect',
        provider: sideEffectStateNotifierProvider,
        overrides: overrides,
        act: (notifier) => notifier.increment(),
        verify: () => verify(repository.sideEffect).called(1),
        tearDown: overrides.clear,
      );

      test('fails immediately when verify is incorrect', () async {
        const expectedError = '''Expected: <2>\n  Actual: <1>\nUnexpected number of calls\n''';

        try {
          await stateNotifierTest<SideEffectStateNotifier, int>(
            provider: sideEffectStateNotifierProvider,
            overrides: overrides,
            act: (notifier) => notifier.increment(),
            verify: () => verify(repository.sideEffect).called(2),
            tearDown: overrides.clear,
          );
        } catch (error) {
          expect((error as TestFailure).message, expectedError);
        }
      });

      test('shows equality warning when strings are identical', () async {
        const expectedError = '''Expected: [Instance of 'ComplexStateA']
  Actual: [Instance of 'ComplexStateA']
   Which: at location [0] is <Instance of 'ComplexStateA'> instead of <Instance of 'ComplexStateA'>\n
WARNING: Please ensure state instances extend Equatable, override == and hashCode, or implement Comparable.
Alternatively, consider using Matchers in the expect of the testStateNotifier rather than concrete state instances.\n''';
        try {
          await stateNotifierTest<ComplexStateNotifier, ComplexState>(
            provider: complexStateNotifierProvider,
            act: (notifier) => notifier.setComplexStateA(),
            expect: () => <ComplexState>[ComplexStateA()],
          );
        } catch (error) {
          expect((error as TestFailure).message, expectedError);
        }
      });
    });
  });
}
