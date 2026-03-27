// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'git_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$currentBranchHash() => r'9701368a93e13430ab8072e8bc2eb31413d205ff';

/// The current branch name, or null if unavailable.
///
/// Copied from [currentBranch].
@ProviderFor(currentBranch)
final currentBranchProvider = AutoDisposeProvider<String?>.internal(
  currentBranch,
  name: r'currentBranchProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentBranchHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentBranchRef = AutoDisposeProviderRef<String?>;
String _$changeCountHash() => r'0b5c138b11692e7ed2bf02bc8d7cdcca2f360b1f';

/// The number of changed files, or null if unavailable.
///
/// Copied from [changeCount].
@ProviderFor(changeCount)
final changeCountProvider = AutoDisposeProvider<int?>.internal(
  changeCount,
  name: r'changeCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$changeCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ChangeCountRef = AutoDisposeProviderRef<int?>;
String _$gitStatusHash() => r'1f7f3cb1197df84c20accd303944da71d31a2ef6';

/// Provides the combined git state for the currently selected project.
///
/// Returns `null` when no project is selected or the project has no local path.
/// Auto-refreshes every 30 seconds via a periodic timer.
/// Watches [selectedProjectProvider] to auto-invalidate on project switch.
///
/// Copied from [GitStatus].
@ProviderFor(GitStatus)
final gitStatusProvider =
    AutoDisposeAsyncNotifierProvider<GitStatus, GitState?>.internal(
      GitStatus.new,
      name: r'gitStatusProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$gitStatusHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$GitStatus = AutoDisposeAsyncNotifier<GitState?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
