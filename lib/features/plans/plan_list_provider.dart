/// Riverpod providers for plan state management.
///
/// Fetches plans for the currently selected project and exposes plan-related
/// state to the UI. Watches [selectedProjectProvider] so switching projects
/// automatically invalidates and refetches plans.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:qdexcode_desktop/core/api/api_client.dart';
import 'package:qdexcode_desktop/core/models/plan.dart';
import 'package:qdexcode_desktop/features/projects/project_provider.dart';

part 'plan_list_provider.g.dart';

// ---------------------------------------------------------------------------
// Plan list provider — fetches plans for the selected project
// ---------------------------------------------------------------------------

/// Fetches all plans for the currently selected project from the API.
///
/// Watches [selectedProjectProvider] so plan data auto-refreshes when the
/// user switches projects. Returns an empty list if no project is selected.
@riverpod
class PlanList extends _$PlanList {
  @override
  Future<List<Plan>> build() async {
    final projectAsync = await ref.watch(selectedProjectProvider.future);
    if (projectAsync == null) return [];

    final dio = ref.watch(apiClientProvider);
    final response = await dio.get<Map<String, dynamic>>(
      '/api/plans',
      queryParameters: {'projectId': projectAsync.id},
    );

    final data = response.data;
    if (data == null) return [];

    // The API may return {plans: [...]} or a raw list.
    final List<dynamic> plansList;
    if (data.containsKey('plans')) {
      plansList = data['plans'] as List<dynamic>? ?? [];
    } else if (data.containsKey('data')) {
      plansList = data['data'] as List<dynamic>? ?? [];
    } else {
      return [];
    }

    final plans = plansList
        .map((json) => Plan.fromJson(json as Map<String, dynamic>))
        .toList();

    // Sort by updatedAt descending (most recent first).
    plans.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    return plans;
  }

  /// Force-refresh the plan list.
  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}

// ---------------------------------------------------------------------------
// Single plan detail provider — fetches a plan with full relations
// ---------------------------------------------------------------------------

/// Fetches a single plan by ID with all nested phases, tasks, subtasks,
/// acceptance criteria, and file scopes.
@riverpod
Future<Plan> planDetail(Ref ref, String planId) async {
  final dio = ref.watch(apiClientProvider);
  final response = await dio.get<Map<String, dynamic>>(
    '/api/plans/$planId',
  );

  final data = response.data;
  if (data == null) {
    throw Exception('Plan not found');
  }

  // The API may wrap in {plan: {...}} or return the plan directly.
  final Map<String, dynamic> planJson;
  if (data.containsKey('plan')) {
    planJson = data['plan'] as Map<String, dynamic>;
  } else {
    planJson = data;
  }

  return Plan.fromJson(planJson);
}

// ---------------------------------------------------------------------------
// Plan navigation state — tracks which plan/task is selected in the tree
// ---------------------------------------------------------------------------

/// What the center panel should show for the plans feature.
sealed class PlanNavigationState {
  const PlanNavigationState();
}

/// No plan selected — show the default dashboard content.
class PlanNavigationNone extends PlanNavigationState {
  const PlanNavigationNone();
}

/// A plan is selected — show plan detail in center panel.
class PlanNavigationPlanDetail extends PlanNavigationState {
  const PlanNavigationPlanDetail(this.planId);
  final String planId;
}

/// A task is selected — show task detail in center panel.
class PlanNavigationTaskDetail extends PlanNavigationState {
  const PlanNavigationTaskDetail({
    required this.planId,
    required this.taskId,
  });
  final String planId;
  final String taskId;
}

/// Manages navigation state for the plan explorer.
///
/// Kept alive so navigation state persists across tab switches.
@Riverpod(keepAlive: true)
class PlanNavigation extends _$PlanNavigation {
  @override
  PlanNavigationState build() => const PlanNavigationNone();

  /// Navigate to a plan detail view.
  void selectPlan(String planId) {
    state = PlanNavigationPlanDetail(planId);
  }

  /// Navigate to a task detail view.
  void selectTask({required String planId, required String taskId}) {
    state = PlanNavigationTaskDetail(planId: planId, taskId: taskId);
  }

  /// Return to the default dashboard view.
  void clear() {
    state = const PlanNavigationNone();
  }
}

// ---------------------------------------------------------------------------
// Plan tree expansion state
// ---------------------------------------------------------------------------

/// Tracks which plan and phase nodes are expanded in the left panel tree.
@Riverpod(keepAlive: true)
class PlanTreeExpansion extends _$PlanTreeExpansion {
  @override
  ({Set<String> expandedPlanIds, Set<String> expandedPhaseIds}) build() =>
      (expandedPlanIds: <String>{}, expandedPhaseIds: <String>{});

  void togglePlan(String planId) {
    final plans = Set<String>.from(state.expandedPlanIds);
    if (plans.contains(planId)) {
      plans.remove(planId);
    } else {
      plans.add(planId);
    }
    state = (expandedPlanIds: plans, expandedPhaseIds: state.expandedPhaseIds);
  }

  void togglePhase(String phaseId) {
    final phases = Set<String>.from(state.expandedPhaseIds);
    if (phases.contains(phaseId)) {
      phases.remove(phaseId);
    } else {
      phases.add(phaseId);
    }
    state = (expandedPlanIds: state.expandedPlanIds, expandedPhaseIds: phases);
  }

  void expandPlan(String planId) {
    if (!state.expandedPlanIds.contains(planId)) {
      final plans = Set<String>.from(state.expandedPlanIds)..add(planId);
      state =
          (expandedPlanIds: plans, expandedPhaseIds: state.expandedPhaseIds);
    }
  }
}

// ---------------------------------------------------------------------------
// Plan filter state
// ---------------------------------------------------------------------------

/// Filter state for the plan tree.
@Riverpod(keepAlive: true)
class PlanFilter extends _$PlanFilter {
  @override
  ({String searchQuery, bool hideCompleted}) build() =>
      (searchQuery: '', hideCompleted: false);

  void setSearchQuery(String query) {
    state = (searchQuery: query, hideCompleted: state.hideCompleted);
  }

  void toggleHideCompleted() {
    state = (searchQuery: state.searchQuery, hideCompleted: !state.hideCompleted);
  }
}
