/// Dio HTTP client with authentication interceptor.
///
/// All API requests automatically include the stored bearer token.
/// When a 401 response is received, the auth state is cleared so the
/// router redirects to the login page.
library;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:qdexcode_desktop/services/mcp/network_log_buffer.dart';
import 'package:qdexcode_desktop/services/mcp/network_log_interceptor.dart';

part 'api_client.g.dart';

const _kBaseUrl = 'https://v2.chrisdrury.com';

/// Global network log buffer for the MCP devtools server.
///
/// Only populated in debug mode. The DevtoolsServer passes this to the
/// `inspect` gateway's `network_log` command handler.
final NetworkLogBuffer networkLogBuffer =
    kDebugMode ? NetworkLogBuffer() : NetworkLogBuffer(capacity: 0);
const _kTokenStorageKey = 'qdexcode_auth_token';

/// Provides the configured [Dio] instance for all API calls.
///
/// The interceptor reads the token from flutter_secure_storage on every
/// request (rather than caching it) so token changes (login/logout) are
/// picked up immediately.
@Riverpod(keepAlive: true)
Dio apiClient(Ref ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: _kBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  const secureStorage = FlutterSecureStorage(
    mOptions: MacOsOptions(
      useDataProtectionKeyChain: true,
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Attach the stored bearer token (if any) to every request.
        final token = await secureStorage.read(key: _kTokenStorageKey);
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        // 401 means the token is invalid/expired — downstream providers
        // watch for this to trigger re-authentication.
        handler.next(error);
      },
    ),
  );

  // Debug-only: capture HTTP traffic for the MCP devtools server.
  if (kDebugMode) {
    dio.interceptors.add(NetworkLogInterceptor(networkLogBuffer));
  }

  return dio;
}
