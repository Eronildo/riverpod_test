import 'package:mocktail/mocktail.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_test/riverpod_test.dart';
import 'package:test/test.dart';

import '../mocks/mocks.dart';
import '../provider/provider.dart';

void main() {
  group('testResultProvider', () {
    group('repositoryProvider', () {
      testResultProvider<Repository>(
        'expect [null] when nothing is called',
        provider: repositoryProvider,
        expect: () => [isNull],
      );

      testResultProvider<Repository>(
        'expect [1] when incrementCounter is called',
        provider: repositoryProvider,
        act: (result) => result.incrementCounter(),
        expect: () => [1],
      );

      testResultProvider<Repository>(
        'expect null when nullFunction is called',
        provider: repositoryProvider,
        act: (result) => result.nullFunction(),
        expect: () => [isNull],
      );

      testResultProvider<Repository>(
        'expect void when voidFunction is called',
        provider: repositoryProvider,
        act: (result) => result.voidFunction(),
        expect: () => [isA<void>()],
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
          await resultProviderTest<Repository>(
            provider: repositoryProvider,
            act: (result) => result.incrementCounter(),
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
            await resultProviderTest<Repository>(
              provider: repositoryProvider,
              act: (result) => result.throwError(),
              expect: () => <int>[1],
            );
          } catch (e) {
            expect(e, isA<RepositoryError>());
          }
        },
      );

      test('fails immediately when exception occurs in act', () async {
        final exception = Exception('oops');

        try {
          await resultProviderTest<Repository>(
            provider: repositoryProvider,
            act: (_) => throw exception,
            expect: () => [1],
          );
        } catch (e) {
          expect(e, equals(exception));
        }
      });
    });

    group('complexRepositoryProvider', () {
      late MockCounterDataSouce mockDataSource;
      final overrides = <Override>[];

      setUp(() {
        mockDataSource = MockCounterDataSouce();
        overrides.add(
          counterDataSourceProvider.overrideWithValue(mockDataSource),
        );
      });

      testResultProvider<ComplexRepository>(
        'expect [null] when nothing is called',
        provider: complexRepositoryProvider,
        expect: () => [isNull],
      );

      testResultProvider<ComplexRepository>(
        'expect [10] when incrementCounter is called',
        provider: complexRepositoryProvider,
        overrides: overrides,
        setUp: () =>
            when(mockDataSource.incrementCounter).thenAnswer((_) async => 10),
        act: (result) => result.incrementCounter(),
        expect: () => [10],
        tearDown: (_) => overrides.clear(),
      );

      testResultProvider<ComplexRepository>(
        'verify if decrementCounter is called and call dispose on tearDown',
        provider: complexRepositoryProvider,
        overrides: overrides,
        setUp: () {
          when(mockDataSource.decrementCounter).thenAnswer((_) async => 20);
          when(mockDataSource.dispose).thenReturn(null);
        },
        act: (result) => result.decrementCounter(),
        verify: (_) => verify(mockDataSource.decrementCounter).called(1),
        tearDown: (result) {
          result.dispose();
          overrides.clear();
        },
      );

      test('fails immediately when verify is incorrect', () async {
        const expectedError =
            '''Expected: <2>\n  Actual: <1>\nUnexpected number of calls\n''';
        try {
          await resultProviderTest<ComplexRepository>(
            provider: complexRepositoryProvider,
            overrides: overrides,
            setUp: () => when(mockDataSource.incrementCounter)
                .thenAnswer((_) async => 10),
            act: (result) => result.incrementCounter(),
            verify: (_) => verify(mockDataSource.incrementCounter).called(2),
            tearDown: (_) => overrides.clear(),
          );
        } catch (e) {
          expect((e as TestFailure).message, expectedError);
        }
      });

      test('shows equality warning when strings are identical', () async {
        const expectedError = '''Expected: [Instance of 'ComplexA']
  Actual: [Instance of 'ComplexA']
   Which: at location [0] is <Instance of 'ComplexA'> instead of <Instance of 'ComplexA'>\n
WARNING: Please ensure state instances extend Equatable, override == and hashCode, or implement Comparable.
Alternatively, consider using Matchers in the expect of the testResultProvider rather than concrete state instances.\n''';
        try {
          await resultProviderTest<Repository>(
            provider: repositoryProvider,
            act: (result) => result.getComplexA(),
            expect: () => <Complex>[ComplexA()],
          );
        } catch (e) {
          expect((e as TestFailure).message, expectedError);
        }
      });
    });

    group('ExceptionNotifier', () {
      final exception = Exception('oops');

      testResultProvider<ExceptionRepository>(
        'errors supports matchers',
        provider: familyExceptionRepositoryProvider(exception),
        act: (result) => result.throwException(),
        errors: () => contains(exception),
      );

      testResultProvider<ExceptionRepository>(
        'captures uncaught exceptions',
        provider: familyExceptionRepositoryProvider(exception),
        act: (result) => result.throwException(),
        errors: () => <Matcher>[equals(exception)],
      );
    });
  });
}
