/// Riverpod providers for project state management.
///
/// Handles fetching projects from the API, persisting the selected project
/// in shared_preferences, and exposing project-related state to the UI.
library;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:qdexcode_desktop/core/api/api_client.dart';
import 'package:qdexcode_desktop/core/models/project.dart';

part 'project_provider.g.dart';

const _kSelectedProjectKey = 'selected_project_id';

// ---------------------------------------------------------------------------
// Projects list provider
// ---------------------------------------------------------------------------

/// Fetches all projects for the current organization from the API.
///
/// Caches the result and auto-disposes when no longer watched.
/// Invalidate to refetch (e.g. after creating or deleting a project).
@riverpod
class ProjectList extends _$ProjectList {
  @override
  Future<List<Project>> build() async {
    final dio = ref.watch(apiClientProvider);

    final response = await dio.get<dynamic>('/api/projects');
    final raw = response.data;
    if (raw == null) return [];
    final data = raw is List ? raw : <dynamic>[];
    if (data.isEmpty) return [];

    final projects = data
        .map((json) => Project.fromJson(json as Map<String, dynamic>))
        .toList();

    // Sort: indexed first, then by name.
    projects.sort((a, b) {
      final aIndexed = a.indexStatus == IndexStatus.indexed ? 0 : 1;
      final bIndexed = b.indexStatus == IndexStatus.indexed ? 0 : 1;
      final statusCmp = aIndexed.compareTo(bIndexed);
      if (statusCmp != 0) return statusCmp;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });

    return projects;
  }

  /// Refresh the project list from the API.
  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}

// ---------------------------------------------------------------------------
// Selected project provider
// ---------------------------------------------------------------------------

/// Manages the currently selected project.
///
/// Persists the selection in shared_preferences so it survives app restarts.
/// On first build, restores the previously selected project (or picks the
/// first available one).
@Riverpod(keepAlive: true)
class SelectedProject extends _$SelectedProject {
  @override
  Future<Project?> build() async {
    final projectsAsync = await ref.watch(projectListProvider.future);
    if (projectsAsync.isEmpty) return null;

    final prefs = await SharedPreferences.getInstance();
    final savedId = prefs.getString(_kSelectedProjectKey);

    if (savedId != null) {
      final match = projectsAsync.where((p) => p.id == savedId).firstOrNull;
      if (match != null) return match;
    }

    // Fallback to first project.
    return projectsAsync.first;
  }

  /// Switch to a different project and persist the choice.
  Future<void> select(Project project) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kSelectedProjectKey, project.id);
    state = AsyncData(project);
  }

  /// Clear the selection (e.g. when the selected project is deleted).
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kSelectedProjectKey);
    ref.invalidateSelf();
  }
}

// ---------------------------------------------------------------------------
// Project CRUD operations
// ---------------------------------------------------------------------------

/// Creates a new project via the API.
///
/// Returns the created [Project] on success.
/// Throws [DioException] on network/API errors.
@riverpod
class ProjectActions extends _$ProjectActions {
  @override
  FutureOr<void> build() {
    // No initial state needed — this is an action-only notifier.
  }

  /// Create a new project.
  ///
  /// After success, invalidates the project list so the UI refreshes.
  Future<Project> create({
    required String name,
    required String cloneUrl,
    String defaultBranch = 'main',
    String? localPath,
  }) async {
    final dio = ref.read(apiClientProvider);

    final response = await dio.post<Map<String, dynamic>>(
      '/api/projects',
      data: {
        'name': name,
        'clone_url': cloneUrl,
        'default_branch': defaultBranch,
        'local_path': localPath,
      },
    );

    final project = Project.fromJson(response.data!);

    // Refresh the project list.
    ref.invalidate(projectListProvider);

    // Auto-select the new project.
    await ref.read(selectedProjectProvider.notifier).select(project);

    return project;
  }

  /// Delete a project by ID.
  ///
  /// After success, invalidates the project list and clears selection if the
  /// deleted project was selected.
  Future<void> delete(String projectId) async {
    final dio = ref.read(apiClientProvider);
    await dio.delete('/api/projects/$projectId');

    // If we deleted the selected project, clear the selection.
    final selected = ref.read(selectedProjectProvider).valueOrNull;
    if (selected?.id == projectId) {
      await ref.read(selectedProjectProvider.notifier).clear();
    }

    ref.invalidate(projectListProvider);
  }
}

// ---------------------------------------------------------------------------
// GitHub repos provider (for Add Project dialog)
// ---------------------------------------------------------------------------

/// A GitHub repository from the user's account.
class GitHubRepo {
  const GitHubRepo({
    required this.id,
    required this.name,
    required this.fullName,
    required this.cloneUrl,
    required this.htmlUrl,
    required this.defaultBranch,
    this.description,
    this.language,
    this.isPrivate = false,
    this.updatedAt,
  });

  factory GitHubRepo.fromJson(Map<String, dynamic> json) {
    return GitHubRepo(
      id: json['id'] as int,
      name: json['name'] as String,
      fullName: json['full_name'] as String,
      cloneUrl: json['clone_url'] as String,
      htmlUrl: json['html_url'] as String,
      defaultBranch: json['default_branch'] as String? ?? 'main',
      description: json['description'] as String?,
      language: json['language'] as String?,
      isPrivate: json['private'] as bool? ?? false,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  final int id;
  final String name;
  final String fullName;
  final String cloneUrl;
  final String htmlUrl;
  final String defaultBranch;
  final String? description;
  final String? language;
  final bool isPrivate;
  final DateTime? updatedAt;
}

/// Fetches the authenticated user's GitHub repositories.
///
/// Uses the qdexcode API as a proxy (which has the GitHub token from OAuth).
@riverpod
Future<List<GitHubRepo>> githubRepos(Ref ref) async {
  final dio = ref.watch(apiClientProvider);

  final response = await dio.get<dynamic>(
    '/api/github/repos',
  );

  final raw = response.data;
  debugPrint('[githubRepos] status=${response.statusCode} type=${raw.runtimeType} len=${raw is List ? raw.length : 'N/A'}');
  if (raw == null) return [];
  final data = raw is List ? raw : <dynamic>[];
  if (data.isEmpty) {
    debugPrint('[githubRepos] empty — raw preview: ${raw.toString().substring(0, raw.toString().length.clamp(0, 200))}');
    return [];
  }

  final repos = data
      .map((json) => GitHubRepo.fromJson(json as Map<String, dynamic>))
      .toList();

  // Sort by most recently updated.
  repos.sort((a, b) {
    final aDate = a.updatedAt ?? DateTime(2000);
    final bDate = b.updatedAt ?? DateTime(2000);
    return bDate.compareTo(aDate);
  });

  return repos;
}
