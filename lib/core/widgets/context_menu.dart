import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:qdexcode_desktop/core/widgets/context_menu_item.dart';

/// A styled overlay context menu positioned at an arbitrary screen offset.
///
/// Typically you should not instantiate this directly. Use [ContextMenuRegion]
/// which manages showing / hiding the menu in response to secondary taps.
///
/// The menu:
///  - Fades in over 150 ms.
///  - Flips horizontally/vertically when it would overflow the screen.
///  - Dismisses on Escape, click-outside, or item selection.
class ContextMenu extends StatefulWidget {
  const ContextMenu({
    super.key,
    required this.items,
    required this.position,
    required this.onDismiss,
  });

  /// The entries to display (items + dividers).
  final List<ContextMenuItem> items;

  /// The global position where the menu should appear (typically the
  /// secondary-tap location).
  final Offset position;

  /// Called when the menu should close for any reason.
  final VoidCallback onDismiss;

  @override
  State<ContextMenu> createState() => _ContextMenuState();
}

class _ContextMenuState extends State<ContextMenu>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  // Key used to measure the menu after layout so we can clamp / flip it.
  final _menuKey = GlobalKey();

  // The resolved position (may differ from widget.position after flipping).
  Offset? _resolvedPosition;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();

    // After the first frame we know the menu size and can resolve the
    // position so it stays on-screen.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _resolvePosition();
    });
  }

  void _resolvePosition() {
    final renderBox =
        _menuKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null || !mounted) return;

    final menuSize = renderBox.size;
    final screen = MediaQuery.of(context).size;
    const edgePadding = 8.0;

    double dx = widget.position.dx;
    double dy = widget.position.dy;

    // Flip horizontally if overflowing right edge.
    if (dx + menuSize.width > screen.width - edgePadding) {
      dx = dx - menuSize.width;
    }

    // Flip vertically if overflowing bottom edge.
    if (dy + menuSize.height > screen.height - edgePadding) {
      dy = dy - menuSize.height;
    }

    // Clamp so the menu never leaves the screen.
    dx = dx.clamp(edgePadding, screen.width - menuSize.width - edgePadding);
    dy = dy.clamp(
      edgePadding,
      screen.height - menuSize.height - edgePadding,
    );

    if (dx != _resolvedPosition?.dx || dy != _resolvedPosition?.dy) {
      setState(() => _resolvedPosition = Offset(dx, dy));
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final pos = _resolvedPosition ?? widget.position;

    return Stack(
      children: [
        // Barrier: transparent layer that dismisses the menu on tap.
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onDismiss,
            onSecondaryTap: widget.onDismiss,
          ),
        ),

        // The menu itself.
        Positioned(
          left: pos.dx,
          top: pos.dy,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: KeyboardListener(
              focusNode: FocusNode()..requestFocus(),
              autofocus: true,
              onKeyEvent: (event) {
                if (event is KeyDownEvent &&
                    event.logicalKey == LogicalKeyboardKey.escape) {
                  widget.onDismiss();
                }
              },
              child: Container(
                key: _menuKey,
                constraints: const BoxConstraints(
                  minWidth: 160,
                  maxWidth: 260,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: cs.surfaceContainer,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: cs.outline),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(40),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IntrinsicWidth(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final item in widget.items)
                        ContextMenuItemWidget(
                          item: item,
                          onDismiss: widget.onDismiss,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
