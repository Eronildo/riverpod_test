import 'package:riverpod/riverpod.dart';

bool isAsyncDataListEquals<State>(
    ProviderBase<State> provider, List<State> states, dynamic expected) {
  if (provider is ProviderBase<AsyncValue<List>> && expected is List) {
    if (states.length == expected.length &&
        states.runtimeType == expected.runtimeType) {
      for (var i = 0; i < states.length; i++) {
        final state = states[i];
        final expect = expected[i];
        if (state is AsyncData<List> && expect is AsyncData<List>) {
          if (state.value.length == expect.value.length) {
            for (var j = 0; j < state.value.length; j++) {
              if (state.value[j] != expect.value[j]) return false;
            }
          } else {
            return false;
          }
        }
      }
      return true;
    }
  }
  return false;
}
