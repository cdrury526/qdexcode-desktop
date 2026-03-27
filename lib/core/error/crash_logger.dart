import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

/// Local crash logger that writes exceptions to disk.
///
/// Logs are stored under `~/.qdexcode/crash-logs/` with one file per day
/// (`YYYY-MM-DD.log`). Files older than [retentionDays] are automatically
/// removed on each write.
class CrashLogger {
  CrashLogger({this.retentionDays = 7});

  /// Number of days to keep crash log files before rotation deletes them.
  final int retentionDays;

  /// Lazily resolved log directory.
  Directory? _logDir;

  /// Returns the crash-log directory, creating it if necessary.
  Future<Directory> _ensureLogDir() async {
    if (_logDir != null) return _logDir!;
    final home = Platform.environment['HOME'] ?? '/tmp';
    _logDir = Directory('$home/.qdexcode/crash-logs');
    if (!await _logDir!.exists()) {
      await _logDir!.create(recursive: true);
    }
    return _logDir!;
  }

  /// Formats a [DateTime] as `YYYY-MM-DD`.
  static String _dateStr(DateTime dt) =>
      '${dt.year}-${_pad(dt.month)}-${_pad(dt.day)}';

  /// Formats a [DateTime] as `YYYY-MM-DD HH:mm:ss.mmm`.
  static String _timestampStr(DateTime dt) =>
      '${_dateStr(dt)} ${_pad(dt.hour)}:${_pad(dt.minute)}:'
      '${_pad(dt.second)}.${dt.millisecond.toString().padLeft(3, '0')}';

  static String _pad(int n) => n.toString().padLeft(2, '0');

  /// Logs an [error] with optional [stackTrace] and [appVersion] to today's
  /// crash log file.
  Future<void> log({
    required Object error,
    StackTrace? stackTrace,
    String? appVersion,
  }) async {
    try {
      final dir = await _ensureLogDir();
      final now = DateTime.now();
      final file = File('${dir.path}/${_dateStr(now)}.log');

      final buffer = StringBuffer()
        ..writeln('--- CRASH REPORT ---')
        ..writeln('Timestamp: ${_timestampStr(now)}')
        ..writeln('App Version: ${appVersion ?? 'unknown'}')
        ..writeln('Platform: ${Platform.operatingSystem} '
            '${Platform.operatingSystemVersion}')
        ..writeln('Error: $error');

      if (stackTrace != null) {
        buffer
          ..writeln('Stack Trace:')
          ..writeln(stackTrace);
      }

      buffer.writeln('--- END REPORT ---\n');

      await file.writeAsString(
        buffer.toString(),
        mode: FileMode.append,
      );

      // Rotate old logs in the background.
      unawaited(_rotateOldLogs(dir));
    } catch (e) {
      // Logging should never throw. Print to stderr as a last resort.
      debugPrint('CrashLogger: failed to write log: $e');
    }
  }

  /// Deletes log files older than [retentionDays].
  Future<void> _rotateOldLogs(Directory dir) async {
    try {
      final cutoff = DateTime.now().subtract(Duration(days: retentionDays));
      await for (final entity in dir.list()) {
        if (entity is! File) continue;
        final name = entity.uri.pathSegments.last;
        // Only touch files that match the YYYY-MM-DD.log pattern.
        if (!name.endsWith('.log')) continue;
        final dateStr = name.replaceAll('.log', '');
        final fileDate = DateTime.tryParse(dateStr);
        if (fileDate != null && fileDate.isBefore(cutoff)) {
          await entity.delete();
        }
      }
    } catch (e) {
      debugPrint('CrashLogger: failed to rotate logs: $e');
    }
  }
}
