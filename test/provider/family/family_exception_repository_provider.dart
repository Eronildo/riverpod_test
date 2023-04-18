import 'package:riverpod/riverpod.dart';

final familyExceptionRepositoryProvider =
    Provider.family.autoDispose<ExceptionRepository, Exception>(
  (ref, e) => ExceptionRepository(e),
);

class ExceptionRepository {
  ExceptionRepository(this.exception);

  final Exception exception;

  void throwException() => throw exception;
}
