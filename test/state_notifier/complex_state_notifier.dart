import 'package:riverpod/riverpod.dart';

final complexStateNotifierProvider =
    StateNotifierProvider<ComplexStateNotifier, ComplexState>(
  (ref) => ComplexStateNotifier(),
);

class ComplexStateNotifier extends StateNotifier<ComplexState> {
  ComplexStateNotifier() : super(ComplexStateA());

  void setComplexStateA() => state = ComplexStateA();
  void setComplexStateB() => state = ComplexStateB();
}

abstract class ComplexState {}

class ComplexStateA extends ComplexState {}

class ComplexStateB extends ComplexState {}
