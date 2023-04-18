import 'package:riverpod/riverpod.dart';

final counterAutoDisposeFamilyNotifierProvider =
    AutoDisposeNotifierProviderFamily<CounterAutoDisposeFamilyNotifier, int,
        int>(
  CounterAutoDisposeFamilyNotifier.new,
);

class CounterAutoDisposeFamilyNotifier
    extends AutoDisposeFamilyNotifier<int, int> {
  @override
  int build(int initialValue) => initialValue;

  void increment() => state++;
}
