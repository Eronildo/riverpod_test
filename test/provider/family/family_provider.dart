import 'package:riverpod/riverpod.dart';

final familyCounterProvider =
    Provider.family.autoDispose<int, int>((ref, count) => count);
