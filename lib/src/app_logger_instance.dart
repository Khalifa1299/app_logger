import 'context_enricher.dart';
import 'handlers/log_handler.dart';
import 'handlers/remote_handler.dart';
import 'log_context.dart';
import 'log_event.dart';
import 'log_level.dart';

class AppLogger {
  static final AppLogger _instance = AppLogger._();
  factory AppLogger() => _instance;
  AppLogger._();

  final List<LogHandler> _handlers = [];
  LogContext _context = const LogContext();

  // ── Setup ──────────────────────────────────────────────────────────────────

  /// Call once at app startup, before adding handlers.
  /// Auto-fills appVersion, platform, deviceModel from the device.
  Future<void> init({String? sessionId}) async {
    final enriched = await ContextEnricher.enrich();
    _context = _context.copyWith(
      appVersion: enriched['appVersion'],
      platform: enriched['platform'],
      deviceModel: enriched['deviceModel'],
      sessionId: sessionId ?? _newSessionId(),
    );
  }

  void addHandler(LogHandler handler) => _handlers.add(handler);
  void removeHandler(LogHandler handler) => _handlers.remove(handler);

  // ── Context ────────────────────────────────────────────────────────────────

  /// Call after login.
  void setUser(String userId) {
    _context = _context.copyWith(userId: userId);
  }

  /// Call after logout.
  void clearUser() {
    _context = _context.copyWith(clearUserId: true);
  }

  /// Update the current screen name (call from GoRouter redirect or initState).
  void setScreen(String screen) {
    _context = _context.copyWith(screen: screen);
  }

  // ── Logging API ───────────────────────────────────────────────────────────

  void verbose(String tag, {String? message, Map<String, dynamic>? data}) =>
      _emit(LogLevel.verbose, tag, message: message, data: data);

  void debug(String tag, {String? message, Map<String, dynamic>? data}) =>
      _emit(LogLevel.debug, tag, message: message, data: data);

  void info(String tag, {String? message, Map<String, dynamic>? data}) =>
      _emit(LogLevel.info, tag, message: message, data: data);

  void warning(String tag, {String? message, Map<String, dynamic>? data}) =>
      _emit(LogLevel.warning, tag, message: message, data: data);

  void error(
    String tag, {
    String? message,
    Map<String, dynamic>? data,
    Object? error,
    StackTrace? stackTrace,
  }) =>
      _emit(LogLevel.error, tag,
          message: message, data: data, error: error, stackTrace: stackTrace);

  void fatal(
    String tag, {
    String? message,
    Map<String, dynamic>? data,
    Object? error,
    StackTrace? stackTrace,
  }) =>
      _emit(LogLevel.fatal, tag,
          message: message, data: data, error: error, stackTrace: stackTrace);

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  /// Flush all remote buffers immediately (call on app pause / background).
  Future<void> flush() async {
    for (final h in _handlers.whereType<RemoteHandler>()) {
      await h.flush();
    }
  }

  Future<void> dispose() async {
    for (final h in _handlers) {
      await h.dispose();
    }
    _handlers.clear();
  }

  // ── Internal ───────────────────────────────────────────────────────────────

  void _emit(
    LogLevel level,
    String tag, {
    String? message,
    Map<String, dynamic>? data,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (_handlers.isEmpty) return;

    final event = LogEvent(
      level: level,
      tag: tag,
      message: message,
      data: data,
      error: error,
      stackTrace: stackTrace,
      timestamp: DateTime.now().toUtc(),
      context: _context.toMap(),
    );

    for (final handler in _handlers) {
      if (handler.shouldHandle(level)) {
        handler.handle(event);
      }
    }
  }

  String _newSessionId() =>
      DateTime.now().millisecondsSinceEpoch.toRadixString(36);
}
