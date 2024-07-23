import 'dart:async';

import 'package:mocktail/mocktail.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_test/riverpod_test.dart';
import 'package:test/test.dart';

import '../mocks/mocks.dart';
import '../provider/provider.dart';

void main() {
  group('testProvider', () {
    group('counterProvider', () {
      testProvider<int>(
        'expect [0]',
        provider: counterProvider,
        expect: () => <int>[0],
      );

      testProvider<int>(
        'expect [5]',
        provider: familyCounterProvider(5),
        expect: () => <int>[5],
      );

      test('fails immediately when expectation is incorrect', () async {
        const expectedError = 'Expected: [1]\n'
            '  Actual: [0]\n'
            '   Which: at location [0] is <0> instead of <1>\n'
            '\n'
            '==== diff ========================================\n'
            '\n'
            // ignore: lines_longer_than_80_chars
            '\x1B[90m[\x1B[0m\x1B[31m[-1-]\x1B[0m\x1B[32m{+0+}\x1B[0m\x1B[90m]\x1B[0m\n'
            '\n'
            '==== end diff ====================================\n';
        try {
          await providerTest<int>(
            provider: counterProvider,
            expect: () => <int>[1],
            errors: Exception.new,
          );
        } catch (e) {
          expect((e as TestFailure).message, expectedError);
        }
      });
    });

    group('futureProvider', () {
      late MockComplexRepository mockRepository;
      final overrides = <Override>[];

      setUp(() {
        mockRepository = MockComplexRepository();
        overrides.add(
          complexRepositoryProvider.overrideWithValue(mockRepository),
        );
      });

      testProvider<AsyncValue<int>>(
        'expect [AsyncLoading(), AsyncData(1)]',
        provider: futureProvider,
        overrides: overrides,
        setUp: () => when(mockRepository.fetchCounter).thenAnswer((_) async => 1),
        expect: () => <AsyncValue<int>>[
          const AsyncLoading(),
          const AsyncData(1),
        ],
        tearDown: overrides.clear,
      );

      testProvider<AsyncValue<List<int>>>(
        'expect [AsyncLoading(), AsyncData([])]',
        provider: futureListProvider,
        overrides: overrides,
        setUp: () => when(mockRepository.fetchCounterList).thenAnswer((_) async => []),
        expect: () => <AsyncValue<List<int>>>[
          const AsyncLoading(),
          const AsyncData([]),
        ],
        tearDown: overrides.clear,
      );

      testProvider<AsyncValue<int>>(
        'excpect [AsyncLoading(), AsyncData(10)]',
        provider: familyFutureProvider(10),
        wait: const Duration(milliseconds: 100),
        expect: () => <AsyncValue<int>>[
          const AsyncLoading(),
          const AsyncData(10),
        ],
      );

      test('fails immediately when verify is incorrect', () async {
        const expectedError = '''Expected: <2>\n  Actual: <1>\nUnexpected number of calls\n''';
        try {
          await providerTest<AsyncValue<int>>(
            provider: futureProvider,
            overrides: overrides,
            verify: () => verify(mockRepository.fetchCounter).called(2),
            tearDown: overrides.clear,
          );
        } catch (e) {
          expect((e as TestFailure).message, expectedError);
        }
      });

      test('shows equality warning when strings are identical', () async {
        const expectedError = '''Expected: [Instance of 'CounterDataSource']
  Actual: [Instance of 'CounterDataSource']
   Which: at location [0] is <Instance of 'CounterDataSource'> instead of <Instance of 'CounterDataSource'>\n
WARNING: Please ensure state instances extend Equatable, override == and hashCode, or implement Comparable.
Alternatively, consider using Matchers in the expect of the testProvider rather than concrete state instances.\n''';
        try {
          await providerTest<CounterDataSource>(
            provider: counterDataSourceProvider,
            expect: () => <CounterDataSource>[CounterDataSource()],
          );
        } catch (e) {
          expect((e as TestFailure).message, expectedError);
        }
      });
    });

    group('streamProvider', () {
      testProvider<AsyncValue<int>>(
        'expect [AsyncLoading(), AsyncData(0), AsyncData(1)]',
        provider: streamProvider,
        expect: () => <AsyncValue<int>>[
          const AsyncLoading(),
          const AsyncData(0),
          const AsyncData(1),
        ],
      );

      testProvider<AsyncValue<int>>(
        'expect [AsyncLoading(), AsyncData(0), AsyncData(1), AsyncData(2)]',
        provider: familysStreamProvider(3),
        wait: const Duration(milliseconds: 100),
        expect: () => <AsyncValue<int>>[
          const AsyncLoading(),
          const AsyncData(0),
          const AsyncData(1),
          const AsyncData(2),
        ],
      );
    });

    group('familyExceptionProvider', () {
      final exception = Exception('oops');

      testProvider<int>(
        'errors supports matchers',
        provider: familyExceptionProvider(exception),
        errors: () => contains(exception),
      );

      testProvider<int>(
        'captures uncaught exceptions',
        provider: familyExceptionProvider(exception),
        errors: () => <Matcher>[equals(exception)],
      );
    });
  });
}
