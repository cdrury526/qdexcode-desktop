import 'package:flutter/material.dart';

import 'package:qdexcode_desktop/features/file_tree/file_tree_panel.dart';
import 'package:qdexcode_desktop/features/git/git_panel.dart';

/// Right panel with a vertical stack of collapsible sections:
/// file tree, git status, and search.
///
/// Each section has a clickable header that expands/collapses the content.
/// All three sections are visible simultaneously by default, similar to
/// VS Code's Explorer sidebar.
class RightPanel extends StatefulWidget {
  const RightPanel({super.key});

  @override
  State<RightPanel> createState() => _RightPanelState();
}

class _RightPanelState extends State<RightPanel> {
  // Track which sections are expanded. All start expanded.
  final Map<String, bool> _expanded = {
    'files': true,
    'git': true,
    'search': true,
  };

  void _toggle(String key) {
    setState(() => _expanded[key] = !(_expanded[key] ?? true));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      color: cs.surface,
      child: Column(
        children: [
          // File tree section — takes remaining space
          _SectionHeader(
            title: 'Files',
            icon: Icons.folder_outlined,
            expanded: _expanded['files']!,
            onTap: () => _toggle('files'),
          ),
          if (_expanded['files']!)
            const Expanded(
              child: FileTreePanel(),
            ),

          // Git status section
          _SectionHeader(
            title: 'Git',
            icon: Icons.commit_outlined,
            expanded: _expanded['git']!,
            onTap: () => _toggle('git'),
          ),
          if (_expanded['git']!)
            const Expanded(
              child: GitPanel(),
            ),

          // Search section
          _SectionHeader(
            title: 'Search',
            icon: Icons.search_outlined,
            expanded: _expanded['search']!,
            onTap: () => _toggle('search'),
          ),
          if (_expanded['search']!)
            const SizedBox(
              height: 120,
              child: _SectionPlaceholder(
                icon: Icons.search_outlined,
                label: 'Search coming soon',
              ),
            ),
        ],
      ),
    );
  }
}

/// Collapsible section header with expand/collapse arrow.
class _SectionHeader extends StatefulWidget {
  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.expanded,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final bool expanded;
  final VoidCallback onTap;

  @override
  State<_SectionHeader> createState() => _SectionHeaderState();
}

class _SectionHeaderState extends State<_SectionHeader> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 28,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: _hovered ? cs.secondary : cs.surfaceContainer,
            border: Border(
              bottom: BorderSide(color: cs.outline, width: 0.5),
            ),
          ),
          child: Row(
            children: [
              AnimatedRotation(
                turns: widget.expanded ? 0.25 : 0,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  Icons.chevron_right,
                  size: 14,
                  color: cs.onTertiary,
                ),
              ),
              const SizedBox(width: 4),
              Icon(widget.icon, size: 14, color: cs.onTertiary),
              const SizedBox(width: 6),
              Text(
                widget.title.toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: cs.onTertiary,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Placeholder content for a section that hasn't been implemented yet.
class _SectionPlaceholder extends StatelessWidget {
  const _SectionPlaceholder({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

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
            label,
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
