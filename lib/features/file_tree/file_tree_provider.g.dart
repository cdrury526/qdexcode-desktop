// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file_tree_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$directoryChildrenHash() => r'262dfca68d4b9ec343d0c36fba81441a8263a0c2';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Lists the immediate children of [directoryPath], sorted dirs-first then
/// alphabetically.
///
/// Auto-disposes when the widget that requested the listing is removed —
/// this keeps memory bounded even for huge trees.
///
/// Copied from [directoryChildren].
@ProviderFor(directoryChildren)
const directoryChildrenProvider = DirectoryChildrenFamily();

/// Lists the immediate children of [directoryPath], sorted dirs-first then
/// alphabetically.
///
/// Auto-disposes when the widget that requested the listing is removed —
/// this keeps memory bounded even for huge trees.
///
/// Copied from [directoryChildren].
class DirectoryChildrenFamily extends Family<AsyncValue<List<FileTreeEntry>>> {
  /// Lists the immediate children of [directoryPath], sorted dirs-first then
  /// alphabetically.
  ///
  /// Auto-disposes when the widget that requested the listing is removed —
  /// this keeps memory bounded even for huge trees.
  ///
  /// Copied from [directoryChildren].
  const DirectoryChildrenFamily();

  /// Lists the immediate children of [directoryPath], sorted dirs-first then
  /// alphabetically.
  ///
  /// Auto-disposes when the widget that requested the listing is removed —
  /// this keeps memory bounded even for huge trees.
  ///
  /// Copied from [directoryChildren].
  DirectoryChildrenProvider call(String directoryPath) {
    return DirectoryChildrenProvider(directoryPath);
  }

