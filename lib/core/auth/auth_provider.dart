/// Riverpod provider for authentication state.
///
/// Manages the full auth lifecycle:
/// - Restores session from secure storage on startup
/// - Exposes current auth state (authenticated / unauthenticated / loading)
/// - Provides login (device flow) and logout actions
/// - Triggers router redirect when auth state changes
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:qdexcode_desktop/core/auth/auth_service.dart';
import 'package:qdexcode_desktop/core/models/user.dart';

part 'auth_provider.g.dart';

// ---------------------------------------------------------------------------
// Auth state
// ---------------------------------------------------------------------------

/// Sealed auth state hierarchy for exhaustive pattern matching.
sealed class AuthState {
  const AuthState();
}

/// Initial state — checking secure storage for existing token.
final class AuthLoading extends AuthState {
  const AuthLoading();
}

/// User is authenticated with a valid session.
final class AuthAuthenticated extends AuthState {
  const AuthAuthenticated({
    required this.user,
    required this.token,
  });

  final User user;
  final String token;
}

/// User is not authenticated (no token or invalid session).
final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated({this.error});

  /// Optional error message from a failed auth attempt.
  final String? error;
}

/// Device flow is in progress — the user code is being displayed.
final class AuthDeviceFlowPending extends AuthState {
  const AuthDeviceFlowPending({
    required this.userCode,
    required this.verificationUrl,
  });

  final String userCode;
  final String verificationUrl;
}

// ---------------------------------------------------------------------------
// Auth service provider (singleton)
// ---------------------------------------------------------------------------

/// Provides the [AuthService] singleton.
@Riverpod(keepAlive: true)
AuthService authService(Ref ref) {
  return AuthService();
}

// ---------------------------------------------------------------------------
// Auth notifier
// ---------------------------------------------------------------------------

/// Manages auth state across the app lifetime.
///
/// On [build], attempts to restore a session from secure storage.
/// Exposes [login] to start the device flow and [logout] to clear credentials.
@Riverpod(keepAlive: true)
class Auth extends _$Auth {
  StreamSubscription<DeviceFlowUpdate>? _pollSubscription;

  @override
  AuthState build() {
    ref.onDispose(() {
      _pollSubscription?.cancel();
    });

    // Kick off async init — state starts as loading.
    _restoreSession();
    return const AuthLoading();
  }

  /// Attempt to restore an existing session from secure storage.
  Future<void> _restoreSession() async {
    final service = ref.read(authServiceProvider);

    try {
      final token = await service.loadToken();
      if (token == null || token.isEmpty) {
        state = const AuthUnauthenticated();
        return;
      }

      // Validate the stored token against the server.
      final sessionData = await service.validateSession(token);
      final user = _parseUserFromSession(sessionData);

      if (user != null) {
        state = AuthAuthenticated(user: user, token: token);
      } else {
        // Token is valid but response is missing user data — clear it.
        await service.deleteToken();
        state = const AuthUnauthenticated();
      }
    } on Exception catch (e) {
      // Token validation failed (network error, 401, etc.) — clear and
      // let the user re-authenticate.
      await service.deleteToken();
      state = AuthUnauthenticated(error: e.toString());
    }
  }

  /// Start the OAuth device flow.
  ///
  /// 1. Requests a device code from the server.
  /// 2. Opens the verification URL in the browser.
  /// 3. Polls for approval — state updates as the flow progresses.
  Future<void> login() async {
    final service = ref.read(authServiceProvider);

    state = const AuthLoading();

    try {
      final codeResponse = await service.requestDeviceCode();

      // Show the user code in the UI.
      state = AuthDeviceFlowPending(
        userCode: codeResponse.userCode,
        verificationUrl: codeResponse.verificationUrl,
      );

      // Open the browser for the user.
      await service.openVerificationUrl(codeResponse.verificationUrl);

      // Cancel any existing poll subscription.
      await _pollSubscription?.cancel();

      // Start polling.
      _pollSubscription = service.pollForToken(codeResponse).listen(
        (update) async {
          switch (update.status) {
            case DeviceFlowStatus.pending:
              // Stay in the pending state — no change needed.
              break;

            case DeviceFlowStatus.approved:
              final tokenResponse = update.tokenResponse!;
              // Validate and get full user info from session endpoint.
              try {
                final sessionData = await service.validateSession(
                  tokenResponse.accessToken,
                );
                final user = _parseUserFromSession(sessionData);
                if (user != null) {
                  state = AuthAuthenticated(
                    user: user,
                    token: tokenResponse.accessToken,
                  );
                } else {
                  state = const AuthUnauthenticated(
                    error: 'Session missing user data',
                  );
                }
              } on Exception catch (e) {
                state = AuthUnauthenticated(error: e.toString());
              }

            case DeviceFlowStatus.denied:
              state = AuthUnauthenticated(
                error: update.errorMessage ?? 'Access denied',
              );

            case DeviceFlowStatus.expired:
              state = AuthUnauthenticated(
                error: update.errorMessage ?? 'Device code expired',
              );

            case DeviceFlowStatus.error:
              state = AuthUnauthenticated(
                error: update.errorMessage ?? 'Authentication error',
              );
          }
        },
        onError: (Object error) {
          state = AuthUnauthenticated(error: error.toString());
        },
      );
    } on Exception catch (e) {
      state = AuthUnauthenticated(error: e.toString());
    }
  }

  /// Clear credentials and return to the unauthenticated state.
  Future<void> logout() async {
    await _pollSubscription?.cancel();
    _pollSubscription = null;

    final service = ref.read(authServiceProvider);
    await service.deleteToken();
    state = const AuthUnauthenticated();
  }

  /// Parse user info from the /api/auth/session response.
  ///
  /// The session endpoint returns:
  /// ```json
  /// {
  ///   "session": { "activeOrganizationId": "..." },
  ///   "user": { "id": "...", "name": "...", "email": "...", ... }
  /// }
  /// ```
  User? _parseUserFromSession(Map<String, dynamic> data) {
    final userData = data['user'] as Map<String, dynamic>?;
    if (userData == null || userData['id'] == null) return null;

    return User(
      id: userData['id'] as String,
      name: userData['name'] as String? ?? '',
      email: userData['email'] as String? ?? '',
      emailVerified: userData['emailVerified'] as bool? ?? false,
      image: userData['image'] as String?,
      createdAt: userData['createdAt'] != null
          ? DateTime.parse(userData['createdAt'] as String)
          : DateTime.now(),
      updatedAt: userData['updatedAt'] != null
          ? DateTime.parse(userData['updatedAt'] as String)
          : DateTime.now(),
    );
  }
}
