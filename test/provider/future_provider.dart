import 'package:riverpod/riverpod.dart';

import 'provider.dart';

final futureProvider = FutureProvider<int>(
  (ref) => ref.watch(complexRepositoryProvider).fetchCounter(),
);
