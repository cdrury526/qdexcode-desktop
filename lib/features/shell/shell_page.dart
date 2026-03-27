import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multi_split_view/multi_split_view.dart';

import 'package:qdexcode_desktop/core/state/window_state_provider.dart';
import 'package:qdexcode_desktop/core/state/window_state_service.dart';
import 'package:qdexcode_desktop/features/shell/center_panel.dart';
import 'package:qdexcode_desktop/features/shell/left_panel.dart';
import 'package:qdexcode_desktop/features/shell/right_panel.dart';

/// Minimum width constraints for each panel.
const double kLeftPanelMinWidth = 180;
const double kCenterPanelMinWidth = 400;
const double kRightPanelMinWidth = 180;

/// Main authenticated page with a 3-panel resizable layout.
///
/// ```
/// +----------+-----------------+----------+
/// | Left     | Center          | Right    |
/// | (20%)    | (60%)           | (20%)    |
/// | Project  | Workspace Host  | File Tree|
/// | Plan Nav | (fixed tabs)    | Git      |
/// | [footer] |                 | Search   |
/// +----------+-----------------+----------+
/// ```
///
/// Uses [MultiSplitView] from the multi_split_view package for
/// resizable panels with drag handles. Restores saved panel widths
/// on launch and persists changes via [PanelWidthsState].
class ShellPage extends ConsumerStatefulWidget {
  const ShellPage({super.key});

  @override
  ConsumerState<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends ConsumerState<ShellPage> {
  late final MultiSplitViewController _splitController;

  @override
  void initState() {
    super.initState();
    // Initialize with saved panel widths (or defaults).
    final saved = ref.read(panelWidthsStateProvider);
    _splitController = MultiSplitViewController(
      areas: [
        Area(data: 'left', flex: saved.leftFlex),
        Area(data: 'center', flex: saved.centerFlex),
        Area(data: 'right', flex: saved.rightFlex),
      ],
    );
  }

  @override
  void dispose() {
    _splitController.dispose();
    super.dispose();
  }

  /// Persist panel proportions when the user finishes dragging a divider.
  void _onWeightChange() {
    final areas = _splitController.areas;
    if (areas.length == 3) {
      ref.read(panelWidthsStateProvider.notifier).update(
            PanelWidths(
              leftFlex: areas[0].flex ?? 2,
              centerFlex: areas[1].flex ?? 6,
              rightFlex: areas[2].flex ?? 2,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // Listen for external panel width changes (e.g. restored from prefs
    // after async load) and sync the controller.
    ref.listen(panelWidthsStateProvider, (prev, next) {
      if (prev != next) {
        _splitController.areas = [
          Area(data: 'left', flex: next.leftFlex),
          Area(data: 'center', flex: next.centerFlex),
          Area(data: 'right', flex: next.rightFlex),
        ];
      }
    });

    return Scaffold(
      body: MultiSplitViewTheme(
        data: MultiSplitViewThemeData(
          dividerThickness: 1,
          dividerPainter: DividerPainters.background(
            color: cs.outline,
            highlightedColor: cs.primary.withValues(alpha: 0.6),
            animationEnabled: true,
          ),
        ),
        child: MultiSplitView(
          controller: _splitController,
          onDividerDragEnd: (_) => _onWeightChange(),
          builder: (context, area) {
            return switch (area.data as String) {
              'left' => const LeftPanel(),
              'center' => const CenterPanel(),
              'right' => const RightPanel(),
              _ => const SizedBox.shrink(),
            };
          },
        ),
      ),
    );
  }
}
