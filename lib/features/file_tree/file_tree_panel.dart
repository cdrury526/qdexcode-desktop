/// File tree panel for the right sidebar.
///
/// Displays a virtualized tree view of the selected project's local directory.
/// When no local_path is set, shows a "Choose local path" button.
/// Uses ListView.builder for performance on projects with 10,000+ files.
library;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:qdexcode_desktop/core/api/api_client.dart';
import 'package:qdexcode_desktop/features/file_tree/file_tree_node.dart';
import 'package:qdexcode_desktop/features/file_tree/file_tree_provider.dart';
import 'package:qdexcode_desktop/features/projects/project_provider.dart';

/// The main file tree panel widget, designed to fill an [Expanded] slot
/// in the right panel.
///
/// Three states:
/// 1. No project selected -> empty prompt
/// 2. Project selected but no localPath -> "Choose local path" button
/// 3. Project with localPath -> virtualized tree view
class FileTreePanel extends ConsumerStatefulWidget {
  const FileTreePanel({super.key});

  @override
  ConsumerState<FileTreePanel> createState() => _FileTreePanelState();
}

class _FileTreePanelState extends ConsumerState<FileTreePanel> {
  bool _settingPath = false;

  @override
  Widget build(BuildContext context) {
    final projectAsync = ref.watch(selectedProjectProvider);

    return projectAsync.when(
      loading: () => const _SkeletonTree(),
      error: (_, _) => const _EmptyState(
        icon: Icons.error_outline_rounded,
        message: 'Error loading project',
      ),
      data: (project) {
        if (project == null) {
          return const _EmptyState(
            icon: Icons.folder_off_rounded,
            message: 'No project selected',
          );
        }

        if (project.localPath == null || project.localPath!.isEmpty) {
          return _ChoosePathState(
            projectName: project.name,
            isLoading: _settingPath,
            onChoosePath: () => _choosePath(project.id),
          );
        }

        return _FileTreeView(rootPath: project.localPath!);
      },
    );
  }

  Future<void> _choosePath(String projectId) async {
    final result = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Select project directory',
    );

    if (result == null || !mounted) return;

    setState(() => _settingPath = true);

    try {
      final dio = ref.read(apiClientProvider);
      await dio.patch<Map<String, dynamic>>(
        '/api/projects/$projectId',
        data: {'local_path': result},
      );

      // Refresh the project list so the selected project picks up the new path.
      ref.invalidate(projectListProvider);
      ref.invalidate(selectedProjectProvider);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to set local path')),
        );
      }
    } finally {
      if (mounted) setState(() => _settingPath = false);
    }
  }
}

// ---------------------------------------------------------------------------
// Virtualized tree view
// ---------------------------------------------------------------------------

class _FileTreeView extends ConsumerWidget {
  const _FileTreeView({required this.rootPath});

  final String rootPath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final treeAsync = ref.watch(flatFileTreeProvider);

    return treeAsync.when(
      loading: () => const _SkeletonTree(),
      error: (err, _) => _EmptyState(
        icon: Icons.warning_rounded,
        message: 'Cannot read directory\n${err.toString().split('\n').first}',
      ),
      data: (entries) {
        if (entries.isEmpty) {
          return const _EmptyState(
            icon: Icons.folder_open_rounded,
            message: 'Directory is empty',
          );
        }

        return Column(
          children: [
            // Breadcrumb / root path indicator.
            _RootPathBar(rootPath: rootPath, ref: ref),

            // Virtualized tree.
            Expanded(
              child: ListView.builder(
                itemCount: entries.length,
                itemExtent: 30, // Fixed height for virtualization.
                itemBuilder: (context, index) {
                  final flat = entries[index];
                  return FileTreeNode(
                    key: ValueKey(flat.entry.path),
                    entry: flat.entry,
                    depth: flat.depth,
                    isExpanded: flat.isExpanded,
                    onTap: () => _onTap(ref, flat),
                    onDoubleTap: flat.entry.isDirectory
                        ? null
                        : () => _onFileDoubleTap(context),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _onTap(WidgetRef ref, FlatTreeEntry flat) {
    if (flat.entry.isDirectory) {
      ref.read(fileTreeExpansionProvider.notifier).toggle(flat.entry.path);
    }
  }

  void _onFileDoubleTap(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Editor coming soon'),
        duration: Duration(seconds: 1),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Root path bar
// ---------------------------------------------------------------------------

class _RootPathBar extends StatelessWidget {
  const _RootPathBar({
    required this.rootPath,
    required this.ref,
  });

  final String rootPath;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // Show just the last path segment as the root name.
    final rootName = rootPath.split('/').last;

    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: cs.outline, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.folder_rounded,
            size: 14,
            color: Color(0xFFE8A838),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              rootName,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          _RefreshButton(
            onTap: () {
              ref.invalidate(flatFileTreeProvider);
            },
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Refresh button
// ---------------------------------------------------------------------------

class _RefreshButton extends StatefulWidget {
  const _RefreshButton({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_RefreshButton> createState() => _RefreshButtonState();
}

class _RefreshButtonState extends State<_RefreshButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Tooltip(
          message: 'Refresh file tree',
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: _hovered ? cs.secondary : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              Icons.refresh_rounded,
              size: 14,
              color: _hovered ? cs.onSecondary : cs.onTertiary,
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// "Choose local path" empty state
// ---------------------------------------------------------------------------

class _ChoosePathState extends StatelessWidget {
  const _ChoosePathState({
    required this.projectName,
    required this.isLoading,
    required this.onChoosePath,
  });

  final String projectName;
  final bool isLoading;
  final VoidCallback onChoosePath;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.folder_off_rounded,
              size: 28,
              color: cs.onTertiary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 8),
            Text(
              'No local path set',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 12,
                color: cs.onTertiary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Point to the local checkout of\n$projectName',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 11,
                color: cs.onTertiary.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 30,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : onChoosePath,
                icon: isLoading
                    ? SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: cs.onPrimary,
                        ),
                      )
                    : const Icon(Icons.folder_open_rounded, size: 14),
                label: Text(
                  isLoading ? 'Setting...' : 'Choose local path',
                  style: const TextStyle(fontSize: 12),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Generic empty state
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.message,
  });

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24, color: cs.onTertiary.withValues(alpha: 0.4)),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onTertiary.withValues(alpha: 0.6),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Skeleton loading state
// ---------------------------------------------------------------------------

class _SkeletonTree extends StatelessWidget {
  const _SkeletonTree();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(8, (index) {
          // Vary width and indent for visual variety.
          final indent = (index % 3) * 12.0 + 8.0;
          final widthFraction = 0.4 + (index % 4) * 0.1;

          return Padding(
            padding: EdgeInsets.only(left: indent, bottom: 6),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              height: 12,
              width: MediaQuery.sizeOf(context).width * widthFraction,
              decoration: BoxDecoration(
                color: cs.tertiary.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          );
        }),
      ),
    );
  }
}
