/// Wrapper around git CLI calls using dart:io Process.run.
///
/// All operations execute `git` as a subprocess with the project's local path
/// as the working directory. Returns parsed, typed results.
library;

import 'dart:io';

// ---------------------------------------------------------------------------
// Data models
// ---------------------------------------------------------------------------

/// The parsed result of `git status --porcelain=v2 --branch`.
class GitStatusResult {
  const GitStatusResult({
    required this.branch,
    required this.upstream,
    required this.ahead,
    required this.behind,
    required this.changedFiles,
  });

  /// Current branch name (e.g. "main").
  final String branch;

  /// Upstream tracking branch (e.g. "origin/main"), or empty if none.
  final String upstream;

  /// Commits ahead of upstream.
  final int ahead;

  /// Commits behind upstream.
  final int behind;

  /// List of changed files with their status.
  final List<GitChangedFile> changedFiles;

  /// Total number of changed files.
  int get changeCount => changedFiles.length;
}

/// A single changed file from git status.
class GitChangedFile {
  const GitChangedFile({
    required this.path,
    required this.status,
    this.additions = 0,
    this.deletions = 0,
  });

  /// Relative file path.
  final String path;

  /// Change status: modified, added, deleted, renamed, untracked.
  final GitFileStatus status;

  /// Lines added (populated from git diff --numstat).
  final int additions;

  /// Lines deleted (populated from git diff --numstat).
  final int deletions;

  /// Create a copy with updated additions/deletions.
  GitChangedFile withStats({int additions = 0, int deletions = 0}) {
    return GitChangedFile(
      path: path,
      status: status,
      additions: additions,
      deletions: deletions,
    );
  }
}

/// The status category for a changed file.
enum GitFileStatus {
  modified,
  added,
  deleted,
  renamed,
  copied,
  untracked,
  unknown;

  /// Single-character label for compact display.
  String get label => switch (this) {
        modified => 'M',
        added => 'A',
        deleted => 'D',
        renamed => 'R',
        copied => 'C',
        untracked => '?',
        unknown => '!',
      };
}

/// A single commit from git log.
class GitCommit {
  const GitCommit({
    required this.hash,
    required this.subject,
    required this.author,
    required this.relativeTime,
  });

  /// Full SHA hash.
  final String hash;

  /// Commit subject line.
  final String subject;

  /// Author name.
  final String author;

  /// Relative time string from git (e.g. "2 hours ago").
  final String relativeTime;

  /// Short hash (first 7 characters).
  String get shortHash => hash.length >= 7 ? hash.substring(0, 7) : hash;
}

/// Result of checking if a path is a git repository.
enum GitRepoCheck {
  /// Valid git repository.
  valid,

  /// Path exists but is not a git repository.
  notARepo,

  /// Path does not exist.
  pathNotFound,
}

// ---------------------------------------------------------------------------
// Git service
// ---------------------------------------------------------------------------

/// Executes git CLI commands against a local repository.
///
/// All methods are static and take [workingDirectory] as a parameter.
/// Throws no exceptions on git failures — returns empty/default values.
abstract final class GitService {
  /// Check if the given path is a valid git repository.
  static Future<GitRepoCheck> checkRepository(String path) async {
    final dir = Directory(path);
    if (!await dir.exists()) return GitRepoCheck.pathNotFound;

    final result = await Process.run(
      'git',
      ['rev-parse', '--git-dir'],
      workingDirectory: path,
    );
    return result.exitCode == 0 ? GitRepoCheck.valid : GitRepoCheck.notARepo;
  }

  /// Get branch info and changed files via `git status --porcelain=v2 --branch`.
  static Future<GitStatusResult> getStatus(String workingDirectory) async {
    final result = await Process.run(
      'git',
      ['status', '--porcelain=v2', '--branch'],
      workingDirectory: workingDirectory,
    );

    if (result.exitCode != 0) {
      return const GitStatusResult(
        branch: '',
        upstream: '',
        ahead: 0,
        behind: 0,
        changedFiles: [],
      );
    }

    return _parseStatusV2(result.stdout as String);
  }

