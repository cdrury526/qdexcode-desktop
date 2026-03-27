import 'package:flutter/material.dart';

/// Data describing a single entry in a [ContextMenu].
///
/// Use the default constructor for a tappable item, or
/// [ContextMenuItem.divider] for a horizontal separator.
class ContextMenuItem {
  /// Creates a tappable context menu entry.
  const ContextMenuItem({
    required this.label,
    required this.onTap,
    this.icon,
    this.shortcut,
    this.destructive = false,
    this.enabled = true,
  }) : isDivider = false;

  /// Creates a non-interactive horizontal divider.
  const ContextMenuItem.divider()
      : label = '',
        onTap = null,
        icon = null,
        shortcut = null,
        destructive = false,
        enabled = true,
        isDivider = true;

  /// Primary text displayed in the menu row.
  final String label;

  /// Called when the item is tapped. Null for dividers.
  final VoidCallback? onTap;

  /// Optional leading icon.
  final IconData? icon;

  /// Optional trailing keyboard-shortcut hint (e.g. "Ctrl+C").
  final String? shortcut;

  /// When true, the item uses the error/danger color.
  final bool destructive;

  /// Whether the item is interactive. Disabled items are rendered muted.
  final bool enabled;

  /// Whether this entry is a horizontal divider rather than a tappable item.
  final bool isDivider;
}

/// Renders a single [ContextMenuItem] inside a [ContextMenu].
///
/// This is an internal presentation widget -- consumers should interact with
/// the menu via [ContextMenuRegion] and [ContextMenuItem] data objects.
class ContextMenuItemWidget extends StatefulWidget {
  const ContextMenuItemWidget({
    super.key,
    required this.item,
    required this.onDismiss,
  });

  final ContextMenuItem item;

  /// Called after the item's [ContextMenuItem.onTap] fires so the parent
  /// overlay can close the menu.
  final VoidCallback onDismiss;

  @override
  State<ContextMenuItemWidget> createState() => _ContextMenuItemWidgetState();
}

class _ContextMenuItemWidgetState extends State<ContextMenuItemWidget> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    // -- Divider --
    if (item.isDivider) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Divider(
          height: 1,
          thickness: 1,
          color: Theme.of(context).colorScheme.outline,
        ),
      );
    }

    final cs = Theme.of(context).colorScheme;
    final isEnabled = item.enabled && item.onTap != null;

    // Foreground color based on state.
    final Color fgColor;
    if (!isEnabled) {
      fgColor = cs.onTertiary.withAlpha(100);
    } else if (item.destructive) {
      fgColor = cs.error;
    } else {
      fgColor = cs.onSurface;
    }

    final hoverBg =
        _hovered && isEnabled ? cs.secondary : Colors.transparent;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor:
          isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: isEnabled
            ? () {
                item.onTap!();
                widget.onDismiss();
              }
            : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          height: 30,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: hoverBg,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              // Leading icon
              if (item.icon != null) ...[
                Icon(item.icon, size: 15, color: fgColor),
                const SizedBox(width: 8),
              ],

              // Label
              Expanded(
                child: Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 13,
                    color: fgColor,
                    fontWeight: FontWeight.w400,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),

              // Shortcut hint
              if (item.shortcut != null) ...[
                const SizedBox(width: 24),
                Text(
                  item.shortcut!,
                  style: TextStyle(
                    fontSize: 11,
                    color: cs.onTertiary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
