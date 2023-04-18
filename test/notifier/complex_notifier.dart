import 'package:riverpod/riverpod.dart';

final complexNotifierProvider =
    NotifierProvider<ComplexNotifier, ComplexState>(ComplexNotifier.new);

class ComplexNotifier extends Notifier<ComplexState> {
  @override
  ComplexState build() => ComplexStateA();

  void setComplexStateA() => state = ComplexStateA();
  void setComplexStateB() => state = ComplexStateB();
}

abstract class ComplexState {}

class ComplexStateA extends ComplexState {}

class ComplexStateB extends ComplexState {}
