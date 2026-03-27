/// Terminal page widget: tab bar + TerminalView per tab.
///
/// Provides a multi-tab terminal experience with:
/// - Horizontal tab bar with create (+) and close (x) buttons
/// - TerminalView rendering with autoResize for each tab
/// - Keyboard shortcuts (Cmd+T new, Cmd+W close, Cmd+1-9 switch)
/// - Right-click context menu (copy, paste, clear)
/// - Empty state with "New Terminal" button when no tabs are open
/// - Local-path hint when the selected project has no local_path set
library;

import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dart_xterm/dart_xterm.dart';

import 'package:qdexcode_desktop/features/terminal/terminal_provider.dart';
import 'package:qdexcode_desktop/features/terminal/terminal_settings.dart';
import 'package:qdexcode_desktop/features/terminal/terminal_tab_model.dart';

// ---------------------------------------------------------------------------
//  TerminalPage — top-level widget for the Terminal workspace tab
// ---------------------------------------------------------------------------

/// The terminal workspace tab content.
///
/// Manages its own tab bar for terminal sessions and renders the active
/// terminal via [TerminalView].
class TerminalPage extends ConsumerStatefulWidget {
  const TerminalPage({super.key});

  @override
  ConsumerState<TerminalPage> createState() => _TerminalPageState();
}

class _TerminalPageState extends ConsumerState<TerminalPage> {
  static final bool _isMacOS = Platform.isMacOS;

