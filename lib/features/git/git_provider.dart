/// Riverpod providers for git status, branch, log, and changed files.
///
/// Watches [selectedProjectProvider] so the git panel auto-refreshes when the
/// user switches projects. Uses a 30-second timer for periodic refresh.
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:qdexcode_desktop/features/git/git_service.dart';
import 'package:qdexcode_desktop/features/projects/project_provider.dart';

part 'git_provider.g.dart';

// ---------------------------------------------------------------------------
// Combined git state
// ---------------------------------------------------------------------------

/// All git information for the selected project.
class GitState {
  const GitState({
    required this.repoCheck,
    required this.status,
    required this.commits,
    required this.changedFilesWithStats,
  });

  /// Whether the local path is a valid git repo.
  final GitRepoCheck repoCheck;

  /// Branch name, ahead/behind, and changed file list.
  final GitStatusResult status;

  /// Recent commit log.
  final List<GitCommit> commits;

  /// Changed files with +/- line stats merged in.
  final List<GitChangedFile> changedFilesWithStats;
}

// ---------------------------------------------------------------------------
// Main git state provider
// ---------------------------------------------------------------------------

/// Provides the combined git state for the currently selected project.
///
/// Returns `null` when no project is selected or the project has no local path.
/// Auto-refreshes every 30 seconds via a periodic timer.
/// Watches [selectedProjectProvider] to auto-invalidate on project switch.
@riverpod
class GitStatus extends _$GitStatus {
  Timer? _refreshTimer;

  @override
  Future<GitState?> build() async {
    // Watch the selected project for reactive updates.
    final projectAsync = ref.watch(selectedProjectProvider);
    final project = projectAsync.valueOrNull;

    if (project == null) return null;

    final localPath = project.localPath;
    if (localPath == null || localPath.isEmpty) return null;

    // Start the 30-second auto-refresh timer.
    _startAutoRefresh();

    // Cancel timer when provider is disposed.
    ref.onDispose(_stopAutoRefresh);

    return _fetchGitState(localPath);
  }

  /// Force a manual refresh.
  Future<void> refresh() async {
    ref.invalidateSelf();
  }

  /// Trigger a refresh from external events (e.g. file watcher).
  void notifyFileChanged() {
    ref.invalidateSelf();
  }

  void _startAutoRefresh() {
    _stopAutoRefresh();
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => ref.invalidateSelf(),
    );
  }

  void _stopAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }
}

/// Fetch all git data for a local path.
Future<GitState> _fetchGitState(String localPath) async {
  // Check if it's a valid git repo first.
  final repoCheck = await GitService.checkRepository(localPath);

  if (repoCheck != GitRepoCheck.valid) {
    return GitState(
      repoCheck: repoCheck,
      status: const GitStatusResult(
        branch: '',
        upstream: '',
        ahead: 0,
        behind: 0,
        changedFiles: [],
      ),
      commits: const [],
      changedFilesWithStats: const [],
    );
  }

  // Run all git commands in parallel.
  final results = await Future.wait([
    GitService.getStatus(localPath),
    GitService.getLog(localPath),
    GitService.getDiffStats(localPath),
  ]);

  final status = results[0] as GitStatusResult;
  final commits = results[1] as List<GitCommit>;
  final diffStats = results[2] as Map<String, (int, int)>;

  // Merge diff stats into changed files.
  final filesWithStats = status.changedFiles.map((file) {
    final stats = diffStats[file.path];
    if (stats != null) {
      return file.withStats(additions: stats.$1, deletions: stats.$2);
    }
    return file;
  }).toList();

  // Sort: modified first, then added, deleted, renamed, untracked.
  filesWithStats.sort((a, b) {
    final aOrder = a.status.index;
    final bOrder = b.status.index;
    if (aOrder != bOrder) return aOrder.compareTo(bOrder);
    return a.path.compareTo(b.path);
  });

  return GitState(
    repoCheck: repoCheck,
    status: status,
    commits: commits,
    changedFilesWithStats: filesWithStats,
  );
}

// ---------------------------------------------------------------------------
// Convenience providers — derived from GitStatus
// ---------------------------------------------------------------------------

/// The current branch name, or null if unavailable.
@riverpod
String? currentBranch(Ref ref) {
  final gitState = ref.watch(gitStatusProvider).valueOrNull;
  if (gitState == null) return null;
  return gitState.status.branch.isNotEmpty ? gitState.status.branch : null;
}

/// The number of changed files, or null if unavailable.
@riverpod
int? changeCount(Ref ref) {
  final gitState = ref.watch(gitStatusProvider).valueOrNull;
  return gitState?.status.changeCount;
}
