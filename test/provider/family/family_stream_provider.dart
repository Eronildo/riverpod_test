import 'package:riverpod/riverpod.dart';

final familysStreamProvider = StreamProvider.family.autoDispose<int, int>(
  (_, count) async* {
    await Future<void>.delayed(const Duration(milliseconds: 100));

    yield* Stream.fromIterable(List.generate(count, (index) => index));
  },
);
