import '../log_event.dart';
import '../log_level.dart';

abstract class LogHandler {
  LogLevel get minimumLevel;

  bool shouldHandle(LogLevel level) => level >= minimumLevel;

  void handle(LogEvent event);

  Future<void> dispose() async {}
}
