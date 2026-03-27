// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'realtime_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$selectedProjectIndexingProgressHash() =>
    r'17a8930e36dac8e449602ed009c080b1ffb4df47';

/// Returns the [IndexingProgress] for the currently selected project,
/// or `null` if no indexing is in progress.
///
/// Copied from [selectedProjectIndexingProgress].
@ProviderFor(selectedProjectIndexingProgress)
final selectedProjectIndexingProgressProvider =
    AutoDisposeProvider<IndexingProgress?>.internal(
      selectedProjectIndexingProgress,
      name: r'selectedProjectIndexingProgressProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$selectedProjectIndexingProgressHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SelectedProjectIndexingProgressRef =
    AutoDisposeProviderRef<IndexingProgress?>;
String _$realtimeHash() => r'07f2688334fd978bacbb1353b54940d1b0c43da6';

/// Provides the [RealtimeService] singleton, kept alive for the app lifetime.
///
/// Watches auth state: connects when authenticated, disconnects on logout.
/// Watches the selected project's organization ID: reconnects with a fresh
/// JWT when the org changes (the JWT encodes org_id).
///
/// Copied from [Realtime].
@ProviderFor(Realtime)
final realtimeProvider = NotifierProvider<Realtime, RealtimeService>.internal(
  Realtime.new,
  name: r'realtimeProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$realtimeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Realtime = Notifier<RealtimeService>;
String _$realtimeConnectionStatusHash() =>
    r'568370658bb5fdba6b6e27c5b5fe620177134442';

/// Provides the current [ConnectionStatus] as a stream.
///
/// Widgets like [ConnectionBadge] watch this for reactive status updates.
///
/// Copied from [RealtimeConnectionStatus].
@ProviderFor(RealtimeConnectionStatus)
final realtimeConnectionStatusProvider =
    NotifierProvider<RealtimeConnectionStatus, ConnectionStatus>.internal(
      RealtimeConnectionStatus.new,
      name: r'realtimeConnectionStatusProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$realtimeConnectionStatusHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$RealtimeConnectionStatus = Notifier<ConnectionStatus>;
String _$realtimeMessagesHash() => r'1bd9d892e9677386869eb6d36f3990336cc74a45';

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
///
/// Copied from [RealtimeMessages].
@ProviderFor(RealtimeMessages)
final realtimeMessagesProvider =
    NotifierProvider<RealtimeMessages, RealtimeMessage?>.internal(
      RealtimeMessages.new,
      name: r'realtimeMessagesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$realtimeMessagesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$RealtimeMessages = Notifier<RealtimeMessage?>;
String _$indexingProgressMapHash() =>
    r'1dbc25ac0a0cd77160fafe79c6f7fcbcd384a7e8';

/// Tracks active indexing progress keyed by project ID.
///
/// Updated by the realtime message dispatcher when `indexing_progress`,
/// `indexing_complete`, or `indexing_error` events arrive.
///
/// Copied from [IndexingProgressMap].
@ProviderFor(IndexingProgressMap)
final indexingProgressMapProvider =
    NotifierProvider<
      IndexingProgressMap,
      Map<String, IndexingProgress>
    >.internal(
      IndexingProgressMap.new,
      name: r'indexingProgressMapProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$indexingProgressMapHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$IndexingProgressMap = Notifier<Map<String, IndexingProgress>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
