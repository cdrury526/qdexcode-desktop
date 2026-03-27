import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:qdexcode_desktop/core/auth/auth_provider.dart';
import 'package:qdexcode_desktop/core/realtime/connection_badge.dart';
import 'package:qdexcode_desktop/core/theme/theme_provider.dart';
import 'package:qdexcode_desktop/features/plans/plan_tree.dart';

/// Left sidebar panel containing:
/// - Project selector slot (top)
/// - Plan navigation slot (middle, scrollable)
/// - Footer with connection badge, theme toggle, and logout
///
/// Slots accept child widgets so features can plug in later.
class LeftPanel extends ConsumerWidget {
  const LeftPanel({
    super.key,
    this.projectSelector,
    this.planNavigation,
  });

  /// Widget for the project selector area at the top.
  final Widget? projectSelector;

  /// Widget for the plan navigation area in the middle.
  final Widget? planNavigation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      color: cs.surface,
      child: Column(
        children: [
          // Project selector slot
          projectSelector ?? const _ProjectSelectorPlaceholder(),

          // Divider
          Divider(height: 1, thickness: 1, color: cs.outline),

          // Plan navigation slot (takes remaining space)
          Expanded(
            child: planNavigation ?? const PlanTree(),
          ),

          // Footer divider
          Divider(height: 1, thickness: 1, color: cs.outline),

          // Footer: connection badge, theme toggle, logout
          const _LeftPanelFooter(),
        ],
      ),
    );
  }
}

/// Placeholder for the project selector before it is implemented.
class _ProjectSelectorPlaceholder extends StatelessWidget {
  const _ProjectSelectorPlaceholder();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Container(
        height: 32,
        decoration: BoxDecoration(
          color: cs.surfaceContainer,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: cs.outline),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            Icon(Icons.folder_outlined, size: 14, color: cs.onTertiary),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Switch project...',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onTertiary,
                  fontSize: 12,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.unfold_more, size: 14, color: cs.onTertiary),
          ],
        ),
      ),
    );
  }
}

/// Footer with connection badge, theme toggle, and logout.
class _LeftPanelFooter extends ConsumerWidget {
  const _LeftPanelFooter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themePreferenceProvider);

    // Pick icon and tooltip based on current theme mode.
    final (IconData icon, String tooltip) = switch (themeMode) {
      ThemeMode.system => (Icons.brightness_auto_outlined, 'Theme: System'),
      ThemeMode.light => (Icons.light_mode_outlined, 'Theme: Light'),
      ThemeMode.dark => (Icons.dark_mode_outlined, 'Theme: Dark'),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        children: [
          // Connection status badge (wired to pg-bridge WebSocket)
          const ConnectionBadge(),

          const Spacer(),

          // Theme toggle: cycles System -> Light -> Dark -> System
          _FooterIconButton(
            icon: icon,
            tooltip: tooltip,
            onTap: () =>
                ref.read(themePreferenceProvider.notifier).cycle(),
          ),

          const SizedBox(width: 2),

          // Logout
          _FooterIconButton(
            icon: Icons.logout,
            tooltip: 'Sign out',
            onTap: () => ref.read(authProvider.notifier).logout(),
          ),
        ],
      ),
    );
  }
}

/// Compact icon button for the footer.
class _FooterIconButton extends StatefulWidget {
  const _FooterIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  State<_FooterIconButton> createState() => _FooterIconButtonState();
}

class _FooterIconButtonState extends State<_FooterIconButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: _hovered ? cs.secondary : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              widget.icon,
              size: 16,
              color: _hovered ? cs.onSecondary : cs.onTertiary,
            ),
          ),
        ),
      ),
    );
  }
}
