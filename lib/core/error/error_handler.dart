import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:qdexcode_desktop/core/error/crash_logger.dart';
import 'package:qdexcode_desktop/core/error/error_widget.dart';

/// Key used in [SharedPreferences] to store the crash-report opt-in setting.
const String kCrashReportOptInKey = 'crash_report_opt_in';

/// Sets up global error handling for the application.
///
/// Call this once in `main()` before `runApp()`:
/// ```dart
/// await initErrorHandler();
/// ```
///
/// This configures:
/// 1. [ErrorWidget.builder] to show [AppErrorWidget] instead of the red screen.
/// 2. [FlutterError.onError] to log framework errors via [CrashLogger].
/// 3. [PlatformDispatcher.instance.onError] to catch uncaught async errors.
Future<void> initErrorHandler() async {
  final logger = CrashLogger();

  // 1. Replace the default red error screen with a styled widget.
  ErrorWidget.builder = AppErrorWidget.builder;

  // 2. Catch framework-level errors (e.g., build/layout/paint failures).
  final originalOnError = FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails details) {
    // Still call the original handler so errors appear in the console.
    originalOnError?.call(details);

    logger.log(
      error: details.exception,
      stackTrace: details.stack,
      appVersion: _appVersion,
    );

    _maybeSendRemote(details.exception, details.stack);
  };

  // 3. Catch uncaught async exceptions that escape the Flutter framework.
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    logger.log(
      error: error,
      stackTrace: stack,
      appVersion: _appVersion,
    );

    _maybeSendRemote(error, stack);

    // Return true to prevent the runtime from terminating the app.
    return true;
  };
}

/// App version string injected at build time or read from package info.
///
/// Updated lazily on first use. Falls back to the compile-time constant
/// defined via `--dart-define=APP_VERSION=...`.
const String _appVersion = String.fromEnvironment(
  'APP_VERSION',
  defaultValue: '1.0.0+1',
);

/// Placeholder for remote crash reporting (e.g., Sentry).
///
/// When the user has opted in via [kCrashReportOptInKey] in
/// [SharedPreferences], this will forward the error to a remote service.
/// Currently a no-op that only logs the intent.
void _maybeSendRemote(Object error, StackTrace? stack) {
  // TODO: Check shared_preferences for opt-in and forward to Sentry.
  //
  // final prefs = await SharedPreferences.getInstance();
  // final optedIn = prefs.getBool(kCrashReportOptInKey) ?? false;
  // if (optedIn) {
  //   Sentry.captureException(error, stackTrace: stack);
  // }
}
