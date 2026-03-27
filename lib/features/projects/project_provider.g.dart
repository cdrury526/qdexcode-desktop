// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$githubReposHash() => r'f48860b96e1375762a284815aa0ed472cfdc3c97';

/// Fetches the authenticated user's GitHub repositories.
///
/// Uses the qdexcode API as a proxy (which has the GitHub token from OAuth).
///
/// Copied from [githubRepos].
@ProviderFor(githubRepos)
final githubReposProvider =
    AutoDisposeFutureProvider<List<GitHubRepo>>.internal(
      githubRepos,
      name: r'githubReposProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$githubReposHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GithubReposRef = AutoDisposeFutureProviderRef<List<GitHubRepo>>;
String _$projectListHash() => r'c42ea76852aa15d9bd85a6adc72fc2b9af761bd0';

/// Fetches all projects for the current organization from the API.
///
/// Caches the result and auto-disposes when no longer watched.
/// Invalidate to refetch (e.g. after creating or deleting a project).
///
/// Copied from [ProjectList].
@ProviderFor(ProjectList)
final projectListProvider =
    AutoDisposeAsyncNotifierProvider<ProjectList, List<Project>>.internal(
      ProjectList.new,
      name: r'projectListProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$projectListHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ProjectList = AutoDisposeAsyncNotifier<List<Project>>;
String _$selectedProjectHash() => r'7a900ac3def1b74d47e3021284fe3980bc5448f8';

/// Manages the currently selected project.
///
/// Persists the selection in shared_preferences so it survives app restarts.
/// On first build, restores the previously selected project (or picks the
/// first available one).
///
/// Copied from [SelectedProject].
@ProviderFor(SelectedProject)
final selectedProjectProvider =
    AsyncNotifierProvider<SelectedProject, Project?>.internal(
      SelectedProject.new,
      name: r'selectedProjectProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$selectedProjectHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SelectedProject = AsyncNotifier<Project?>;
String _$projectActionsHash() => r'f0ab85a2c7768c6c6f2eef4656ca3f2d10b7313a';

/// Creates a new project via the API.
///
/// Returns the created [Project] on success.
/// Throws [DioException] on network/API errors.
///
/// Copied from [ProjectActions].
@ProviderFor(ProjectActions)
final projectActionsProvider =
    AutoDisposeAsyncNotifierProvider<ProjectActions, void>.internal(
      ProjectActions.new,
      name: r'projectActionsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$projectActionsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ProjectActions = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
