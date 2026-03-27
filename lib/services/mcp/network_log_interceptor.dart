/// Dio interceptor that records HTTP traffic to a [NetworkLogBuffer].
///
/// Only instantiate this in debug mode — it adds overhead by copying
/// headers and response bodies for every request.
library;

import 'package:dio/dio.dart';

import 'package:qdexcode_desktop/services/mcp/network_log_buffer.dart';

/// Key used to stash the request start time in [RequestOptions.extra].
const _kTimestampKey = '__networkLog_startTime';

/// Maximum number of characters to capture from response bodies.
const _kMaxPreviewLength = 500;

/// Dio [Interceptor] that captures request/response pairs into a
/// [NetworkLogBuffer] for later inspection via the devtools MCP server.
class NetworkLogInterceptor extends Interceptor {
  /// Creates an interceptor that writes to [buffer].
  NetworkLogInterceptor(this.buffer);

  /// The ring buffer that receives captured entries.
  final NetworkLogBuffer buffer;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_kTimestampKey] = DateTime.now();
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    final entry = _buildEntry(
      options: response.requestOptions,
      statusCode: response.statusCode ?? 0,
      responseBody: response.data,
    );
    buffer.add(entry);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final entry = _buildEntry(
      options: err.requestOptions,
      statusCode: err.response?.statusCode ?? -1,
      responseBody: err.response?.data,
      error: err.message ?? err.type.name,
    );
    buffer.add(entry);
    handler.next(err);
  }

  NetworkLogEntry _buildEntry({
    required RequestOptions options,
    required int statusCode,
    Object? responseBody,
    String? error,
  }) {
    final startTime =
        options.extra[_kTimestampKey] as DateTime? ?? DateTime.now();
    final duration =
        DateTime.now().difference(startTime).inMilliseconds;

    return NetworkLogEntry(
      method: options.method,
      url: options.uri.toString(),
      statusCode: statusCode,
      requestHeaders: _redactHeaders(options.headers),
      responsePreview: _truncate(responseBody),
      timestamp: startTime,
      durationMs: duration,
      error: error,
    );
  }

  /// Copies headers to a flat `Map<String, String>`, redacting auth values.
  static Map<String, String> _redactHeaders(Map<String, dynamic> headers) {
    final redacted = <String, String>{};
    for (final entry in headers.entries) {
      final key = entry.key;
      final value = entry.value?.toString() ?? '';
      if (key.toLowerCase() == 'authorization') {
        redacted[key] = 'Bearer ***';
      } else {
        redacted[key] = value;
      }
    }
    return redacted;
  }

  /// Converts a response body to a string preview, truncated to
  /// [_kMaxPreviewLength] characters.
  static String _truncate(Object? body) {
    if (body == null) return '';
    final str = body.toString();
    if (str.length <= _kMaxPreviewLength) return str;
    return '${str.substring(0, _kMaxPreviewLength)}...';
  }
}
