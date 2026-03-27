// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'window_state_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$windowStateServiceHash() =>
    r'b0c446731e1c94724ee497a7559d3fd095b882c6';

/// Provides the [WindowStateService] singleton.
///
/// Copied from [windowStateService].
@ProviderFor(windowStateService)
final windowStateServiceProvider = Provider<WindowStateService>.internal(
  windowStateService,
  name: r'windowStateServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$windowStateServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WindowStateServiceRef = ProviderRef<WindowStateService>;
String _$windowGeometryStateHash() =>
    r'047f3f77da3498183eb29bc41bf8baac9371b503';

/// Manages window geometry (position + size) with debounced persistence.
///
/// Loads the saved geometry on build, and exposes [update] for the
/// window listener to call on move/resize. Saves are debounced to avoid
/// writing on every pixel of a drag.
///
/// Copied from [WindowGeometryState].
@ProviderFor(WindowGeometryState)
final windowGeometryStateProvider =
    NotifierProvider<WindowGeometryState, WindowGeometry>.internal(
      WindowGeometryState.new,
      name: r'windowGeometryStateProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$windowGeometryStateHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$WindowGeometryState = Notifier<WindowGeometry>;
String _$panelWidthsStateHash() => r'50b77df92c0048e1f341c2438a11f22fb5f20aed';

/// Manages panel width flex proportions with debounced persistence.
///
/// Copied from [PanelWidthsState].
@ProviderFor(PanelWidthsState)
final panelWidthsStateProvider =
    NotifierProvider<PanelWidthsState, PanelWidths>.internal(
      PanelWidthsState.new,
      name: r'panelWidthsStateProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$panelWidthsStateHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$PanelWidthsState = Notifier<PanelWidths>;
String _$activeTabStateHash() => r'2d59aadf9d2103edd39a2ae09c0dce9ed4cf5868';

/// Manages the active center workspace tab with immediate persistence.
///
/// Copied from [ActiveTabState].
@ProviderFor(ActiveTabState)
final activeTabStateProvider =
    NotifierProvider<ActiveTabState, String>.internal(
      ActiveTabState.new,
      name: r'activeTabStateProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$activeTabStateHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ActiveTabState = Notifier<String>;
String _$selectedProjectStateHash() =>
    r'062e90197cd80e39cabffa4a9b5c66d5f1ec426d';

/// Manages the selected project ID with immediate persistence.
///
/// Copied from [SelectedProjectState].
@ProviderFor(SelectedProjectState)
final selectedProjectStateProvider =
    NotifierProvider<SelectedProjectState, String?>.internal(
      SelectedProjectState.new,
      name: r'selectedProjectStateProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$selectedProjectStateHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SelectedProjectState = Notifier<String?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
