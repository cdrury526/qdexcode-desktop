import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:qdexcode_desktop/core/state/window_state_provider.dart';
import 'package:qdexcode_desktop/features/dashboard/dashboard_page.dart';
import 'package:qdexcode_desktop/features/plans/plan_detail_view.dart';
import 'package:qdexcode_desktop/features/plans/plan_list_provider.dart';
import 'package:qdexcode_desktop/features/plans/task_detail_view.dart';
import 'package:qdexcode_desktop/features/settings/settings_page.dart';
import 'package:qdexcode_desktop/features/shell/workspace_tab_bar.dart';
import 'package:qdexcode_desktop/features/terminal/terminal_page.dart';

/// Default workspace tabs that are always present.
const kDefaultWorkspaceTabs = [
  WorkspaceTab(id: 'dashboard', label: 'Dashboard', icon: Icons.dashboard_outlined),
  WorkspaceTab(id: 'terminal', label: 'Terminal', icon: Icons.terminal_outlined),
  WorkspaceTab(id: 'editor', label: 'Editor', icon: Icons.code_outlined),
  WorkspaceTab(id: 'settings', label: 'Settings', icon: Icons.settings_outlined),
];

/// Center workspace panel with a fixed tab bar and content area.
///
/// Each tab hosts its own content widget. Sub-navigation (e.g. plan detail
/// views within the Dashboard tab) is handled by the content widgets
/// themselves, not by creating new top-level tabs.
class CenterPanel extends ConsumerStatefulWidget {
  const CenterPanel({super.key});

  @override
  ConsumerState<CenterPanel> createState() => _CenterPanelState();
}

class _CenterPanelState extends ConsumerState<CenterPanel> {
  @override
  Widget build(BuildContext context) {
    final activeTabId = ref.watch(activeTabStateProvider);
    final selectedIndex = kDefaultWorkspaceTabs
        .indexWhere((tab) => tab.id == activeTabId)
        .clamp(0, kDefaultWorkspaceTabs.length - 1);

    return Column(
      children: [
        WorkspaceTabBar(
          tabs: kDefaultWorkspaceTabs,
          selectedIndex: selectedIndex,
          onTabSelected: (index) {
            ref.read(activeTabStateProvider.notifier).setTab(
                  kDefaultWorkspaceTabs[index].id,
                );
          },
        ),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _buildTabContent(selectedIndex),
          ),
        ),
      ],
    );
  }

  Widget _buildTabContent(int index) {
    final tab = kDefaultWorkspaceTabs[index];
    return KeyedSubtree(
      key: ValueKey(tab.id),
      child: switch (tab.id) {
        'dashboard' => const _DashboardOrPlanDetail(),
        'terminal' => const TerminalPage(),
        'editor' => const _EditorPlaceholder(),
        'settings' => const SettingsPage(),
        _ => const SizedBox.shrink(),
      },
    );
  }
}

/// Routes between the dashboard and plan/task detail views based on
/// the [planNavigationProvider] state.
class _DashboardOrPlanDetail extends ConsumerWidget {
  const _DashboardOrPlanDetail();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navState = ref.watch(planNavigationProvider);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: switch (navState) {
        PlanNavigationNone() => const DashboardPage(),
        PlanNavigationPlanDetail(planId: final id) => PlanDetailView(
            key: ValueKey('plan-detail-$id'),
            planId: id,
          ),
        PlanNavigationTaskDetail(planId: final pId, taskId: final tId) =>
          TaskDetailView(
            key: ValueKey('task-detail-$tId'),
            planId: pId,
            taskId: tId,
          ),
      },
    );
  }
}

/// Placeholder for the Editor tab content.
class _EditorPlaceholder extends StatelessWidget {
  const _EditorPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const _PlaceholderContent(
      icon: Icons.code_outlined,
      title: 'Editor',
      subtitle: 'Coming soon',
    );
  }
}

/// Shared skeleton placeholder used by each tab.
class _PlaceholderContent extends StatelessWidget {
  const _PlaceholderContent({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: cs.onTertiary),
          const SizedBox(height: 12),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
