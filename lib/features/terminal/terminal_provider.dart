/// Riverpod providers for terminal session management.
///
/// Manages the lifecycle of multiple terminal tabs (create, switch, close,
/// dispose-all) and exposes state for the UI layer. Integrates with the
/// selected project provider to set the initial working directory.
library;

import 'dart:io' show Platform;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:qdexcode_desktop/features/projects/project_provider.dart';
import 'package:qdexcode_desktop/features/terminal/terminal_tab_model.dart';

part 'terminal_provider.g.dart';

// ---------------------------------------------------------------------------
//  Terminal session state
// ---------------------------------------------------------------------------

/// Immutable snapshot of the terminal session manager's state.
class TerminalSessionState {
  const TerminalSessionState({
    required this.tabs,
    required this.activeIndex,
  });

  /// All open terminal tabs.
  final List<TerminalTabModel> tabs;

  /// Index of the currently active tab, or -1 if no tabs are open.
  final int activeIndex;

  /// The currently active tab, or null if no tabs are open.
  TerminalTabModel? get activeTab =>
      (activeIndex >= 0 && activeIndex < tabs.length)
          ? tabs[activeIndex]
          : null;

  TerminalSessionState copyWith({
    List<TerminalTabModel>? tabs,
    int? activeIndex,
  }) {
    return TerminalSessionState(
      tabs: tabs ?? this.tabs,
      activeIndex: activeIndex ?? this.activeIndex,
    );
  }
}

// ---------------------------------------------------------------------------
//  Terminal session notifier
// ---------------------------------------------------------------------------

/// Manages the lifecycle of terminal tabs.
///
/// Kept alive for the app lifetime so terminal sessions persist across
/// workspace tab switches.
@Riverpod(keepAlive: true)
class TerminalSessions extends _$TerminalSessions {
  @override
  TerminalSessionState build() {
    // Dispose all tabs when the provider is disposed (app shutdown).
    ref.onDispose(_disposeAllTabs);
    return const TerminalSessionState(tabs: [], activeIndex: -1);
  }

  /// Resolve the working directory for a new terminal tab.
  ///
  /// Uses the selected project's [localPath] if available, otherwise falls
  /// back to the user's home directory.
  String? _resolveWorkingDirectory() {
    final project =
        ref.read(selectedProjectProvider).valueOrNull;
    final localPath = project?.localPath;
    if (localPath != null && localPath.isNotEmpty) return localPath;

    // Fall back to home directory.
    return Platform.environment['HOME'] ??
        Platform.environment['USERPROFILE'];
  }

  /// Create a new terminal tab and make it active.
  ///
  /// Returns the created [TerminalTabModel].
  TerminalTabModel addTab({String? shell, String? workingDirectory}) {
    final cwd = workingDirectory ?? _resolveWorkingDirectory();

    final tab = TerminalTabModel.create(
      shell: shell,
      workingDirectory: cwd,
    );

    // Listen for title changes to trigger state updates.
    tab.onTitleChange = (_) => _notifyChanged();

    final newTabs = [...state.tabs, tab];
    state = TerminalSessionState(
      tabs: newTabs,
      activeIndex: newTabs.length - 1,
    );

    return tab;
  }

  /// Close a tab at [index], disposing its PTY.
  ///
  /// If the last tab is closed, no new tab is auto-created (the UI shows
  /// the empty state with a "New Terminal" button).
  void closeTab(int index) {
    if (index < 0 || index >= state.tabs.length) return;

    final tab = state.tabs[index];
    final newTabs = [...state.tabs]..removeAt(index);
    tab.dispose();

    int newActive = state.activeIndex;
    if (newTabs.isEmpty) {
      newActive = -1;
    } else if (newActive >= newTabs.length) {
      newActive = newTabs.length - 1;
    } else if (newActive > index) {
      newActive--;
    }

    state = TerminalSessionState(tabs: newTabs, activeIndex: newActive);
  }

  /// Switch to the tab at [index].
  void selectTab(int index) {
    if (index < 0 || index >= state.tabs.length) return;
    if (index == state.activeIndex) return;
    state = state.copyWith(activeIndex: index);
  }

  /// Switch to tab number [n] (1-indexed, matching Cmd+1-9).
  void selectTabByNumber(int n) {
    selectTab(n - 1);
  }

  /// Trigger a state rebuild (e.g. after title change).
  void _notifyChanged() {
    state = state.copyWith();
  }

  /// Dispose all open tabs. Called on provider disposal.
  void _disposeAllTabs() {
    for (final tab in state.tabs) {
      tab.dispose();
    }
  }

  /// Dispose all tabs and reset state. Used for explicit cleanup.
  void disposeAll() {
    _disposeAllTabs();
    state = const TerminalSessionState(tabs: [], activeIndex: -1);
  }
}

// ---------------------------------------------------------------------------
//  Convenience provider: whether to show "set local path" hint
// ---------------------------------------------------------------------------

/// True when the selected project has no [localPath] set.
///
/// The terminal page can show a non-intrusive hint suggesting the user
/// configure a local path so terminals open in the project directory.
@riverpod
bool terminalShowLocalPathHint(Ref ref) {
  final project = ref.watch(selectedProjectProvider).valueOrNull;
  if (project == null) return false;
  return project.localPath == null || project.localPath!.isEmpty;
}