  /// Get line-level change stats via `git diff --numstat`.
  ///
  /// Returns a map of file path to (additions, deletions).
  static Future<Map<String, (int, int)>> getDiffStats(
    String workingDirectory,
  ) async {
    // Staged + unstaged combined.
    final stagedResult = await Process.run(
      'git',
      ['diff', '--numstat', '--cached'],
      workingDirectory: workingDirectory,
    );
    final unstagedResult = await Process.run(
      'git',
      ['diff', '--numstat'],
      workingDirectory: workingDirectory,
    );

    final stats = <String, (int, int)>{};

    void parseNumstat(String output) {
      for (final line in output.split('\n')) {
        if (line.trim().isEmpty) continue;
        final parts = line.split('\t');
        if (parts.length < 3) continue;

        final adds = int.tryParse(parts[0]) ?? 0;
        final dels = int.tryParse(parts[1]) ?? 0;
        final path = parts[2];

        final existing = stats[path];
        if (existing != null) {
          stats[path] = (existing.$1 + adds, existing.$2 + dels);
        } else {
          stats[path] = (adds, dels);
        }
      }
    }

    if (stagedResult.exitCode == 0) {
      parseNumstat(stagedResult.stdout as String);
    }
    if (unstagedResult.exitCode == 0) {
      parseNumstat(unstagedResult.stdout as String);
    }

    return stats;
  }

  /// Get recent commits via `git log`.
  static Future<List<GitCommit>> getLog(
    String workingDirectory, {
    int count = 10,
  }) async {
    // Use unit separator (0x1F) as field delimiter.
    final result = await Process.run(
      'git',
      [
        'log',
        '--format=%H\x1f%s\x1f%an\x1f%ar',
        '-n',
        '$count',
      ],
      workingDirectory: workingDirectory,
    );

    if (result.exitCode != 0) return [];

    final output = (result.stdout as String).trim();
    if (output.isEmpty) return [];

    return output.split('\n').map((line) {
      final parts = line.split('\x1f');
      if (parts.length < 4) return null;
      return GitCommit(
        hash: parts[0],
        subject: parts[1],
        author: parts[2],
        relativeTime: parts[3],
      );
    }).whereType<GitCommit>().toList();
  }

  // ---------------------------------------------------------------------------
  // Parsing
  // ---------------------------------------------------------------------------

  /// Parse `git status --porcelain=v2 --branch` output.
  static GitStatusResult _parseStatusV2(String output) {
    var branch = '';
    var upstream = '';
    var ahead = 0;
    var behind = 0;
    final files = <GitChangedFile>[];

    for (final line in output.split('\n')) {
      if (line.isEmpty) continue;

      // Header lines start with #.
      if (line.startsWith('# branch.head ')) {
        branch = line.substring('# branch.head '.length);
      } else if (line.startsWith('# branch.upstream ')) {
        upstream = line.substring('# branch.upstream '.length);
      } else if (line.startsWith('# branch.ab ')) {
        final ab = line.substring('# branch.ab '.length);
        final parts = ab.split(' ');
        if (parts.length >= 2) {
          ahead = int.tryParse(parts[0].replaceFirst('+', '')) ?? 0;
          behind = int.tryParse(parts[1].replaceFirst('-', '')) ?? 0;
        }
      }
      // Changed entries: "1 XY ..." or "2 XY ..." (renamed).
      else if (line.startsWith('1 ') || line.startsWith('2 ')) {
        final parsed = _parseChangedEntry(line);
        if (parsed != null) files.add(parsed);
      }
      // Untracked: "? path"
      else if (line.startsWith('? ')) {
        final path = line.substring(2);
        files.add(GitChangedFile(
          path: path,
          status: GitFileStatus.untracked,
        ));
      }
    }

    return GitStatusResult(
      branch: branch,
      upstream: upstream,
      ahead: ahead,
      behind: behind,
      changedFiles: files,
    );
  }

  /// Parse a single changed entry line from porcelain v2.
  static GitChangedFile? _parseChangedEntry(String line) {
    // Format: "1 XY sub mH mI mW hH hI path"
    // or:     "2 XY sub mH mI mW hH hI Xscore path\torigPath"
    final parts = line.split(' ');
    if (parts.length < 9) return null;

    final xy = parts[1];
    final indexStatus = xy[0];
    final workTreeStatus = xy[1];

    // Determine the most relevant status.
    final status = _mapStatusChar(
      workTreeStatus != '.' ? workTreeStatus : indexStatus,
    );

    // For renamed entries (type 2), path may contain a tab.
    String path;
    if (parts[0] == '2') {
      // Rejoin everything after the 8th space.
      final rest = parts.sublist(8).join(' ');
      final tabIdx = rest.indexOf('\t');
      path = tabIdx >= 0 ? rest.substring(0, tabIdx) : rest;
    } else {
      path = parts.sublist(8).join(' ');
    }

    return GitChangedFile(path: path, status: status);
  }

  /// Map a single status character to [GitFileStatus].
  static GitFileStatus _mapStatusChar(String char) => switch (char) {
        'M' => GitFileStatus.modified,
        'A' => GitFileStatus.added,
        'D' => GitFileStatus.deleted,
        'R' => GitFileStatus.renamed,
        'C' => GitFileStatus.copied,
        '?' => GitFileStatus.untracked,
        _ => GitFileStatus.unknown,
      };
}
