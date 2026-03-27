/// GitHub repository picker for the Add Project dialog (step 1).
///
/// Fetches the user's GitHub repos, displays them in a searchable list,
/// and marks repos that are already indexed. Selected repo passes to step 2.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:qdexcode_desktop/core/theme/app_theme.dart';
import 'package:qdexcode_desktop/features/projects/project_provider.dart';

/// Callback when a GitHub repo is selected.
typedef OnRepoSelected = void Function(GitHubRepo repo);

/// Searchable list of the user's GitHub repos.
///
/// Repos already added as projects are shown at the bottom with a badge.
class GitHubRepoPicker extends ConsumerStatefulWidget {
  const GitHubRepoPicker({
    required this.onSelect,
    this.selectedRepo,
    super.key,
  });

  final OnRepoSelected onSelect;
  final GitHubRepo? selectedRepo;

  @override
  ConsumerState<GitHubRepoPicker> createState() => _GitHubRepoPickerState();
}

class _GitHubRepoPickerState extends ConsumerState<GitHubRepoPicker> {
  final _searchController = TextEditingController();
  String _filter = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reposAsync = ref.watch(githubReposProvider);
    final existingProjects = ref.watch(projectListProvider).valueOrNull ?? [];
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header.
        Text(
          'Select a GitHub repository to index.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: cs.onTertiary,
          ),
        ),
        const SizedBox(height: 12),

        // Search field.
        SizedBox(
          height: 36,
          child: TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _filter = value),
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Search repositories...',
              prefixIcon: const Icon(Icons.search_rounded, size: 18),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 36,
                minHeight: 36,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              suffixIcon: _filter.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _filter = '');
                      },
                      icon: const Icon(Icons.close_rounded, size: 16),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    )
                  : null,
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Repo list.
        Expanded(
          child: reposAsync.when(
            loading: () => const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            error: (error, _) => _RepoListError(error: error.toString()),
            data: (repos) {
              final existingUrls = existingProjects
                  .map((p) => _normalizeUrl(p.cloneUrl))
                  .toSet();

              final filtered = _filterAndSort(repos, existingUrls);

              if (filtered.isEmpty) {
                return Center(
                  child: Text(
                    _filter.isEmpty
                        ? 'No repositories found'
                        : 'No matches for "$_filter"',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onTertiary,
                    ),
                  ),
                );
              }

              return ListView.builder(
                itemCount: filtered.length,
                itemExtent: 56,
                itemBuilder: (context, index) {
                  final repo = filtered[index];
                  final isAlreadyIndexed =
                      existingUrls.contains(_normalizeUrl(repo.cloneUrl));
                  final isSelected =
                      widget.selectedRepo?.cloneUrl == repo.cloneUrl;

                  return _RepoListTile(
                    repo: repo,
                    isAlreadyIndexed: isAlreadyIndexed,
                    isSelected: isSelected,
                    onTap: isAlreadyIndexed
                        ? null
                        : () => widget.onSelect(repo),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  List<GitHubRepo> _filterAndSort(
    List<GitHubRepo> repos,
    Set<String> existingUrls,
  ) {
    var filtered = repos;
    if (_filter.isNotEmpty) {
      final lowerFilter = _filter.toLowerCase();
      filtered = repos
          .where((r) =>
              r.name.toLowerCase().contains(lowerFilter) ||
              r.fullName.toLowerCase().contains(lowerFilter) ||
              (r.description?.toLowerCase().contains(lowerFilter) ?? false))
          .toList();
    }

    // Sort: non-indexed first, then by name.
    filtered.sort((a, b) {
      final aIndexed =
          existingUrls.contains(_normalizeUrl(a.cloneUrl)) ? 1 : 0;
      final bIndexed =
          existingUrls.contains(_normalizeUrl(b.cloneUrl)) ? 1 : 0;
      final indexCmp = aIndexed.compareTo(bIndexed);
      if (indexCmp != 0) return indexCmp;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });

    return filtered;
  }
}

// ---------------------------------------------------------------------------
// Repo list tile
// ---------------------------------------------------------------------------

class _RepoListTile extends StatelessWidget {
  const _RepoListTile({
    required this.repo,
    required this.isAlreadyIndexed,
    required this.isSelected,
    this.onTap,
  });

  final GitHubRepo repo;
  final bool isAlreadyIndexed;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Material(
      color: isSelected
          ? cs.primary.withValues(alpha: 0.08)
          : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            children: [
              // Status indicator.
              if (isAlreadyIndexed)
                const Icon(
                  Icons.check_circle_rounded,
                  size: 16,
                  color: AppTheme.success,
                )
              else if (isSelected)
                Icon(
                  Icons.radio_button_checked_rounded,
                  size: 16,
                  color: cs.primary,
                )
              else
                Icon(
                  Icons.radio_button_off_rounded,
                  size: 16,
                  color: cs.onTertiary.withValues(alpha: 0.4),
                ),

              const SizedBox(width: 10),

              // Repo info.
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            repo.fullName,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                              color: isAlreadyIndexed
                                  ? cs.onTertiary
                                  : cs.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isAlreadyIndexed) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.success.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'indexed',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.success,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (repo.description != null &&
                        repo.description!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          repo.description!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 11,
                            color: cs.onTertiary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Language + visibility.
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (repo.language != null)
                    Text(
                      repo.language!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 10,
                        color: cs.onTertiary,
                      ),
                    ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        repo.isPrivate
                            ? Icons.lock_rounded
                            : Icons.public_rounded,
                        size: 12,
                        color: cs.onTertiary.withValues(alpha: 0.5),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        repo.isPrivate ? 'private' : 'public',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 10,
                          color: cs.onTertiary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Error state
// ---------------------------------------------------------------------------

class _RepoListError extends StatelessWidget {
  const _RepoListError({required this.error});

  final String error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 32,
            color: AppTheme.danger,
          ),
          const SizedBox(height: 8),
          Text(
            'Failed to load repositories',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            error,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onTertiary,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Normalize clone URLs for comparison.
///
/// Strips protocol, trailing .git, and lowercases.
String _normalizeUrl(String url) {
  var normalized = url.toLowerCase();
  normalized = normalized.replaceFirst(RegExp(r'^https?://'), '');
  normalized = normalized.replaceFirst(RegExp(r'\.git$'), '');
  return normalized;
}
