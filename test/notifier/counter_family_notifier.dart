import 'package:riverpod/riverpod.dart';

final counterFamilyNotifierProvider =
    NotifierProviderFamily<CounterFamilyNotifier, int, int>(
  CounterFamilyNotifier.new,
);

class CounterFamilyNotifier extends FamilyNotifier<int, int> {
  @override
  int build(int initialValue) => initialValue;

  void increment() => state++;
}
