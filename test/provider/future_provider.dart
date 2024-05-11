import 'package:riverpod/riverpod.dart';

import 'provider.dart';

final futureProvider = FutureProvider<int>(
  (ref) => ref.watch(complexRepositoryProvider).fetchCounter(),
);

final futureListProvider = FutureProvider<List<int>>(
  (ref) => ref.watch(complexRepositoryProvider).fetchCounterList(),
);
