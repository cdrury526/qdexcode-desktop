/// Ring buffer for capturing Dio HTTP request/response history.
///
/// Used by the embedded MCP devtools server to expose network activity
/// via the `inspect` gateway's `network_log` command. Debug-only.
library;

/// A single captured HTTP request/response pair.
class NetworkLogEntry {
  /// Creates a network log entry.
  const NetworkLogEntry({
    required this.method,
    required this.url,
    required this.statusCode,
    required this.requestHeaders,
    required this.responsePreview,
    required this.timestamp,
    required this.durationMs,
    this.error,
  });

  /// HTTP method (GET, POST, etc.).
  final String method;

  /// Full request URL including query parameters.
  final String url;

  /// HTTP status code, or -1 if the request failed before a response.
  final int statusCode;

  /// Request headers with sensitive values redacted.
  ///
  /// Authorization headers are replaced with `'Bearer ***'`.
  final Map<String, String> requestHeaders;

  /// First 500 characters of the response body, or the error message.
  final String responsePreview;

  /// When the request was initiated.
  final DateTime timestamp;

  /// Round-trip duration in milliseconds.
  final int durationMs;

  /// Error message if the request failed, `null` on success.
  final String? error;

  /// Whether this entry represents a failed request.
  bool get isError => error != null;

  /// Serializes this entry to a JSON-compatible map.
  Map<String, dynamic> toJson() => {
        'method': method,
        'url': url,
        'statusCode': statusCode,
        'requestHeaders': requestHeaders,
        'responsePreview': responsePreview,
        'timestamp': timestamp.toIso8601String(),
        'durationMs': durationMs,
        if (error != null) 'error': error,
      };
}

/// Fixed-capacity ring buffer that stores the most recent [NetworkLogEntry]s.
///
/// When the buffer is full, the oldest entry is overwritten. Thread-safe
/// for single-isolate use (Flutter UI thread).
class NetworkLogBuffer {
  /// Creates a ring buffer with the given [capacity].
  NetworkLogBuffer({this.capacity = 50});

  /// Maximum number of entries retained.
  final int capacity;

  final List<NetworkLogEntry> _buffer = [];
  int _head = 0;
  int _count = 0;

  /// Adds an entry to the buffer, evicting the oldest if full.
  void add(NetworkLogEntry entry) {
    if (_buffer.length < capacity) {
      _buffer.add(entry);
    } else {
      _buffer[_head] = entry;
    }
    _head = (_head + 1) % capacity;
    _count++;
  }

  /// Removes all entries from the buffer.
  void clear() {
    _buffer.clear();
    _head = 0;
    _count = 0;
  }

  /// Total number of entries ever added (including evicted ones).
  int get totalCount => _count;

  /// Number of entries currently in the buffer.
  int get length => _buffer.length;

  /// All entries in chronological order (oldest first).
  List<NetworkLogEntry> get entries {
    if (_buffer.length < capacity) {
      return List.unmodifiable(_buffer);
    }
    // Ring buffer is full — read from head (oldest) to head-1 (newest).
    return List.unmodifiable([
      ..._buffer.sublist(_head),
      ..._buffer.sublist(0, _head),
    ]);
  }

  /// Entries matching a URL substring filter.
  List<NetworkLogEntry> filterByUrl(String substring) {
    final lower = substring.toLowerCase();
    return entries.where((e) => e.url.toLowerCase().contains(lower)).toList();
  }

  /// Only entries that represent errors.
  List<NetworkLogEntry> get errorsOnly =>
      entries.where((e) => e.isError).toList();
}
