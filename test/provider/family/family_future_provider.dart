import 'package:riverpod/riverpod.dart';

final familyFutureProvider = FutureProvider.family.autoDispose<int, int>(
  (ref, count) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));

    return count;
  },
);
