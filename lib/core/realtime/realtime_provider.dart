/// Riverpod providers for the pg-bridge WebSocket realtime system.
///
/// Manages WebSocket lifecycle, connection state, and event dispatch.
/// When the selected project changes (different org), the WebSocket
/// re-authenticates with a fresh JWT scoped to the new org.
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:qdexcode_desktop/core/api/api_client.dart';
import 'package:qdexcode_desktop/core/auth/auth_provider.dart';
import 'package:qdexcode_desktop/core/realtime/realtime_events.dart';
import 'package:qdexcode_desktop/core/realtime/realtime_service.dart';
import 'package:qdexcode_desktop/features/projects/project_provider.dart';

part 'realtime_provider.g.dart';

// ---------------------------------------------------------------------------
// RealtimeService singleton
// ---------------------------------------------------------------------------

/// Provides the [RealtimeService] singleton, kept alive for the app lifetime.
///
/// Watches auth state: connects when authenticated, disconnects on logout.
/// Watches the selected project's organization ID: reconnects with a fresh
/// JWT when the org changes (the JWT encodes org_id).
@Riverpod(keepAlive: true)
class Realtime extends _$Realtime {
  RealtimeService? _service;
  StreamSubscription<RealtimeMessage>? _messageSubscription;
  String? _currentOrgId;

  @override
  RealtimeService build() {
    final dio = ref.watch(apiClientProvider);
    final authState = ref.watch(authProvider);

    // Create or reuse the service.
    _service ??= RealtimeService(dio: dio);
    final service = _service!;

    // Clean up on dispose.
    ref.onDispose(() {
      _messageSubscription?.cancel();
      _messageSubscription = null;
      service.dispose();
      _service = null;
    });

    // Only connect when authenticated.
    if (authState is AuthAuthenticated) {
      _connectAndWatch(service);
    } else {
      service.disconnect();
      _currentOrgId = null;
    }

    return service;
  }

  /// Connect the service and set up the org-change watcher.
  void _connectAndWatch(RealtimeService service) {
    // Watch the selected project to detect org changes.
    final selectedProject = ref.watch(selectedProjectProvider).valueOrNull;
    final newOrgId = selectedProject?.organizationId;

    if (newOrgId != null && newOrgId != _currentOrgId) {
      // Org changed -- reconnect to get a new JWT with the correct org_id.
      _currentOrgId = newOrgId;
      service.reconnect();
    } else if (service.status == ConnectionStatus.disconnected ||
        service.status == ConnectionStatus.error) {
      // Not connected yet -- kick off initial connection.
      service.connect();
    }

    // Set up message dispatch (once).
    _messageSubscription ??= service.messages.listen(_dispatchMessage);
  }

  /// Route incoming messages to the appropriate Riverpod providers.
  void _dispatchMessage(RealtimeMessage message) {
    switch (message.type) {
      case RealtimeMessageType.indexingProgress:
      case RealtimeMessageType.indexingComplete:
      case RealtimeMessageType.indexingError:
        // Update the indexing progress provider.
        final progress = IndexingProgress.fromMessage(message);
        ref
            .read(indexingProgressMapProvider.notifier)
            .update(progress);

        // If indexing just completed, refresh the project list so the
        // index_status column is up-to-date in the UI.
        if (message.type == RealtimeMessageType.indexingComplete) {
          ref.invalidate(projectListProvider);
        }

      case RealtimeMessageType.projectUpdated:
      case RealtimeMessageType.projectDeleted:
        ref.invalidate(projectListProvider);

      case RealtimeMessageType.planUpdated:
        // Plan list providers will pick this up if they exist.
        // Use a broad invalidation so any plan-related provider refreshes.
        _invalidateByPattern('plan');

      case RealtimeMessageType.taskUpdated:
      case RealtimeMessageType.subtaskUpdated:
        _invalidateByPattern('task');

      case RealtimeMessageType.connectionCount:
      case RealtimeMessageType.menubarConnected:
      case RealtimeMessageType.menubarDisconnected:
      case RealtimeMessageType.terminalOutput:
      case RealtimeMessageType.ping:
      case RealtimeMessageType.pong:
      case RealtimeMessageType.error:
        // These are either handled internally or not relevant for
        // provider invalidation.
        break;
    }
  }

