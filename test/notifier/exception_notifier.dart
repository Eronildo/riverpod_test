import 'package:riverpod/riverpod.dart';

final exceptionNotifierProvider =
    NotifierProvider<ExceptionNotifier, int>(ExceptionNotifier.new);

class ExceptionNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void throwException(Exception e) => throw e;
}
