/// Realtime event types from the pg-bridge WebSocket.
///
/// Maps the wire format `{ type, data, ts }` to typed Dart classes.
/// Message types match those defined in the Next.js web app
/// (apps/web/src/hooks/use-websocket.ts).
library;

import 'dart:convert';

// ---------------------------------------------------------------------------
// Connection status
// ---------------------------------------------------------------------------

/// WebSocket connection lifecycle states.
enum ConnectionStatus {
  /// Not connected and not attempting to connect.
  disconnected,

  /// Actively establishing a connection (first attempt).
  connecting,

  /// Connected and receiving messages.
  connected,

  /// Connection lost, attempting to reconnect with backoff.
  reconnecting,

  /// Permanently failed (max retries exceeded or auth error).
  error,
}

// ---------------------------------------------------------------------------
// Message types
// ---------------------------------------------------------------------------

/// All message types that flow through the pg-bridge realtime system.
enum RealtimeMessageType {
  indexingProgress('indexing_progress'),
  indexingComplete('indexing_complete'),
  indexingError('indexing_error'),
  projectUpdated('project_updated'),
  projectDeleted('project_deleted'),
  planUpdated('plan_updated'),
  taskUpdated('task_updated'),
  subtaskUpdated('subtask_updated'),
  menubarConnected('menubar_connected'),
  menubarDisconnected('menubar_disconnected'),
  terminalOutput('terminal_output'),
  connectionCount('connection_count'),
  ping('ping'),
  pong('pong'),
  error('error');

  const RealtimeMessageType(this.wireValue);

  /// The string value used on the wire (JSON `type` field).
  final String wireValue;

  /// Look up a [RealtimeMessageType] by its wire value.
  /// Returns `null` for unknown types.
  static RealtimeMessageType? fromWire(String value) {
    for (final type in values) {
      if (type.wireValue == value) return type;
    }
    return null;
  }
}

// ---------------------------------------------------------------------------
// Wire message
// ---------------------------------------------------------------------------

/// A single message from the pg-bridge WebSocket.
///
/// Wire format: `{ "type": "indexing_progress", "data": {...}, "ts": "..." }`
class RealtimeMessage {
  const RealtimeMessage({
    required this.type,
    required this.data,
    required this.timestamp,
  });

  /// Parse a raw JSON string into a [RealtimeMessage].
  /// Returns `null` if parsing fails or the type is unknown.
  static RealtimeMessage? tryParse(String raw) {
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final typeStr = json['type'] as String?;
      if (typeStr == null) return null;

      final type = RealtimeMessageType.fromWire(typeStr);
      if (type == null) return null;

      return RealtimeMessage(
        type: type,
        data: (json['data'] as Map<String, dynamic>?) ?? const {},
        timestamp: json['ts'] as String? ?? '',
      );
    } on Object {
      return null;
    }
  }

  final RealtimeMessageType type;
  final Map<String, dynamic> data;
  final String timestamp;

  /// Convenience: get a string value from [data].
  String? getString(String key) => data[key] as String?;

  /// Convenience: get an int value from [data].
  int? getInt(String key) {
    final v = data[key];
    if (v is int) return v;
    if (v is num) return v.toInt();
    return null;
  }

  /// Convenience: get a double value from [data].
  double? getDouble(String key) {
    final v = data[key];
    if (v is double) return v;
    if (v is num) return v.toDouble();
    return null;
  }

  @override
  String toString() =>
      'RealtimeMessage(type: ${type.wireValue}, data: $data)';
}

// ---------------------------------------------------------------------------
// Indexing progress (typed payload)
// ---------------------------------------------------------------------------

/// Typed representation of an `indexing_progress` event payload.
///
/// The Go indexer sends: files_done, files_total, current_file, status,
/// project_id, pipeline, symbols_found, error.
class IndexingProgress {
  const IndexingProgress({
    required this.projectId,
    required this.pipeline,
    required this.stage,
    required this.progress,
    this.filesProcessed,
    this.filesTotal,
    this.currentFile,
    this.symbolsFound,
    this.error,
    this.completedAt,
  });

  /// Parse from a [RealtimeMessage] with type `indexing_progress`.
  factory IndexingProgress.fromMessage(RealtimeMessage message) {
    final d = message.data;
    final filesDone =
        (d['files_done'] as num?)?.toInt() ??
        (d['files_processed'] as num?)?.toInt() ??
        0;
    final filesTotal = (d['files_total'] as num?)?.toInt() ?? 0;

    return IndexingProgress(
      projectId: d['project_id'] as String? ?? '',
      pipeline: d['pipeline'] as String? ?? 'initial_index',
      stage: (d['status'] as String?) ?? (d['stage'] as String?) ?? 'progress',
      progress:
          filesTotal > 0 ? ((filesDone / filesTotal) * 100).round() : 0,
      filesProcessed: filesDone,
      filesTotal: filesTotal,
      currentFile: d['current_file'] as String?,
      symbolsFound: (d['symbols_found'] as num?)?.toInt(),
      error: d['error'] as String?,
      completedAt: d['completed_at'] as String?,
    );
  }

  final String projectId;
  final String pipeline;
  final String stage;

  /// 0-100 percentage.
  final int progress;
  final int? filesProcessed;
  final int? filesTotal;
  final String? currentFile;
  final int? symbolsFound;
  final String? error;
  final String? completedAt;

  /// Whether the indexing operation has finished (success or failure).
  bool get isComplete =>
      stage == 'complete' || stage == 'done' || completedAt != null;

  /// Whether the indexing operation failed.
  bool get isFailed => error != null && error!.isNotEmpty;

  @override
  String toString() =>
      'IndexingProgress($projectId, $stage, $progress%, '
      '${filesProcessed ?? 0}/${filesTotal ?? 0} files)';
}