  /// Invalidate providers that match a pattern.
  ///
  /// Since we cannot enumerate all providers at runtime, we invalidate
  /// known providers by feature area. This is extensible as new features
  /// are added.
  void _invalidateByPattern(String area) {
    // Currently we rely on the message stream for granular updates.
    // Feature providers can listen to [realtimeMessagesProvider] filtered
    // by type for fine-grained reactivity.
  }
}

// ---------------------------------------------------------------------------
// Connection status provider
// ---------------------------------------------------------------------------

/// Provides the current [ConnectionStatus] as a stream.
///
/// Widgets like [ConnectionBadge] watch this for reactive status updates.
@Riverpod(keepAlive: true)
class RealtimeConnectionStatus extends _$RealtimeConnectionStatus {
  StreamSubscription<ConnectionStatus>? _subscription;

  @override
  ConnectionStatus build() {
    final service = ref.watch(realtimeProvider);

    _subscription?.cancel();
    _subscription = service.statusStream.listen((status) {
      state = status;
    });

    ref.onDispose(() {
      _subscription?.cancel();
      _subscription = null;
    });

    return service.status;
  }
}

// ---------------------------------------------------------------------------
// Realtime message stream (for feature providers to listen)
// ---------------------------------------------------------------------------

/// Exposes the raw [RealtimeMessage] stream for feature-specific providers
/// that need fine-grained event handling.
///
/// Usage:
/// ```dart
/// ref.listen(realtimeMessagesProvider, (prev, next) {
///   next.whenData((msg) {
///     if (msg.type == RealtimeMessageType.planUpdated) { ... }
///   });
/// });
/// ```
@Riverpod(keepAlive: true)
class RealtimeMessages extends _$RealtimeMessages {
  StreamSubscription<RealtimeMessage>? _subscription;

  @override
  RealtimeMessage? build() {
    final service = ref.watch(realtimeProvider);

    _subscription?.cancel();
    _subscription = service.messages.listen((message) {
      state = message;
    });

    ref.onDispose(() {
      _subscription?.cancel();
      _subscription = null;
    });

    return null;
  }
}

// ---------------------------------------------------------------------------
// Indexing progress provider
// ---------------------------------------------------------------------------

/// Tracks active indexing progress keyed by project ID.
///
/// Updated by the realtime message dispatcher when `indexing_progress`,
/// `indexing_complete`, or `indexing_error` events arrive.
@Riverpod(keepAlive: true)
class IndexingProgressMap extends _$IndexingProgressMap {
  @override
  Map<String, IndexingProgress> build() {
    return const {};
  }

  /// Update the progress for a single project.
  void update(IndexingProgress progress) {
    state = {...state, progress.projectId: progress};
  }

  /// Clear progress for a specific project.
  void clearProject(String projectId) {
    final updated = Map<String, IndexingProgress>.from(state);
    updated.remove(projectId);
    state = updated;
  }

  /// Clear all progress (e.g. on logout).
  void clearAll() {
    state = const {};
  }
}

// ---------------------------------------------------------------------------
// Convenience: indexing progress for the selected project
// ---------------------------------------------------------------------------

/// Returns the [IndexingProgress] for the currently selected project,
/// or `null` if no indexing is in progress.
@riverpod
IndexingProgress? selectedProjectIndexingProgress(Ref ref) {
  final selected = ref.watch(selectedProjectProvider).valueOrNull;
  if (selected == null) return null;

  final progressMap = ref.watch(indexingProgressMapProvider);
  return progressMap[selected.id];
}
