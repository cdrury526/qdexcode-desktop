/// Model for a single terminal tab: Terminal emulator + PTY process + wiring.
///
/// Each tab owns a [Terminal] (escape sequence parsing / screen buffer) and a
/// native [Pty] process connected to the user's shell. Stream subscriptions
/// wire PTY output to the terminal and terminal keystrokes back to the PTY.
///
/// Call [dispose] to tear everything down (kills the PTY, cancels streams).
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:dart_pty/dart_pty.dart';
import 'package:dart_xterm/dart_xterm.dart';

// ---------------------------------------------------------------------------
//  TerminalTabModel
// ---------------------------------------------------------------------------

/// Holds all state for a single terminal tab.
class TerminalTabModel {
  TerminalTabModel._({
    required this.id,
    required this.terminal,
    required this.pty,
    required StreamSubscription<String> outputSubscription,
    String title = 'Shell',
  })  : _outputSubscription = outputSubscription,
        _title = title;

  /// Unique identifier for this tab.
  final int id;

  /// The terminal emulator that parses escape sequences and holds the buffer.
  final Terminal terminal;

  /// The native PTY process connected to a shell.
  final Pty pty;

  /// Stream subscription forwarding PTY output to the terminal.
  final StreamSubscription<String> _outputSubscription;

  /// Current tab title (updated by the shell via OSC escape sequences).
  String _title;
  String get title => _title;

  /// Whether this tab has been disposed.
  bool _disposed = false;
  bool get isDisposed => _disposed;

  /// Callback invoked when the tab title changes.
  void Function(TerminalTabModel tab)? onTitleChange;

  // -------------------------------------------------------------------------
  //  Factory
  // -------------------------------------------------------------------------

  /// Global counter for generating unique tab IDs.
  static int _nextId = 1;

  /// Detect the user's default shell.
  static String get defaultShell {
    if (Platform.isWindows) return 'cmd.exe';
    return Platform.environment['SHELL'] ?? '/bin/zsh';
  }

  /// Create a new terminal tab with a running shell process.
  ///
  /// [shell] overrides the default shell executable. [workingDirectory] sets
  /// the initial cwd for the spawned process. [columns] and [rows] set the
  /// initial terminal dimensions (auto-updated by [TerminalView.autoResize]).
  static TerminalTabModel create({
    String? shell,
    String? workingDirectory,
    int columns = 80,
    int rows = 24,
  }) {
    final id = _nextId++;
    final resolvedShell = shell ?? defaultShell;

    final terminal = Terminal(maxLines: 10000);

    // Inherit current environment; ensure TERM is set for proper escape
    // sequence handling (zsh ZLE, colored output, etc.).
    final env = Map<String, String>.from(Platform.environment);
    env['TERM'] = 'xterm-256color';
    env['COLORTERM'] = 'truecolor';

    final pty = Pty.start(
      resolvedShell,
      columns: columns,
      rows: rows,
      workingDirectory: workingDirectory,
      environment: env,
      onLog: (level, component, msg) {
        debugPrint('[PTY:$level] $component: $msg');
      },
    );

    // PTY output (bytes from shell) -> Terminal (escape sequence parsing).
    const utf8Decoder = Utf8Decoder(allowMalformed: true);
    final outputSub = pty.output
        .map((data) => utf8Decoder.convert(data))
        .listen((text) {
      terminal.write(text);
    });

    final tab = TerminalTabModel._(
      id: id,
      terminal: terminal,
      pty: pty,
      outputSubscription: outputSub,
      title: resolvedShell.split('/').last,
    );

    // Terminal keystrokes -> PTY (user types -> shell stdin).
    terminal.onOutput = (data) {
      if (!tab._disposed) {
        pty.write(Uint8List.fromList(data.codeUnits));
      }
    };

    // Terminal resize -> PTY (SIGWINCH).
    terminal.onResize = (width, height, pixelWidth, pixelHeight) {
      if (!tab._disposed) {
        pty.resize(height, width);
      }
    };

    // Shell title changes -> tab title.
    terminal.onTitleChange = (title) {
      tab._title = title;
      tab.onTitleChange?.call(tab);
    };

    return tab;
  }

  // -------------------------------------------------------------------------
  //  Lifecycle
  // -------------------------------------------------------------------------

  /// Release all resources: kill the PTY, cancel subscriptions.
  ///
  /// Safe to call multiple times.
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _outputSubscription.cancel();
    terminal.onOutput = null;
    terminal.onResize = null;
    terminal.onTitleChange = null;
    pty.kill();
    pty.dispose();
  }
}
