import 'package:riverpod/riverpod.dart';

final streamProvider = StreamProvider<int>(
  (_) => Stream.fromIterable(List.generate(2, (index) => index)),
);
