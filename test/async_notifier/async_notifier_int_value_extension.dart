// ignore_for_file: invalid_use_of_protected_member

import 'package:riverpod/riverpod.dart';

extension AsyncNotifierIntValueExtension on AsyncNotifier<int> {
  int get value => state.hasValue ? state.value! : 0;
}

extension AutoDisposeAsyncNotifierIntValueExtension
    on AutoDisposeAsyncNotifier<int> {
  int get value => state.hasValue ? state.value! : 0;
}

extension FamilyAsyncNotifierIntValueExtension
    on FamilyAsyncNotifier<int, int> {
  int get value => state.hasValue ? state.value! : 0;
}

extension AutoDisposeFamilyAsyncNotifierIntValueExtension
    on AutoDisposeFamilyAsyncNotifier<int, int> {
  int get value => state.hasValue ? state.value! : 0;
}
