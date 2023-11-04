// ignore_for_file: invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member

import 'dart:async';

import 'package:meta/meta.dart';
import 'package:riverpod/riverpod.dart'
    show AsyncValue, Override, ProviderContainer;
// ignore: implementation_imports
import 'package:riverpod/src/async_notifier.dart'
    show AsyncNotifierBase, AsyncNotifierProviderBase;
import 'package:riverpod_test/src/diff.dart';
import 'package:test/test.dart' as test;

/// Creates a new `AsyncNotifier` test case with the given [description].
/// [testAsyncNotifier] will handle asserting that the `notifier` emits the
/// [expect]ed states (in order) after [act] is executed.
/// [testAsyncNotifier] also handles ensuring that no additional states are
/// emitted by closing the [provider] before evaluating the [expect]ation.
///
/// [setUp] is optional and should be used to set up
/// any dependencies prior to initializing the `provider` under test.
/// [setUp] should be used to set up state necessary for a particular test case.
/// For common set up code, prefer to use `setUp` from `package:test/test.dart`.
///
/// [provider] should construct and return the `notifier` under test.
///
/// [overrides] list of [Override] to override providers behavior.
///
/// [seed] is an optional `Function` that returns a state
/// which will be used to seed the `notifier` before [act] is called.
///
/// [act] is an optional callback which will be invoked with the `notifier`
/// under test and should be used to interact with the `notifier`.
///
/// [skip] is an optional `int` which can be used to skip any number of states.
/// [skip] defaults to 0.
///
/// [wait] is an optional `Duration` which can be used to wait for
/// async operations within the `notifier` under test such as `debounce`.
///
/// [expect] is an optional `Function` that returns a `Matcher` which the
/// `notifier` under test is expected to emit after [act] is executed.
///
/// [verify] is an optional callback which is invoked after [expect]
/// and can be used for additional verification/assertions.
/// [verify] is called with the `notifier` returned by [provider].
///
/// [errors] is an optional `Function` that returns a `Matcher` which the
/// `notifier` under test is expected to throw after [act] is executed.
///
/// [tearDown] is optional and can be used to
/// execute any code after the test has run.
/// [tearDown] should be used to clean up after a particular test case.
/// For common tear down code, prefer to use `tearDown` from `package:test/test.dart`.
///
/// ```dart
/// testAsyncNotifier(
///   'expect [AsyncData(1)] when increment is called',
///   provider: counterProvider,
///   act: (notifier) => notifier.increment(),
///   expect: () => [AsyncData(1)],
/// );
/// ```
///
/// [testAsyncNotifier] can optionally be used with a seeded state.
///
/// ```dart
/// testAsyncNotifier(
///   'expect [AsyncData(10)] when seeded with AsyncData(9)',
///   provider: counterProvider,
///   seed: () => AsyncData(9),
///   act: (notifier) => notifier.increment(),
///   expect: () => [AsyncData(10)],
/// );
/// ```
///
/// [testAsyncNotifier] can also be used to [overrides] to override
/// providers behavior.
///
/// ```dart
/// testAsyncNotifier(
///   'expect [AsyncData(10)] when mockRepository increment return 10',
///   setUp: () => when(mockRepository.increment).thenReturn(10),
///   provider: counterProvider,
///   overrides: [repositoryProvider.overrideWithValue(mockRepository)]
///   act: (notifier) => notifier.increment(),
///   expect: () => [AsyncData(10)],
/// );
/// ```
///
/// [testAsyncNotifier] can also be used to [skip] any number of emitted states
/// before asserting against the expected states.
/// [skip] defaults to 0.
///
/// ```dart
/// testAsyncNotifier(
///   'expect [AsyncData(2)] when increment is called twice',
///   provider: counterProvider,
///   act: (notifier) => notifier
///       ..increment()
///       ..increment(),
///   skip: AsyncData(1),
///   expect: () => [AsyncData(2)],
/// );
/// ```
///
/// [testAsyncNotifier] can also be used to wait for async operations
/// by optionally providing a `Duration` to [wait].
///
/// ```dart
/// testAsyncNotifier(
///   'expect [AsyncData(1)] when increment is called',
///   provider: counterProvider,
///   act: (notifier) => notifier.increment(),
///   wait: const Duration(milliseconds: 300),
///   expect: () => [AsyncData(1)],
/// );
/// ```
///
/// [testAsyncNotifier] can also be used to [verify] internal functionality.
///
/// ```dart
/// testAsyncNotifier(
///   'expect [AsyncData(1)] when increment is called',
///   provider: counterProvider,
///   act: (notifier) => notifier.increment(),
///   expect: () => [AsyncData(1)],
///   verify: (_) {
///     verify(() => repository.someMethod(any())).called(1);
///   }
/// );
/// ```
///
/// **Note:** when using [testAsyncNotifier] with state classes which don't
/// override `==` and `hashCode` you can provide an `Iterable` of matchers
/// instead of explicit state instances.
///
/// ```dart
/// testAsyncNotifier(
///  'expect [AsyncData(StateB)] when setStateB is called',
///  provider: myProvider,
///  act: (notifier) => notifier.setStateB(),
///  expect: () => [AsyncData(StateB)],
/// );
/// ```
///
@isTest
void testAsyncNotifier<C extends AsyncNotifierBase<State>, State>(
  String description, {
  required AsyncNotifierProviderBase<C, State> provider,
  FutureOr<void> Function()? setUp,
  List<Override> overrides = const [],
  dynamic Function()? expect,
  AsyncValue<State>? seed,
  dynamic Function(C notifier)? act,
  Duration? wait,
  int skip = 0,
  dynamic Function(C notifier)? verify,
  dynamic Function()? errors,
  FutureOr<void> Function()? tearDown,
  bool emitBuildStates = false,
}) {
  test.test(description, () async {
    await asyncNotifierTest<C, State>(
      setUp: setUp,
      provider: provider,
      overrides: overrides,
      seed: seed,
      act: act,
      wait: wait,
      skip: skip,
      expect: expect,
      verify: verify,
      errors: errors,
      tearDown: tearDown,
      emitBuildStates: emitBuildStates,
    );
  });
}

