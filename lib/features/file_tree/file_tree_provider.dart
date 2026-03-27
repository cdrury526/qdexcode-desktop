/// Riverpod providers for file tree state management.
///
/// Reads the local filesystem using dart:io, watches for changes,
/// and exposes a lazy-loaded directory tree to the UI.
library;

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:qdexcode_desktop/features/projects/project_provider.dart';

part 'file_tree_provider.g.dart';

// ---------------------------------------------------------------------------
// File tree node model
// ---------------------------------------------------------------------------

/// A single node in the file tree (file or directory).
@immutable
class FileTreeEntry implements Comparable<FileTreeEntry> {
  const FileTreeEntry({
    required this.name,
    required this.path,
    required this.isDirectory,
    this.size,
  });

  final String name;
  final String path;
  final bool isDirectory;
  final int? size;

  @override
  int compareTo(FileTreeEntry other) {
    // Directories first, then alphabetical (case-insensitive).
    if (isDirectory != other.isDirectory) {
      return isDirectory ? -1 : 1;
    }
    return name.toLowerCase().compareTo(other.name.toLowerCase());
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FileTreeEntry &&
          runtimeType == other.runtimeType &&
          path == other.path;

  @override
  int get hashCode => path.hashCode;
}

// ---------------------------------------------------------------------------
// Default ignore patterns
// ---------------------------------------------------------------------------

/// Directories and files hidden by default (similar to .gitignore defaults).
const _defaultIgnorePatterns = <String>{
  '.git',
  '.svn',
  '.hg',
  'node_modules',
  '.dart_tool',
  'build',
  '.build',
  '.idea',
  '.vscode',
  '__pycache__',
  '.DS_Store',
  'Thumbs.db',
  '.flutter-plugins',
  '.flutter-plugins-dependencies',
  '.packages',
};

/// Whether a filename should be hidden by default.
bool _isIgnored(String name) => _defaultIgnorePatterns.contains(name);

// ---------------------------------------------------------------------------
// Directory listing provider (per-directory, lazy)
// ---------------------------------------------------------------------------

/// Lists the immediate children of [directoryPath], sorted dirs-first then
/// alphabetically.
///
/// Auto-disposes when the widget that requested the listing is removed —
/// this keeps memory bounded even for huge trees.
@riverpod
Future<List<FileTreeEntry>> directoryChildren(
  Ref ref,
  String directoryPath,
) async {
  final dir = Directory(directoryPath);
  if (!await dir.exists()) return const [];

  final entries = <FileTreeEntry>[];

  await for (final entity in dir.list(followLinks: false)) {
    final name = entity.path.split(Platform.pathSeparator).last;

    // Skip hidden/ignored entries.
    if (_isIgnored(name)) continue;

    final isDir = entity is Directory;
    int? size;
    if (!isDir) {
      try {
        size = await (entity as File).length();
      } on FileSystemException {
        // Permission denied or broken symlink — skip size.
      }
    }

    entries.add(FileTreeEntry(
      name: name,
      path: entity.path,
      isDirectory: isDir,
      size: size,
    ));
  }

  entries.sort();
  return entries;
}

// ---------------------------------------------------------------------------
// File watcher provider
// ---------------------------------------------------------------------------

/// Watches [directoryPath] for filesystem events and pushes a stream of
/// change notifications.
///
/// Consumers should invalidate [directoryChildrenProvider] for the affected
/// path when events arrive.
@riverpod
Stream<FileSystemEvent> directoryWatcher(Ref ref, String directoryPath) {
  final dir = Directory(directoryPath);

  // We cannot watch a non-existent directory.
  if (!dir.existsSync()) return const Stream.empty();

  // Debounce rapid FS events (e.g. git checkout touching many files).
  final controller = StreamController<FileSystemEvent>();
  Timer? debounce;

  final subscription = dir.watch().listen((event) {
    debounce?.cancel();
    debounce = Timer(const Duration(milliseconds: 300), () {
      if (!controller.isClosed) {
        controller.add(event);
      }
    });
  });

  ref.onDispose(() {
    debounce?.cancel();
    subscription.cancel();
    controller.close();
  });

  return controller.stream;
}

// ---------------------------------------------------------------------------
// Root path provider (derived from selected project)
// ---------------------------------------------------------------------------

/// The local root path for the file tree, derived from the selected project.
///
/// Returns `null` when no project is selected or the project has no localPath.
@riverpod
String? fileTreeRootPath(Ref ref) {
  final projectAsync = ref.watch(selectedProjectProvider);
  final project = projectAsync.valueOrNull;
  return project?.localPath;
}

// ---------------------------------------------------------------------------
// Expansion state (UI state)
// ---------------------------------------------------------------------------

/// Tracks which directories are currently expanded in the tree.
///
/// Kept alive so expansion state survives brief widget rebuilds.
@Riverpod(keepAlive: true)
class FileTreeExpansion extends _$FileTreeExpansion {
  @override
  Set<String> build() => {};

