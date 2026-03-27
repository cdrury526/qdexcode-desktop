// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$themePreferenceHash() => r'a0401070db45e7fd541b40cec5dd816d889a8594';

/// User's theme preference: system, light, or dark.
///
/// Defaults to [ThemeMode.system] which follows the OS setting.
/// Persists the user's choice to shared_preferences so it survives restarts.
///
/// Copied from [ThemePreference].
@ProviderFor(ThemePreference)
final themePreferenceProvider =
    NotifierProvider<ThemePreference, ThemeMode>.internal(
      ThemePreference.new,
      name: r'themePreferenceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$themePreferenceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ThemePreference = Notifier<ThemeMode>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
