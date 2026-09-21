import '../log_event.dart';
import '../log_level.dart';
import 'log_handler.dart';

/// Sends log events to Firebase Crashlytics.
///
/// Requires `firebase_crashlytics` in the consuming app's pubspec.yaml.
/// Pass `FirebaseCrashlytics.instance` to the constructor:
///
/// ```dart
/// log.addHandler(CrashlyticsHandler(FirebaseCrashlytics.instance));
/// ```
///
/// - warning / info / debug → breadcrumb via `log`
/// - error / fatal          → non-fatal / fatal via `recordError`
class CrashlyticsHandler extends LogHandler {
  // Typed as dynamic so this file compiles without a hard firebase_crashlytics
  // import. The caller provides the real FirebaseCrashlytics instance.
  final dynamic _crashlytics;

  @override
  final LogLevel minimumLevel;

  CrashlyticsHandler(this._crashlytics,
      {this.minimumLevel = LogLevel.info});

  @override
  void handle(LogEvent event) {
    final breadcrumb = '[${event.level.name.toUpperCase()}] ${event.tag}'
        '${event.message != null ? ' — ${event.message}' : ''}'
        '${event.data != null ? ' | ${event.data}' : ''}';

    try {
      _crashlytics.log(breadcrumb);

      if (event.data != null) {
        event.data!.forEach((k, v) {
          try {
            _crashlytics.setCustomKey('log_$k', v.toString());
          } catch (_) {}
        });
      }

      if (event.level >= LogLevel.error && event.error != null) {
        _crashlytics.recordError(
          event.error,
          event.stackTrace,
          reason: '${event.tag}: ${event.message ?? ''}',
          fatal: event.level == LogLevel.fatal,
          printDetails: false,
        );
      }
    } catch (_) {
      // Swallow crashlytics errors — logging must never crash the app.
    }
  }
}
