import 'dart:async';

import 'package:meta/meta.dart';
import 'package:riverpod/riverpod.dart'
    show Override, ProviderBase, ProviderContainer;
import 'package:riverpod_test/src/async_list_equals.dart';
import 'package:riverpod_test/src/diff.dart';
import 'package:riverpod_test/src/run_zoned_wrapper.dart';
import 'package:test/test.dart' as test;

/// Creates a new `Provider` test case with the given [description].
/// [testProvider] will handle asserting that the `provider` emits the
/// [expect]ed after [provider] is read.
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
/// [wait] is an optional `Duration` which can be used to wait for
/// async operations within the `notifier` under test such as `debounce`.
///
/// [expect] is an optional `Function` that returns a `Matcher` which the
/// `provider` under test is expected.
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
/// testProvider(
///   'expect [0]',
///   provider: counterProvider,
///   expect: () => <int>[0],
/// );
/// ```
///
/// [testProvider] can also be used to [overrides] to override
/// providers behavior.
///
/// ```dart
/// testProvider(
///   'expect [10] when mockRepository increment return 10',
///   setUp: () => when(mockRepository.increment).thenReturn(10),
///   provider: counterProvider,
///   overrides: [repositoryProvider.overrideWithValue(mockRepository)]
///   expect: () => <int>[10],
/// );
/// ```
///
/// [testProvider] can also be used to wait for async operations
/// by optionally providing a `Duration` to [wait].
///
/// ```dart
/// testProvider(
///   'expect [AsyncLoading(), AsyncData(1)]',
///   provider: futureProvider,
///   wait: const Duration(milliseconds: 100),
///   expect: () => [AsyncLoading(), AsyncData(1)],
/// );
/// ```
///
/// [testProvider] can also be used to [verify] internal functionality.
///
/// ```dart
/// testProvider(
///   'verify if someMethod is called',
///   provider: futureProvider,
///   verify: (_) {
///     verify(() => repository.someMethod(any())).called(1);
///   }
/// );
/// ```
///
/// **Note:** when using [testProvider] with state classes which don't
/// override `==` and `hashCode` you can provide an `Iterable` of matchers
/// instead of explicit state instances.
///
/// ```dart
/// testProvider(
///  'expect [StateB]',
///  provider: myProvider,
///  expect: () => [StateB],
/// );
/// ```
///
@isTest
void testProvider<State>(
  String description, {
  required ProviderBase<State> provider,
  FutureOr<void> Function()? setUp,
  List<Override> overrides = const [],
  dynamic Function()? expect,
  Duration? wait,
  dynamic Function()? verify,
  dynamic Function()? errors,
  FutureOr<void> Function()? tearDown,
}) {
  test.test(description, () async {
    await providerTest<State>(
      setUp: setUp,
      provider: provider,
      overrides: overrides,
      wait: wait,
      expect: expect,
      verify: verify,
      errors: errors,
      tearDown: tearDown,
    );
  });
}

/// Internal [testProvider] runner which is only visible for testing.
/// This should never be used directly - please use [testProvider] instead.
@visibleForTesting
Future<void> providerTest<State>({
  required ProviderBase<State> provider,
  FutureOr<void> Function()? setUp,
  List<Override> overrides = const [],
  dynamic Function()? expect,
  Duration? wait,
  dynamic Function()? verify,
  dynamic Function()? errors,
  FutureOr<void> Function()? tearDown,
}) async {
  final unhandledErrors = <Object>[];
  var shallowEquality = false;

  try {
    await runZonedGuardedWrapper(
      () async {
        await setUp?.call();
        final container = ProviderContainer(overrides: overrides);
        final states = <State>[];

        try {
          container
            ..read<State>(provider)
            ..listen<State>(
              provider,
              (previous, next) => states.add(next),
              fireImmediately: true,
            );
        } catch (error) {
          if (errors == null) rethrow;
          unhandledErrors.add(error);
        }
        if (wait != null) await Future<void>.delayed(wait);
        await Future<void>.delayed(Duration.zero);
        container.dispose();
        if (expect != null) {
          final dynamic expected = expect();
          shallowEquality = '$states' == '$expected';
          try {
            final isAsyncListEquals =
                isAsyncDataListEquals(provider, states, expected);
            if (isAsyncListEquals) {
              test.expect(isAsyncListEquals, true);
            } else {
              test.expect(states, test.wrapMatcher(expected));
            }
          } on test.TestFailure catch (e) {
            if (shallowEquality || expected is! List<State>) rethrow;
            final diff = testDiff(expected: expected, actual: states);
            final message = '${e.message}\n$diff';
            throw test.TestFailure(message);
          }
        }
        await verify?.call();
        await tearDown?.call();
      },
    );
  } catch (error) {
    if (shallowEquality && error is test.TestFailure) {
      throw test.TestFailure(
        '''${error.message}
WARNING: Please ensure state instances extend Equatable, override == and hashCode, or implement Comparable.
Alternatively, consider using Matchers in the expect of the testProvider rather than concrete state instances.\n''',
      );
    }
    if (errors == null || !unhandledErrors.contains(error)) {
      throw error;
    }
  }

  if (errors != null) test.expect(unhandledErrors, test.wrapMatcher(errors()));
}
