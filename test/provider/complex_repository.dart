import 'package:riverpod/riverpod.dart';

final complexRepositoryProvider = Provider<ComplexRepository>(
  (ref) => ComplexRepository(
    dataSource: ref.watch(counterDataSourceProvider),
  ),
);

class ComplexRepository {
  ComplexRepository({
    required this.dataSource,
  });

  CounterDataSource dataSource;

  Future<int> fetchCounter() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));

    return dataSource.counter;
  }

  Future<List<int>> fetchCounterList() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));

    return [2];
  }

  Future<int> incrementCounter() => dataSource.incrementCounter();

  Future<int> decrementCounter() => dataSource.decrementCounter();

  void dispose() {
    dataSource.dispose();
  }
}

final counterDataSourceProvider =
    Provider<CounterDataSource>((ref) => CounterDataSource());

class CounterDataSource {
  int counter = 0;

  Future<int> incrementCounter() => Future.value(counter + 1);

  Future<int> decrementCounter() => Future.value(counter - 1);

  void dispose() {
    counter = 0;
  }
}