  @override
  DirectoryChildrenProvider getProviderOverride(
    covariant DirectoryChildrenProvider provider,
  ) {
    return call(provider.directoryPath);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'directoryChildrenProvider';
}

/// Lists the immediate children of [directoryPath], sorted dirs-first then
/// alphabetically.
///
/// Auto-disposes when the widget that requested the listing is removed —
/// this keeps memory bounded even for huge trees.
///
/// Copied from [directoryChildren].
class DirectoryChildrenProvider
    extends AutoDisposeFutureProvider<List<FileTreeEntry>> {
  /// Lists the immediate children of [directoryPath], sorted dirs-first then
  /// alphabetically.
  ///
  /// Auto-disposes when the widget that requested the listing is removed —
  /// this keeps memory bounded even for huge trees.
  ///
  /// Copied from [directoryChildren].
  DirectoryChildrenProvider(String directoryPath)
    : this._internal(
        (ref) => directoryChildren(ref as DirectoryChildrenRef, directoryPath),
        from: directoryChildrenProvider,
        name: r'directoryChildrenProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$directoryChildrenHash,
        dependencies: DirectoryChildrenFamily._dependencies,
        allTransitiveDependencies:
            DirectoryChildrenFamily._allTransitiveDependencies,
        directoryPath: directoryPath,
      );

  DirectoryChildrenProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.directoryPath,
  }) : super.internal();

  final String directoryPath;

  @override
  Override overrideWith(
    FutureOr<List<FileTreeEntry>> Function(DirectoryChildrenRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DirectoryChildrenProvider._internal(
        (ref) => create(ref as DirectoryChildrenRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        directoryPath: directoryPath,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<FileTreeEntry>> createElement() {
    return _DirectoryChildrenProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DirectoryChildrenProvider &&
        other.directoryPath == directoryPath;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, directoryPath.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DirectoryChildrenRef
    on AutoDisposeFutureProviderRef<List<FileTreeEntry>> {
  /// The parameter `directoryPath` of this provider.
  String get directoryPath;
}

class _DirectoryChildrenProviderElement
    extends AutoDisposeFutureProviderElement<List<FileTreeEntry>>
    with DirectoryChildrenRef {
  _DirectoryChildrenProviderElement(super.provider);

  @override
  String get directoryPath =>
      (origin as DirectoryChildrenProvider).directoryPath;
}

String _$directoryWatcherHash() => r'05e618eae624b0c1548ba0283e268df201e6ba6c';

/// Watches [directoryPath] for filesystem events and pushes a stream of
/// change notifications.
///
/// Consumers should invalidate [directoryChildrenProvider] for the affected
/// path when events arrive.
///
/// Copied from [directoryWatcher].
@ProviderFor(directoryWatcher)
const directoryWatcherProvider = DirectoryWatcherFamily();

/// Watches [directoryPath] for filesystem events and pushes a stream of
/// change notifications.
///
/// Consumers should invalidate [directoryChildrenProvider] for the affected
/// path when events arrive.
///
/// Copied from [directoryWatcher].
class DirectoryWatcherFamily extends Family<AsyncValue<FileSystemEvent>> {
  /// Watches [directoryPath] for filesystem events and pushes a stream of
  /// change notifications.
  ///
  /// Consumers should invalidate [directoryChildrenProvider] for the affected
  /// path when events arrive.
  ///
  /// Copied from [directoryWatcher].
  const DirectoryWatcherFamily();

  /// Watches [directoryPath] for filesystem events and pushes a stream of
  /// change notifications.
  ///
  /// Consumers should invalidate [directoryChildrenProvider] for the affected
  /// path when events arrive.
  ///
  /// Copied from [directoryWatcher].
  DirectoryWatcherProvider call(String directoryPath) {
    return DirectoryWatcherProvider(directoryPath);
  }

  @override
  DirectoryWatcherProvider getProviderOverride(
    covariant DirectoryWatcherProvider provider,
  ) {
    return call(provider.directoryPath);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'directoryWatcherProvider';
}

/// Watches [directoryPath] for filesystem events and pushes a stream of
/// change notifications.
///
/// Consumers should invalidate [directoryChildrenProvider] for the affected
/// path when events arrive.
///
/// Copied from [directoryWatcher].
class DirectoryWatcherProvider
    extends AutoDisposeStreamProvider<FileSystemEvent> {
  /// Watches [directoryPath] for filesystem events and pushes a stream of
  /// change notifications.
  ///
  /// Consumers should invalidate [directoryChildrenProvider] for the affected
  /// path when events arrive.
  ///
  /// Copied from [directoryWatcher].
  DirectoryWatcherProvider(String directoryPath)
    : this._internal(
        (ref) => directoryWatcher(ref as DirectoryWatcherRef, directoryPath),
        from: directoryWatcherProvider,
        name: r'directoryWatcherProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$directoryWatcherHash,
        dependencies: DirectoryWatcherFamily._dependencies,
        allTransitiveDependencies:
            DirectoryWatcherFamily._allTransitiveDependencies,
        directoryPath: directoryPath,
      );

  DirectoryWatcherProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.directoryPath,
  }) : super.internal();

  final String directoryPath;

  @override
  Override overrideWith(
    Stream<FileSystemEvent> Function(DirectoryWatcherRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DirectoryWatcherProvider._internal(
        (ref) => create(ref as DirectoryWatcherRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        directoryPath: directoryPath,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<FileSystemEvent> createElement() {
    return _DirectoryWatcherProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DirectoryWatcherProvider &&
        other.directoryPath == directoryPath;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, directoryPath.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DirectoryWatcherRef on AutoDisposeStreamProviderRef<FileSystemEvent> {
  /// The parameter `directoryPath` of this provider.
  String get directoryPath;
}

class _DirectoryWatcherProviderElement
    extends AutoDisposeStreamProviderElement<FileSystemEvent>
    with DirectoryWatcherRef {
  _DirectoryWatcherProviderElement(super.provider);

  @override
  String get directoryPath =>
      (origin as DirectoryWatcherProvider).directoryPath;
}

String _$fileTreeRootPathHash() => r'4c1c524e2bdf7aed16a5b34c1bc8d72ac816afad';

/// The local root path for the file tree, derived from the selected project.
///
/// Returns `null` when no project is selected or the project has no localPath.
///
/// Copied from [fileTreeRootPath].
@ProviderFor(fileTreeRootPath)
final fileTreeRootPathProvider = AutoDisposeProvider<String?>.internal(
  fileTreeRootPath,
  name: r'fileTreeRootPathProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$fileTreeRootPathHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FileTreeRootPathRef = AutoDisposeProviderRef<String?>;
String _$fileTreeExpansionHash() => r'b6cbba5c7858232a8dff9e49e5cdab3239d3eedc';

/// Tracks which directories are currently expanded in the tree.
///
/// Kept alive so expansion state survives brief widget rebuilds.
///
/// Copied from [FileTreeExpansion].
@ProviderFor(FileTreeExpansion)
final fileTreeExpansionProvider =
    NotifierProvider<FileTreeExpansion, Set<String>>.internal(
      FileTreeExpansion.new,
      name: r'fileTreeExpansionProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$fileTreeExpansionHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$FileTreeExpansion = Notifier<Set<String>>;
String _$flatFileTreeHash() => r'c003ebd9ea225c9eefe95ac1e52ad32a31960996';

/// Produces a flattened list of visible tree entries for ListView.builder.
///
/// Recursively includes children of expanded directories. Only the visible
/// (expanded) portion of the tree is materialized.
///
/// Copied from [FlatFileTree].
@ProviderFor(FlatFileTree)
final flatFileTreeProvider =
    AutoDisposeAsyncNotifierProvider<
      FlatFileTree,
      List<FlatTreeEntry>
    >.internal(
      FlatFileTree.new,
      name: r'flatFileTreeProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$flatFileTreeHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$FlatFileTree = AutoDisposeAsyncNotifier<List<FlatTreeEntry>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
