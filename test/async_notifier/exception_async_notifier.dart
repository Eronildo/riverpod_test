import 'dart:async';
import 'package:riverpod/riverpod.dart';

final exceptionAsyncNotifierProvider =
    AsyncNotifierProviderFamily<ExceptionAsyncNotifier, int, int>(
  ExceptionAsyncNotifier.new,
);

class ExceptionAsyncNotifier extends FamilyAsyncNotifier<int, int> {
  @override
  FutureOr<int> build(int initialValue) => initialValue;

  void throwException(Exception e) => throw e;
}
