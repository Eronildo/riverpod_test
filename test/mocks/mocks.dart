import 'package:mocktail/mocktail.dart';

import '../provider/provider.dart';

class MockRepository extends Mock implements Repository {}

class MockComplexRepository extends Mock implements ComplexRepository {}

class MockCounterDataSouce extends Mock implements CounterDataSource {}