  @override
  void initState() {
    super.initState();
    // Auto-create the first tab if none exist.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sessions = ref.read(terminalSessionsProvider);
      if (sessions.tabs.isEmpty) {
        ref.read(terminalSessionsProvider.notifier).addTab();
      }
    });
  }

  // -------------------------------------------------------------------------
  //  Keyboard shortcuts
  // -------------------------------------------------------------------------

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    final isModifier = _isMacOS
        ? HardwareKeyboard.instance.isMetaPressed
        : HardwareKeyboard.instance.isControlPressed;

    if (!isModifier) return KeyEventResult.ignored;

    final notifier = ref.read(terminalSessionsProvider.notifier);

    // Cmd+T / Ctrl+T -- new tab.
    if (event.logicalKey == LogicalKeyboardKey.keyT) {
      notifier.addTab();
      return KeyEventResult.handled;
    }

    // Cmd+W / Ctrl+W -- close current tab.
    if (event.logicalKey == LogicalKeyboardKey.keyW) {
      final active = ref.read(terminalSessionsProvider).activeIndex;
      if (active >= 0) notifier.closeTab(active);
      return KeyEventResult.handled;
    }

    // Cmd+1-9 / Ctrl+1-9 -- switch to tab N.
    final digit = _digitFromKey(event.logicalKey);
    if (digit != null && digit >= 1 && digit <= 9) {
      notifier.selectTabByNumber(digit);
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  static int? _digitFromKey(LogicalKeyboardKey key) {
    return switch (key) {
      LogicalKeyboardKey.digit1 => 1,
      LogicalKeyboardKey.digit2 => 2,
      LogicalKeyboardKey.digit3 => 3,
      LogicalKeyboardKey.digit4 => 4,
      LogicalKeyboardKey.digit5 => 5,
      LogicalKeyboardKey.digit6 => 6,
      LogicalKeyboardKey.digit7 => 7,
      LogicalKeyboardKey.digit8 => 8,
      LogicalKeyboardKey.digit9 => 9,
      _ => null,
    };
  }

  // -------------------------------------------------------------------------
  //  Build
  // -------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final sessions = ref.watch(terminalSessionsProvider);
    final showHint = ref.watch(terminalShowLocalPathHintProvider);

    return Focus(
      onKeyEvent: _handleKeyEvent,
      child: Column(
        children: [
          // Terminal tab bar.
          _TerminalTabBar(
            tabs: sessions.tabs,
            activeIndex: sessions.activeIndex,
            onSelect: (i) =>
                ref.read(terminalSessionsProvider.notifier).selectTab(i),
            onClose: (i) =>
                ref.read(terminalSessionsProvider.notifier).closeTab(i),
            onNewTab: () =>
                ref.read(terminalSessionsProvider.notifier).addTab(),
          ),

          // Local-path hint banner.
          if (showHint) const _LocalPathHint(),

          // Terminal content area.
          Expanded(
            child: sessions.tabs.isEmpty
                ? _EmptyState(
                    onNewTerminal: () =>
                        ref.read(terminalSessionsProvider.notifier).addTab(),
                  )
                : IndexedStack(
                    index: sessions.activeIndex,
                    children: [
                      for (var i = 0; i < sessions.tabs.length; i++)
                        _TerminalTabContent(
                          key: ValueKey(sessions.tabs[i].id),
                          tab: sessions.tabs[i],
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//  Terminal tab bar
// ---------------------------------------------------------------------------

class _TerminalTabBar extends StatelessWidget {
  const _TerminalTabBar({
    required this.tabs,
    required this.activeIndex,
    required this.onSelect,
    required this.onClose,
    required this.onNewTab,
  });

  final List<TerminalTabModel> tabs;
  final int activeIndex;
  final ValueChanged<int> onSelect;
  final ValueChanged<int> onClose;
  final VoidCallback onNewTab;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      height: 30,
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        border: Border(
          bottom: BorderSide(color: cs.outline.withValues(alpha: 0.3)),
        ),
      ),
      child: Row(
        children: [
          // Scrollable tab list.
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: tabs.length,
              itemBuilder: (context, index) {
                final tab = tabs[index];
                final isActive = index == activeIndex;
                return _TerminalTabChip(
                  label: tab.title,
                  isActive: isActive,
                  onTap: () => onSelect(index),
                  onClose: () => onClose(index),
                );
              },
            ),
          ),

          // New tab button.
          _IconAction(
            icon: Icons.add,
            tooltip: 'New Terminal',
            onTap: onNewTab,
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//  Tab chip
// ---------------------------------------------------------------------------

class _TerminalTabChip extends StatefulWidget {
  const _TerminalTabChip({
    required this.label,
    required this.isActive,
    required this.onTap,
    required this.onClose,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onClose;

  @override
  State<_TerminalTabChip> createState() => _TerminalTabChipState();
}

class _TerminalTabChipState extends State<_TerminalTabChip> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final foreground = widget.isActive ? cs.onSurface : cs.onSurfaceVariant;
    final background = widget.isActive
        ? cs.surfaceContainer
        : (_hovered ? cs.surfaceContainerHigh : Colors.transparent);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: background,
            border: Border(
              bottom: BorderSide(
                color: widget.isActive ? cs.primary : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.terminal, size: 13, color: foreground),
              const SizedBox(width: 6),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 120),
                child: Text(
                  widget.label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: foreground,
                    fontWeight:
                        widget.isActive ? FontWeight.w600 : FontWeight.w400,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              const SizedBox(width: 4),
              // Close button (visible on hover or when active).
              if (_hovered || widget.isActive)
                _IconAction(
                  icon: Icons.close,
                  size: 14,
                  onTap: widget.onClose,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//  Small icon button helper
// ---------------------------------------------------------------------------

class _IconAction extends StatefulWidget {
  const _IconAction({
    required this.icon,
    required this.onTap,
    this.tooltip,
    this.size = 16,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;
  final double size;

  @override
  State<_IconAction> createState() => _IconActionState();
}

class _IconActionState extends State<_IconAction> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final child = MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: Icon(
            widget.icon,
            size: widget.size,
            color: _hovered ? cs.onSurface : cs.onSurfaceVariant,
          ),
        ),
      ),
    );

    if (widget.tooltip != null) {
      return Tooltip(message: widget.tooltip!, child: child);
    }
    return child;
  }
}

// ---------------------------------------------------------------------------
//  Terminal tab content — renders a single TerminalView
// ---------------------------------------------------------------------------

class _TerminalTabContent extends StatefulWidget {
  const _TerminalTabContent({
    super.key,
    required this.tab,
  });

  final TerminalTabModel tab;

  @override
  State<_TerminalTabContent> createState() => _TerminalTabContentState();
}

class _TerminalTabContentState extends State<_TerminalTabContent>
    with AutomaticKeepAliveClientMixin {
  late final TerminalController _controller;
  late final FocusNode _focusNode;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _controller = TerminalController();
    _focusNode = FocusNode(debugLabel: 'terminal-${widget.tab.id}');
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _requestFocus() {
    if (_focusNode.canRequestFocus) {
      _focusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final brightness = Theme.of(context).brightness;

    // Request focus after the frame so the terminal receives keyboard input.
    WidgetsBinding.instance.addPostFrameCallback((_) => _requestFocus());

    return TerminalView(
      widget.tab.terminal,
      controller: _controller,
      theme: terminalThemeFor(brightness),
      textStyle: kTerminalTextStyle,
      autoResize: true,
      focusNode: _focusNode,
      autofocus: true,
      hardwareKeyboardOnly: true,
      onSecondaryTapDown: (details, offset) {
        _showContextMenu(context, details.globalPosition);
      },
    );
  }

  // -------------------------------------------------------------------------
  //  Context menu
  // -------------------------------------------------------------------------

  void _showContextMenu(BuildContext context, Offset position) {
    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx,
        position.dy,
      ),
      items: const [
        PopupMenuItem(value: 'copy', child: Text('Copy')),
        PopupMenuItem(value: 'paste', child: Text('Paste')),
        PopupMenuDivider(),
        PopupMenuItem(value: 'clear', child: Text('Clear')),
      ],
    ).then((value) {
      if (value == null) return;
      switch (value) {
        case 'copy':
          _handleCopy();
        case 'paste':
          _handlePaste();
        case 'clear':
          _handleClear();
      }
    });
  }

  void _handleCopy() {
    final selection = _controller.selection;
    if (selection != null) {
      final text = widget.tab.terminal.buffer.getText(selection);
      Clipboard.setData(ClipboardData(text: text));
    }
  }

  void _handlePaste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) {
      widget.tab.terminal.paste(data!.text!);
    }
  }

  void _handleClear() {
    widget.tab.terminal.textInput('clear\n');
  }
}

// ---------------------------------------------------------------------------
//  Empty state
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onNewTerminal});

  final VoidCallback onNewTerminal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.terminal_outlined, size: 48, color: cs.onSurfaceVariant),
          const SizedBox(height: 12),
          Text(
            'No terminal sessions',
            style: theme.textTheme.titleMedium?.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: onNewTerminal,
            icon: const Icon(Icons.add, size: 16),
            label: const Text('New Terminal'),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//  Local path hint banner
// ---------------------------------------------------------------------------

class _LocalPathHint extends StatelessWidget {
  const _LocalPathHint();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      color: cs.tertiaryContainer.withValues(alpha: 0.4),
      child: Text(
        'Tip: Set a local path in your project to open terminals there '
        'automatically.',
        style: theme.textTheme.labelSmall?.copyWith(
          color: cs.onTertiaryContainer,
        ),
      ),
    );
  }
}
