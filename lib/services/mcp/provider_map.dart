/// Shared provider name registry for MCP gateway tools.
///
/// Maps human-readable provider names (as used by the `inspect` and `action`
/// gateways) to reader functions that extract JSON-safe values from the
/// [ProviderContainer]. Both gateways import this file so the name set
/// stays consistent — `inspect provider_state` and `action invalidate`
/// operate on the exact same registry.
///
/// Each reader is called fresh on every tool invocation — never cached.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:qdexcode_desktop/core/auth/auth_provider.dart';
import 'package:qdexcode_desktop/core/state/window_state_provider.dart';
import 'package:qdexcode_desktop/core/theme/theme_provider.dart';
import 'package:qdexcode_desktop/features/projects/project_provider.dart';

// ---------------------------------------------------------------------------
// Serialization helpers
// ---------------------------------------------------------------------------

/// Serialize the sealed [AuthState] hierarchy to a JSON-safe map.
Map<String, dynamic> serializeAuthState(AuthState state) => switch (state) {
      AuthLoading() => {'status': 'loading'},
      AuthAuthenticated(:final user, :final token) => {
          'status': 'authenticated',
          'user': {
            'id': user.id,
            'name': user.name,
            'email': user.email,
            'image': user.image,
          },
          'tokenPrefix': '${token.substring(0, token.length.clamp(0, 8))}...',
        },
      AuthUnauthenticated(:final error) => {
          'status': 'unauthenticated',
          // ignore: use_null_aware_elements
          if (error != null) 'error': error,
        },
      AuthDeviceFlowPending(:final userCode, :final verificationUrl) => {
          'status': 'device_flow_pending',
          'userCode': userCode,
          'verificationUrl': verificationUrl,
        },
    };

/// Serialize an [AsyncValue] with a custom value serializer.
Map<String, dynamic> serializeAsyncValue<T>(
  AsyncValue<T> asyncValue,
  Object? Function(T value) serializeValue,
) =>
    switch (asyncValue) {
      AsyncData(:final value) => {
          'status': 'data',
          'value': serializeValue(value),
        },
      AsyncLoading() => {'status': 'loading'},
      AsyncError(:final error) => {
          'status': 'error',
          'error': error.toString(),
        },
      _ => {'status': 'unknown'},
    };

/// Serialize a list of items that may have toJson().
List<Object?> serializeList(List<dynamic> items) =>
    items.map(serializeValue).toList();

/// Best-effort serialization: toJson() if available, toString() otherwise.
Object? serializeValue(Object? value) {
  if (value == null) return null;
  try {
    // ignore: avoid_dynamic_calls
    return (value as dynamic).toJson();
  } on NoSuchMethodError {
    return value.toString();
  }
}

// ---------------------------------------------------------------------------
// Provider registry
// ---------------------------------------------------------------------------

/// Reads a named provider from the container and returns a JSON-safe value.
typedef ProviderReader = Object? Function(ProviderContainer container);

/// Registry of provider names to reader functions.
///
/// Used by both `inspect` (provider_state) and `action` (invalidate) gateways.
/// Each entry reads from the container on every call — never cached.
final Map<String, ProviderReader> providerRegistry = {
  'authProvider': (c) => serializeAuthState(c.read(authProvider)),
  'projectListProvider': (c) =>
      serializeAsyncValue(c.read(projectListProvider), serializeList),
  'selectedProjectProvider': (c) =>
      serializeAsyncValue(c.read(selectedProjectProvider), serializeValue),
  'themePreferenceProvider': (c) => c.read(themePreferenceProvider).name,
  'panelWidthsStateProvider': (c) =>
      c.read(panelWidthsStateProvider).toJson(),
  'windowGeometryStateProvider': (c) =>
      c.read(windowGeometryStateProvider).toJson(),
  'activeTabStateProvider': (c) => c.read(activeTabStateProvider),
  'selectedProjectStateProvider': (c) =>
      c.read(selectedProjectStateProvider),
};

/// Map of provider names to their invalidation functions.
///
/// Not all providers can be invalidated (some are keepAlive singletons
/// that should not be torn down). This map only contains providers
/// where invalidation is meaningful and safe.
final Map<String, void Function(ProviderContainer container)>
    invalidatableProviders = {
  'projectListProvider': (c) => c.invalidate(projectListProvider),
  'selectedProjectProvider': (c) => c.invalidate(selectedProjectProvider),
  'themePreferenceProvider': (c) => c.invalidate(themePreferenceProvider),
};
