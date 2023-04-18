import 'dart:async';

import 'package:meta/meta.dart';
import 'package:riverpod/riverpod.dart'
    show Override, ProviderBase, ProviderContainer;
import 'package:riverpod_test/src/diff.dart';
import 'package:test/test.dart' as test;

/// Creates a new `Result Provider` test case with the given [description].
/// [testResultProvider] will handle asserting that the `provider result` 
/// emits the [expect]ed after [act] is executed.
///
/// [setUp] is optional and should be used to set up
/// any dependencies prior to initializing the `provider` under test.
/// [setUp] should be used to set up state necessary for a particular test case.
/// For common set up code, prefer to use `setUp` from `package:test/test.dart`.
///
/// [provider] should construct and return the `provider result` under test.
/// 
/// [overrides] list of [Override] to override providers behavior.
/// 
/// [act] is an optional callback which will be invoked with the `provider`
/// under test and should be used to interact with the [Result].
///
/// [expect] is an optional `Function` that returns a `Matcher` which the 
/// `result provider` under test is expected to emit after [act] is executed.
///
/// [verify] is an optional callback which is invoked after [expect]
/// and can be used for additional verification/assertions.
///
/// [errors] is an optional `Function` that returns a `Matcher` which the 
/// `provider` under test is expected to throw.
///
/// [tearDown] is optional and can be used to
/// execute any code after the test has run.
/// [tearDown] should be used to clean up after a particular test case.
/// For common tear down code, prefer to use `tearDown` from `package:test/test.dart`.
///
/// ```dart
/// testResultProvider(
///   'expect [1] when incrementCounter is called',
///   provider: repositoryProvider,
///   act: (result) => result.incrementCounter(),
///   expect: () => [1],
/// );
/// ```
/// 
/// [testResultProvider] can also be used to [overrides] to override 
/// providers behavior.
/// 
/// ```dart
/// testResultProvider(
///   'expect [2] when incrementCounter is called and mockRepository return 2',
///   setUp: () => when(mockRepository.increment).thenReturn(2),
///   provider: repositoryProvider,
///   overrides: [repositoryProvider.overrideWithValue(mockRepository)]
///   act: (result) => result.incrementCounter(),
///   expect: () => [2],
/// );
/// ```
///
/// [testResultProvider] can also be used to [verify] internal functionality.
///
/// ```dart
/// testResultProvider(
///   'verify if decrementCounter is called',
///   provider: futureProvider,
///   overrides: overrides,
///   setUp: () => when(mock.decrementCounter).thenAnswer((_) async => 20),
///   act: (result) => result.decrementCounter(),
///   verify: (_) {
///     verify(mock.decrementCounter).called(1);
///   }
/// );
/// ```
///
/// **Note:** when using [testResultProvider] with state classes which don't 
/// override `==` and `hashCode` you can provide an `Iterable` of matchers 
/// instead of explicit state instances.
///
/// ```dart
/// testResultProvider(
///  'expect [StateB] when getStateB is called',
///  provider: myProvider,
///  act: (result) => result.getStateB(),
///  expect: () => [StateB],
/// );
/// ```
///
@isTest
void testResultProvider<Result>(
  String description, {
  required ProviderBase<Result> provider,
  FutureOr<void> Function()? setUp,
  List<Override> overrides = const [],
  dynamic Function()? expect,
  dynamic Function(Result result)? verify,
  dynamic Function()? errors,
  FutureOr<void> Function(Result result)? tearDown,
  dynamic Function(Result result)? act,
}) {
  test.test(description, () async {
    await resultProviderTest<Result>(
      setUp: setUp,
      provider: provider,
      overrides: overrides,
      expect: expect,
      verify: verify,
      errors: errors,
      tearDown: tearDown,
      act: act,
    );
  });
}

/// Internal [testResultProvider] runner which is only visible for testing.
/// This should never be used directly, please use [testResultProvider] instead.
@visibleForTesting
Future<void> resultProviderTest<Result>({
  required ProviderBase<Result> provider,
  FutureOr<void> Function()? setUp,
  List<Override> overrides = const [],
  dynamic Function()? expect,
  dynamic Function(Result result)? verify,
  dynamic Function()? errors,
  FutureOr<void> Function(Result result)? tearDown,
  dynamic Function(Result result)? act,
}) async {
  final unhandledErrors = <Object>[];
  var shallowEquality = false;

  await runZonedGuarded(
    () async {
      await setUp?.call();
      final container = ProviderContainer(overrides: overrides);
      final result = container.read<Result>(provider);
      final values = <dynamic>[];
      try {
        final value = await act?.call(result);
        values.add(value);
      } catch (error) {
        if (errors == null) rethrow;
        unhandledErrors.add(error);
      }
      await Future<void>.delayed(Duration.zero);
      container.dispose();
      if (expect != null) {
        final dynamic expected = expect();
        shallowEquality = '$values' == '$expected';
        try {
          test.expect(values, test.wrapMatcher(expected));
        } on test.TestFailure catch (e) {
          if (shallowEquality || expected is! List<Object>) rethrow;
          final diff = testDiff(expected: expected, actual: values);
          final message = '${e.message}\n$diff';
          throw test.TestFailure(message);
        }
      }
      await verify?.call(result);
      await tearDown?.call(result);
    },
    (error, stack) {
      if (shallowEquality && error is test.TestFailure) {
        throw test.TestFailure(
          '''${error.message}
WARNING: Please ensure state instances extend Equatable, override == and hashCode, or implement Comparable.
Alternatively, consider using Matchers in the expect of the testResultProvider rather than concrete state instances.\n''',
        );
      }
      if (errors == null || !unhandledErrors.contains(error)) {
        throw error;
      }
    },
  );
  if (errors != null) test.expect(unhandledErrors, test.wrapMatcher(errors()));
}
