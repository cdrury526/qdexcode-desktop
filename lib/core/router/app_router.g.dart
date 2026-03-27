// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$routerHash() => r'd26bfc9638f7137206783668b728d5a49351e20c';

/// Provides the [GoRouter] instance for the application.
///
/// The router handles three states:
/// - Unauthenticated -> `/login`
/// - Authenticated with no projects -> `/onboarding`
/// - Authenticated with projects -> `/`
///
/// Routes:
/// - `/login` -- auth gate (Phase 1)
/// - `/onboarding` -- first-launch guided flow (Phase 2)
/// - `/` -- main 3-panel layout (Phase 2)
/// - `/projects/:id` -- project detail (Phase 3)
///
/// Copied from [router].
@ProviderFor(router)
final routerProvider = AutoDisposeProvider<GoRouter>.internal(
  router,
  name: r'routerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$routerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RouterRef = AutoDisposeProviderRef<GoRouter>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
