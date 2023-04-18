import 'package:riverpod/riverpod.dart';

final familyExceptionProvider = Provider.family.autoDispose<int, Exception>(
  (ref, e) => throw e,
);