  /// Toggle the expanded state of a directory path.
  void toggle(String path) {
    if (state.contains(path)) {
      state = {...state}..remove(path);
    } else {
      state = {...state, path};
    }
  }

  /// Expand a directory.
  void expand(String path) {
    if (!state.contains(path)) {
      state = {...state, path};
    }
  }

  /// Collapse a directory.
  void collapse(String path) {
    if (state.contains(path)) {
      state = {...state}..remove(path);
    }
  }

  /// Collapse all and clear expansion state (e.g. on project switch).
  void reset() {
    state = {};
  }
}

// ---------------------------------------------------------------------------
// Flattened tree provider (for virtualized rendering)
// ---------------------------------------------------------------------------

/// A flattened entry for virtualized rendering — includes depth for
/// indentation.
@immutable
class FlatTreeEntry {
  const FlatTreeEntry({
    required this.entry,
    required this.depth,
    required this.isExpanded,
    required this.isLoading,
  });

  final FileTreeEntry entry;
  final int depth;
  final bool isExpanded;
  final bool isLoading;
}

/// Produces a flattened list of visible tree entries for ListView.builder.
///
/// Recursively includes children of expanded directories. Only the visible
/// (expanded) portion of the tree is materialized.
@riverpod
class FlatFileTree extends _$FlatFileTree {
  @override
  Future<List<FlatTreeEntry>> build() async {
    final rootPath = ref.watch(fileTreeRootPathProvider);
    if (rootPath == null) return const [];

    final expandedPaths = ref.watch(fileTreeExpansionProvider);

    // Watch the root for FS changes to trigger rebuilds.
    ref.listen(
      directoryWatcherProvider(rootPath),
      (_, next) {
        next.whenData((_) {
          // Invalidate root children on FS event.
          ref.invalidate(directoryChildrenProvider(rootPath));
        });
      },
    );

    return _buildFlatTree(rootPath, expandedPaths, 0);
  }

  Future<List<FlatTreeEntry>> _buildFlatTree(
    String dirPath,
    Set<String> expandedPaths,
    int depth,
  ) async {
    final children = await ref.watch(
      directoryChildrenProvider(dirPath).future,
    );

    final result = <FlatTreeEntry>[];

    for (final entry in children) {
      final isExpanded =
          entry.isDirectory && expandedPaths.contains(entry.path);

      result.add(FlatTreeEntry(
        entry: entry,
        depth: depth,
        isExpanded: isExpanded,
        isLoading: false,
      ));

      if (isExpanded) {
        // Watch this directory for FS changes too.
        ref.listen(
          directoryWatcherProvider(entry.path),
          (_, next) {
            next.whenData((_) {
              ref.invalidate(directoryChildrenProvider(entry.path));
              ref.invalidateSelf();
            });
          },
        );

        final childEntries = await _buildFlatTree(
          entry.path,
          expandedPaths,
          depth + 1,
        );
        result.addAll(childEntries);
      }
    }

    return result;
  }
}
