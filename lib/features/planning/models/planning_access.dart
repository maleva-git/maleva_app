/// What the signed-in user may do with the plan on screen, from the actions the Super Admin
/// gave the role (`GET /api/screen-access/planning/me`). A port of `planningAccess.ts`.
enum PlanningMode { newPlan, edit }

PlanningMode planningModeFor(int? planningId) => (planningId ?? 0) > 0 ? PlanningMode.edit : PlanningMode.newPlan;

class PlanningAccess {
  const PlanningAccess({
    required this.mode,
    required this.canView,
    required this.canCreate,
    required this.canEdit,
    required this.canDelete,
    required this.canWrite,
    required this.deniedReason,
    required this.deleteDeniedReason,
  });

  /// `resolvePlanningAccess`: actions without VIEW count for nothing; [canWrite] is CREATE on a
  /// new plan and EDIT on a saved one.
  factory PlanningAccess.resolve(Iterable<String>? actions, PlanningMode mode) {
    final granted = {...?actions?.map((a) => a.toUpperCase())};
    final canView = granted.contains('VIEW');
    final canCreate = canView && granted.contains('CREATE');
    final canEdit = canView && granted.contains('EDIT');
    final canDelete = canView && granted.contains('DELETE');
    final canWrite = mode == PlanningMode.edit ? canEdit : canCreate;
    return PlanningAccess(
      mode: mode,
      canView: canView,
      canCreate: canCreate,
      canEdit: canEdit,
      canDelete: canDelete,
      canWrite: canWrite,
      deniedReason: canWrite
          ? ''
          : mode == PlanningMode.edit
              ? 'View only: your role can open this plan but not change it.'
              : 'View only: your role cannot create a plan.',
      deleteDeniedReason: canDelete ? '' : 'Your role cannot delete a plan.',
    );
  }

  /// Until the rules arrive nothing is writable (`READ_ONLY_PLANNING_ACCESS`).
  static final readOnly = PlanningAccess.resolve(const ['VIEW'], PlanningMode.newPlan);

  final PlanningMode mode;
  final bool canView;
  final bool canCreate;
  final bool canEdit;
  final bool canDelete;
  final bool canWrite;
  final String deniedReason;
  final String deleteDeniedReason;

  /// The mode badge (`PlanningFilters.tsx:46-72`): "Read-only" / "Editing Plan #{n}" / "Editing" / "New plan".
  String badge(String planningNo) {
    if (!canWrite) return 'Read-only';
    if (mode == PlanningMode.edit) return planningNo.isNotEmpty ? 'Editing Plan #$planningNo' : 'Editing';
    return 'New plan';
  }
}

/// The view-only banner (`PlanningList.tsx:225-237`); the app does not know the role's name.
String viewOnlyBannerText({String? roleName}) =>
    'View only. ${roleName != null && roleName.isNotEmpty ? 'Your role ($roleName) can' : 'You can'} open, search and export plans. '
    'The Super Admin decides who may create and change plans (Utils → Screen Access).';
