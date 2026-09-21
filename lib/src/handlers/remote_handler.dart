import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../log_event.dart';
import '../log_level.dart';
import 'log_handler.dart';

/// Batches log events and POSTs them to a remote endpoint.
///
/// Payload: { "events": [ ...LogEvent.toJson() ] }
///
/// Call [flush] on app pause/dispose to drain the buffer.
class RemoteHandler extends LogHandler {
  final String endpoint;
  final Map<String, String> headers;

  @override
  final LogLevel minimumLevel;

  final int batchSize;
  final Duration flushInterval;

  final List<LogEvent> _buffer = [];
  Timer? _timer;

  static const int _maxBuffer = 200;

  RemoteHandler({
    required this.endpoint,
    this.headers = const {},
    this.minimumLevel = LogLevel.warning,
    this.batchSize = 20,
    this.flushInterval = const Duration(seconds: 30),
  }) {
    _timer = Timer.periodic(flushInterval, (_) => flush());
  }

  @override
  void handle(LogEvent event) {
    if (_buffer.length >= _maxBuffer) return; // drop when overflowing
    _buffer.add(event);
    if (_buffer.length >= batchSize) flush();
  }

  Future<void> flush() async {
    if (_buffer.isEmpty) return;

    final batch = List<LogEvent>.from(_buffer);
    _buffer.clear();

    try {
      final response = await http
          .post(
            Uri.parse(endpoint),
            headers: {'Content-Type': 'application/json', ...headers},
            body: jsonEncode({
              'events': batch.map((e) => e.toJson()).toList(),
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode >= 500) {
        _requeue(batch);
      }
    } catch (_) {
      _requeue(batch);
    }
  }

  void _requeue(List<LogEvent> batch) {
    final remaining = _maxBuffer - _buffer.length;
    if (remaining > 0) {
      _buffer.insertAll(0, batch.take(remaining));
    }
  }

  @override
  Future<void> dispose() async {
    _timer?.cancel();
    await flush();
  }
}
