import 'dart:async';


Future<void> runZonedGuardedWrapper(Future<void> Function() body) {
  final completer = Completer<void>();
  runZonedGuarded(() async {
    await body();
    if (!completer.isCompleted) completer.complete();
  }, (error, stackTrace) {
    if (!completer.isCompleted) completer.completeError(error, stackTrace);
  });
  return completer.future;
}
