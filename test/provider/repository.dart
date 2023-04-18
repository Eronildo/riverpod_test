import 'package:riverpod/riverpod.dart';

final repositoryProvider = Provider<Repository>((ref) => Repository());

class Repository {
  void sideEffect() {
    Future<void>.delayed(const Duration(microseconds: 1));
  }

  int incrementCounter() => 1;

  int? nullFunction() => null;

  void voidFunction() {
    assert(2 + 2 == 4, '2 + 2 must to be 4');
  }

  void throwError() {
    throw RepositoryError();
  }

  Complex getComplexA() => ComplexA();
}

class RepositoryError extends Error {}

abstract class Complex {}

class ComplexA extends Complex {}

class ComplexB extends Complex {}
