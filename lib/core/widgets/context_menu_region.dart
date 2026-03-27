import 'package:flutter/material.dart';

import 'package:qdexcode_desktop/core/widgets/context_menu.dart';
import 'package:qdexcode_desktop/core/widgets/context_menu_item.dart';

/// A wrapper widget that shows a styled [ContextMenu] on secondary tap
/// (right-click) at the pointer position.
///
/// ```dart
/// ContextMenuRegion(
///   items: [
///     ContextMenuItem(icon: Icons.copy, label: 'Copy', onTap: () {}),
///     ContextMenuItem(icon: Icons.edit, label: 'Rename', shortcut: 'F2', onTap: () {}),
///     ContextMenuItem.divider(),
///     ContextMenuItem(icon: Icons.delete, label: 'Delete', destructive: true, onTap: () {}),
///   ],
///   child: YourWidget(),
/// )
/// ```
///
/// The menu:
///  - Fades in over 150 ms.
///  - Flips when near screen edges.
///  - Dismisses on Escape, click-outside, or item selection.
class ContextMenuRegion extends StatefulWidget {
  const ContextMenuRegion({
    super.key,
    required this.items,
    required this.child,
    this.enabled = true,
    this.onBeforeShow,
  });

  /// Menu entries to display on right-click.
  final List<ContextMenuItem> items;

  /// The child widget wrapped by this region.
  final Widget child;

  /// When false, secondary taps are not intercepted.
  final bool enabled;

  /// Optional callback fired just before the menu appears.
  /// Return `false` to prevent the menu from showing.
  /// Useful for dynamically enabling/disabling the menu or rebuilding
  /// the items list based on what was clicked.
  final bool Function()? onBeforeShow;

  @override
  State<ContextMenuRegion> createState() => _ContextMenuRegionState();
}

class _ContextMenuRegionState extends State<ContextMenuRegion> {
  OverlayEntry? _overlayEntry;

  void _show(Offset globalPosition) {
    // Allow the consumer to cancel the show.
    if (widget.onBeforeShow != null && !widget.onBeforeShow!()) {
      return;
    }

    _dismiss();

    final overlay = Overlay.of(context);
    _overlayEntry = OverlayEntry(
      builder: (_) => ContextMenu(
        items: widget.items,
        position: globalPosition,
        onDismiss: _dismiss,
      ),
    );
    overlay.insert(_overlayEntry!);
  }

  void _dismiss() {
    _overlayEntry?.remove();
    _overlayEntry?.dispose();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _dismiss();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onSecondaryTapUp: (details) => _show(details.globalPosition),
      child: widget.child,
    );
  }
}
