import 'package:riverpod/riverpod.dart';

final exceptionStateNotifierProvider =
    StateNotifierProvider<ExceptionStateNotifier, int>(
  (ref) => ExceptionStateNotifier(),
);

class ExceptionStateNotifier extends StateNotifier<int> {
  ExceptionStateNotifier() : super(0);

  void throwException(Exception e) => throw e;
}