/// Internal [testAsyncNotifier] runner which is only visible for testing.
/// This should never be used directly - please use [testAsyncNotifier] instead.
@visibleForTesting
Future<void> asyncNotifierTest<C extends AsyncNotifierBase<State>, State>({
  required AsyncNotifierProviderBase<C, State> provider,
  FutureOr<void> Function()? setUp,
  List<Override> overrides = const [],
  dynamic Function()? expect,
  AsyncValue<State>? seed,
  dynamic Function(C notifier)? act,
  Duration? wait,
  int skip = 0,
  dynamic Function(C notifier)? verify,
  dynamic Function()? errors,
  FutureOr<void> Function()? tearDown,
  bool emitBuildStates = false,
}) async {
  final unhandledErrors = <Object>[];
  var shallowEquality = false;

  await runZonedGuarded(
    () async {
      await setUp?.call();
      final container = ProviderContainer(overrides: overrides);
      final states = <AsyncValue<State>>[];
      container.listen<AsyncValue<State>>(
        provider,
        (previous, next) => states.add(next),
        fireImmediately: true,
      );
      final notifier = container.read(provider.notifier);
      // ignore: invalid_use_of_protected_member
      await notifier.future;
      // clear the states emitted by the build
      if (!emitBuildStates) states.clear();
      // applies seed in the state
      // ignore: invalid_use_of_protected_member
      if (seed != null) notifier.state = seed;
      try {
        await act?.call(notifier);
      } catch (error) {
        if (errors == null) rethrow;
        unhandledErrors.add(error);
      }
      if (wait != null) await Future<void>.delayed(wait);
      await Future<void>.delayed(Duration.zero);
      container.dispose();
      if (expect != null) {
        if (skip < 0) skip = 0;
        if (skip > states.length) skip = states.length;
        states.removeRange(0, skip);
        final dynamic expected = expect();
        // remove state return by seed
        if (seed != null && states.isNotEmpty) states.remove(seed);
        shallowEquality = '$states' == '$expected';
        try {
          test.expect(states, test.wrapMatcher(expected));
        } on test.TestFailure catch (e) {
          if (shallowEquality || expected is! List<AsyncValue<State>>) rethrow;
          final diff = testDiff(expected: expected, actual: states);
          final message = '${e.message}\n$diff';
          throw test.TestFailure(message);
        }
      }
      await verify?.call(notifier);
      await tearDown?.call();
    },
    (error, stack) {
      if (shallowEquality && error is test.TestFailure) {
        throw test.TestFailure(
          '''${error.message}
WARNING: Please ensure state instances extend Equatable, override == and hashCode, or implement Comparable.
Alternatively, consider using Matchers in the expect of the testAsyncNotifier rather than concrete state instances.\n''',
        );
      }
      if (errors == null || !unhandledErrors.contains(error)) {
        throw error;
      }
    },
  );
  if (errors != null) test.expect(unhandledErrors, test.wrapMatcher(errors()));
}
