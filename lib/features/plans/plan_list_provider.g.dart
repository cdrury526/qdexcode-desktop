// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plan_list_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$planDetailHash() => r'1b4e0c7b54c5d949af65fcd1d3249d1c5c967a2f';

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

/// Fetches a single plan by ID with all nested phases, tasks, subtasks,
/// acceptance criteria, and file scopes.
///
/// Copied from [planDetail].
@ProviderFor(planDetail)
const planDetailProvider = PlanDetailFamily();

/// Fetches a single plan by ID with all nested phases, tasks, subtasks,
/// acceptance criteria, and file scopes.
///
/// Copied from [planDetail].
class PlanDetailFamily extends Family<AsyncValue<Plan>> {
  /// Fetches a single plan by ID with all nested phases, tasks, subtasks,
  /// acceptance criteria, and file scopes.
  ///
  /// Copied from [planDetail].
  const PlanDetailFamily();

  /// Fetches a single plan by ID with all nested phases, tasks, subtasks,
  /// acceptance criteria, and file scopes.
  ///
  /// Copied from [planDetail].
  PlanDetailProvider call(String planId) {
    return PlanDetailProvider(planId);
  }

  @override
  PlanDetailProvider getProviderOverride(
    covariant PlanDetailProvider provider,
  ) {
    return call(provider.planId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'planDetailProvider';
}

/// Fetches a single plan by ID with all nested phases, tasks, subtasks,
/// acceptance criteria, and file scopes.
///
/// Copied from [planDetail].
class PlanDetailProvider extends AutoDisposeFutureProvider<Plan> {
  /// Fetches a single plan by ID with all nested phases, tasks, subtasks,
  /// acceptance criteria, and file scopes.
  ///
  /// Copied from [planDetail].
  PlanDetailProvider(String planId)
    : this._internal(
        (ref) => planDetail(ref as PlanDetailRef, planId),
        from: planDetailProvider,
        name: r'planDetailProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$planDetailHash,
        dependencies: PlanDetailFamily._dependencies,
        allTransitiveDependencies: PlanDetailFamily._allTransitiveDependencies,
        planId: planId,
      );

  PlanDetailProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.planId,
  }) : super.internal();

  final String planId;

  @override
  Override overrideWith(
    FutureOr<Plan> Function(PlanDetailRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PlanDetailProvider._internal(
        (ref) => create(ref as PlanDetailRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        planId: planId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Plan> createElement() {
    return _PlanDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PlanDetailProvider && other.planId == planId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, planId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PlanDetailRef on AutoDisposeFutureProviderRef<Plan> {
  /// The parameter `planId` of this provider.
  String get planId;
}

class _PlanDetailProviderElement extends AutoDisposeFutureProviderElement<Plan>
    with PlanDetailRef {
  _PlanDetailProviderElement(super.provider);

  @override
  String get planId => (origin as PlanDetailProvider).planId;
}

String _$planListHash() => r'37811e64b349214ee5072b4f570bbd3c0165f5fe';

/// Fetches all plans for the currently selected project from the API.
///
/// Watches [selectedProjectProvider] so plan data auto-refreshes when the
/// user switches projects. Returns an empty list if no project is selected.
///
/// Copied from [PlanList].
@ProviderFor(PlanList)
final planListProvider =
    AutoDisposeAsyncNotifierProvider<PlanList, List<Plan>>.internal(
      PlanList.new,
      name: r'planListProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$planListHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$PlanList = AutoDisposeAsyncNotifier<List<Plan>>;
String _$planNavigationHash() => r'60644e9620fd5aaa1ddb63eebf98a07336cb363f';

/// Manages navigation state for the plan explorer.
///
/// Kept alive so navigation state persists across tab switches.
///
/// Copied from [PlanNavigation].
@ProviderFor(PlanNavigation)
final planNavigationProvider =
    NotifierProvider<PlanNavigation, PlanNavigationState>.internal(
      PlanNavigation.new,
      name: r'planNavigationProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$planNavigationHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$PlanNavigation = Notifier<PlanNavigationState>;
String _$planTreeExpansionHash() => r'4bbada57605b769272d0ef92cbafd355a85217e1';

/// Tracks which plan and phase nodes are expanded in the left panel tree.
///
/// Copied from [PlanTreeExpansion].
@ProviderFor(PlanTreeExpansion)
final planTreeExpansionProvider =
    NotifierProvider<
      PlanTreeExpansion,
      ({Set<String> expandedPlanIds, Set<String> expandedPhaseIds})
    >.internal(
      PlanTreeExpansion.new,
      name: r'planTreeExpansionProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$planTreeExpansionHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$PlanTreeExpansion =
    Notifier<({Set<String> expandedPlanIds, Set<String> expandedPhaseIds})>;
String _$planFilterHash() => r'bcf425257cdabb36b1c81968c0857d0773dfb4aa';

/// Filter state for the plan tree.
///
/// Copied from [PlanFilter].
@ProviderFor(PlanFilter)
final planFilterProvider =
    NotifierProvider<
      PlanFilter,
      ({String searchQuery, bool hideCompleted})
    >.internal(
      PlanFilter.new,
      name: r'planFilterProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$planFilterHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$PlanFilter = Notifier<({String searchQuery, bool hideCompleted})>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
