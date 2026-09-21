import 'log_level.dart';

class LogEvent {
  final LogLevel level;
  final String tag;
  final String? message;
  final Map<String, dynamic>? data;
  final Object? error;
  final StackTrace? stackTrace;
  final DateTime timestamp;
  final Map<String, dynamic> context;

  const LogEvent({
    required this.level,
    required this.tag,
    this.message,
    this.data,
    this.error,
    this.stackTrace,
    required this.timestamp,
    required this.context,
  });

  Map<String, dynamic> toJson() => {
        'level': level.name,
        'tag': tag,
        if (message != null) 'message': message,
        if (data != null && data!.isNotEmpty) 'data': data,
        if (error != null) 'error': error.toString(),
        if (stackTrace != null) 'stackTrace': stackTrace.toString(),
        'timestamp': timestamp.toIso8601String(),
        ...context,
      };
}
