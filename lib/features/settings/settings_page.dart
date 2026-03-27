import 'package:flutter/material.dart';

import 'package:qdexcode_desktop/features/settings/settings_placeholder.dart';

/// Definition of a settings sub-tab.
class _SettingsSubTab {
  const _SettingsSubTab({
    required this.id,
    required this.label,
    required this.icon,
    required this.placeholderText,
  });

  final String id;
  final String label;
  final IconData icon;
  final String placeholderText;
}

/// All settings sub-tabs, matching the V1 layout.
const _kSettingsSubTabs = [
  _SettingsSubTab(
    id: 'general',
    label: 'General',
    icon: Icons.tune_outlined,
    placeholderText: 'General settings coming soon',
  ),
  _SettingsSubTab(
    id: 'api-keys',
    label: 'API Keys',
    icon: Icons.key_outlined,
    placeholderText: 'API key management coming soon',
  ),
  _SettingsSubTab(
    id: 'mcp-logs',
    label: 'MCP Logs',
    icon: Icons.receipt_long_outlined,
    placeholderText: 'MCP call logs coming soon',
  ),
  _SettingsSubTab(
    id: 'recent-deploys',
    label: 'Recent Deploys',
    icon: Icons.rocket_launch_outlined,
    placeholderText: 'Deploy history coming soon',
  ),
  _SettingsSubTab(
    id: 'ai-advisor',
    label: 'AI Advisor',
    icon: Icons.auto_awesome_outlined,
    placeholderText: 'AI Advisor coming soon',
  ),
];

/// Settings tab with horizontal pill sub-tab navigation.
///
/// Each sub-tab shows a centered [SettingsPlaceholder] card.
/// Sub-tab switches use [AnimatedSwitcher] for smooth transitions.
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int _selectedSubTab = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SubTabBar(
          tabs: _kSettingsSubTabs,
          selectedIndex: _selectedSubTab,
          onTabSelected: (index) => setState(() => _selectedSubTab = index),
        ),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _buildSubTabContent(_selectedSubTab),
          ),
        ),
      ],
    );
  }

  Widget _buildSubTabContent(int index) {
    final tab = _kSettingsSubTabs[index];
    return KeyedSubtree(
      key: ValueKey(tab.id),
      child: SettingsPlaceholder(
        icon: tab.icon,
        title: tab.label,
        subtitle: tab.placeholderText,
      ),
    );
  }
}

/// Horizontal pill-style sub-tab bar for settings navigation.
///
/// Compact height (36px) with pill-shaped selected indicator,
/// matching the V1 design reference.
class _SubTabBar extends StatelessWidget {
  const _SubTabBar({
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  final List<_SettingsSubTab> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: cs.outline, width: 1),
        ),
      ),
      child: Row(
        children: [
          for (int i = 0; i < tabs.length; i++)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: _SubTabPill(
                tab: tabs[i],
                isSelected: i == selectedIndex,
                onTap: () => onTabSelected(i),
              ),
            ),
          const Spacer(),
        ],
      ),
    );
  }
}

/// Individual pill-shaped sub-tab button.
class _SubTabPill extends StatefulWidget {
  const _SubTabPill({
    required this.tab,
    required this.isSelected,
    required this.onTap,
  });

  final _SettingsSubTab tab;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_SubTabPill> createState() => _SubTabPillState();
}

class _SubTabPillState extends State<_SubTabPill> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final isSelected = widget.isSelected;
    final foreground = isSelected ? cs.onSurface : cs.onTertiary;

    Color? background;
    if (isSelected) {
      background = cs.secondary;
    } else if (_hovered) {
      background = cs.secondary.withAlpha(128);
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(widget.tab.icon, size: 14, color: foreground),
                const SizedBox(width: 6),
                Text(
                  widget.tab.label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: foreground,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w400,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
