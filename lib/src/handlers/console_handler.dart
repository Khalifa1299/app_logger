import 'package:flutter/foundation.dart';
import '../log_event.dart';
import '../log_level.dart';
import 'log_handler.dart';

class ConsoleHandler extends LogHandler {
  @override
  final LogLevel minimumLevel;

  ConsoleHandler({this.minimumLevel = LogLevel.verbose});

  @override
  void handle(LogEvent event) {
    if (!kDebugMode) return;

    final time = _formatTime(event.timestamp);
    final prefix = _prefix(event.level);
    final tag = event.tag;
    final msg = event.message ?? '';

    final buffer = StringBuffer('$time $prefix [$tag]');
    if (msg.isNotEmpty) buffer.write(' $msg');
    if (event.data != null && event.data!.isNotEmpty) {
      buffer.write('\n   data: ${event.data}');
    }
    if (event.error != null) {
      buffer.write('\n   error: ${event.error}');
    }
    if (event.stackTrace != null) {
      buffer.write('\n   stack: ${event.stackTrace}');
    }

    debugPrint(buffer.toString());
  }

  String _prefix(LogLevel level) => switch (level) {
        LogLevel.verbose => '⬜ VERBOSE',
        LogLevel.debug   => '🔵 DEBUG  ',
        LogLevel.info    => '🟢 INFO   ',
        LogLevel.warning => '🟡 WARNING',
        LogLevel.error   => '🔴 ERROR  ',
        LogLevel.fatal   => '💀 FATAL  ',
      };

  String _formatTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:'
      '${dt.minute.toString().padLeft(2, '0')}:'
      '${dt.second.toString().padLeft(2, '0')}.'
      '${dt.millisecond.toString().padLeft(3, '0')}';
}
