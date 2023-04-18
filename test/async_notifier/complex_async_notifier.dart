import 'package:riverpod/riverpod.dart';

final complexAsyncNotifierProvider =
    AsyncNotifierProvider<ComplexAsyncNotifier, ComplexState>(
  ComplexAsyncNotifier.new,
);

class ComplexAsyncNotifier extends AsyncNotifier<ComplexState> {
  @override
  ComplexState build() => ComplexStateA();

  void setComplexStateA() => state = AsyncData(ComplexStateA());
  void setComplexStateB() => state = AsyncData(ComplexStateB());
}

abstract class ComplexState {}

class ComplexStateA extends ComplexState {}

class ComplexStateB extends ComplexState {}
