import 'dart:async';

import 'package:meta/meta.dart';
import 'package:riverpod/riverpod.dart'
    show Override, ProviderContainer, StateNotifier, StateNotifierProvider;
import 'package:riverpod_test/src/diff.dart';
import 'package:test/test.dart' as test;

/// Creates a new `Notifier` test case with the given [description].
/// [testStateNotifier] will handle asserting that the `notifier` emits the
/// [expect]ed states (in order) after [act] is executed.
/// [testStateNotifier] also handles ensuring that no additional states are
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
/// testStateNotifier(
///   'expect [1] when increment is called',
///   provider: counterProvider,
///   act: (notifier) => notifier.increment(),
///   expect: () => [1],
/// );
/// ```
///
/// [testStateNotifier] can also be used to [overrides] to override
/// providers behavior.
///
/// ```dart
/// testStateNotifier(
///   'expect [2] when increment is called',
///   setUp: () => when(mockRepository.increment).thenReturn(2),
///   provider: counterProvider,
///   overrides: [repositoryProvider.overrideWithValue(mockRepository)]
///   act: (notifier) => notifier.increment(),
///   expect: () => [2],
/// );
/// ```
///
/// [testStateNotifier] can optionally be used with a seeded state.
///
/// ```dart
/// testStateNotifier(
///   'expect [10] when seeded with 9',
///   provider: counterProvider,
///   seed: () => 9,
///   act: (notifier) => notifier.increment(),
///   expect: () => [10],
/// );
/// ```
///
/// [testStateNotifier] can also be used to wait for async operations
/// by optionally providing a `Duration` to [wait].
///
/// ```dart
/// testStateNotifier(
///   'expect [1] when increment is called',
///   provider: counterProvider,
///   act: (notifier) => notifier.increment(),
///   wait: const Duration(milliseconds: 300),
///   expect: () => [1],
/// );
/// ```
///
/// [testStateNotifier] can also be used to [verify] internal functionality.
///
/// ```dart
/// testStateNotifier(
///   'expect [1] when increment is called',
///   provider: counterProvider,
///   act: (notifier) => notifier.increment(),
///   expect: () => [1],
///   verify: (_) {
///     verify(() => repository.someMethod(any())).called(1);
///   }
/// );
/// ```
///
/// **Note:** when using [testStateNotifier] with state classes which don't
/// override `==` and `hashCode` you can provide an `Iterable` of matchers
/// instead of explicit state instances.
///
/// ```dart
/// testStateNotifier(
///  'expect [StateB] when setStateB is called',
///  provider: myProvider,
///  act: (notifier) => notifier.setStateB(),
///  expect: () => [StateB],
/// );
/// ```
///
@isTest
void testStateNotifier<C extends StateNotifier<State>, State>(
  String description, {
  required StateNotifierProvider<C, State> provider,
  FutureOr<void> Function()? setUp,
  List<Override> overrides = const [],
  dynamic Function()? expect,
  State? seed,
  dynamic Function(C notifier)? act,
  Duration? wait,
  dynamic Function()? verify,
  dynamic Function()? errors,
  FutureOr<void> Function()? tearDown,
  bool emitBuildStates = false,
}) {
  test.test(description, () async {
    await stateNotifierTest<C, State>(
      setUp: setUp,
      provider: provider,
      overrides: overrides,
      seed: seed,
      act: act,
      wait: wait,
      expect: expect,
      verify: verify,
      errors: errors,
      tearDown: tearDown,
      emitBuildStates: emitBuildStates,
    );
  });
}

/// Internal [testStateNotifier] runner which is only visible for testing.
/// This should never be used directly - please use [testStateNotifier] instead.
@visibleForTesting
Future<void> stateNotifierTest<C extends StateNotifier<State>, State>({
  required StateNotifierProvider<C, State> provider,
  FutureOr<void> Function()? setUp,
  List<Override> overrides = const [],
  dynamic Function()? expect,
  State? seed,
  dynamic Function(C notifier)? act,
  Duration? wait,
  dynamic Function()? verify,
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
      final states = <State>[];
      container.listen<State>(
        provider,
        (previous, next) => states.add(next),
        fireImmediately: true,
      );
      try {
        final notifier = container.read(provider.notifier);
        if (!emitBuildStates) states.clear();
        // applies seed in the state
        // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
        if (seed != null) notifier.state = seed;
        await act?.call(notifier);
      } catch (error) {
        if (errors == null) rethrow;
        unhandledErrors.add(error);
      }
      if (wait != null) await Future<void>.delayed(wait);
      await Future<void>.delayed(Duration.zero);
      container.dispose();
      if (expect != null) {
        final dynamic expected = expect();
        // remove state return by seed
        if (seed != null && states.isNotEmpty) states.remove(seed);
        shallowEquality = '$states' == '$expected';
        try {
          test.expect(states, test.wrapMatcher(expected));
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
    (error, stack) {
      if (shallowEquality && error is test.TestFailure) {
        throw test.TestFailure(
          '''${error.message}
WARNING: Please ensure state instances extend Equatable, override == and hashCode, or implement Comparable.
Alternatively, consider using Matchers in the expect of the testStateNotifier rather than concrete state instances.\n''',
        );
      }
      if (errors == null || !unhandledErrors.contains(error)) {
        throw error;
      }
    },
  );
  if (errors != null) test.expect(unhandledErrors, test.wrapMatcher(errors()));
}
