import 'package:maleva/core/planning/planning_api.dart' show PlanSaveConflict;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:maleva/core/widgets/ui/ui.dart';
import 'package:maleva/features/planning/bloc/plan_cubit.dart';
import 'package:maleva/features/planning/bloc/plan_state.dart';
import 'package:maleva/features/planning/view/phone/phone_plan_view.dart';
import 'package:maleva/features/planning/view/tablet/tablet_board_view.dart';
import 'package:maleva/features/planning/view/tablet/tablet_portrait_view.dart';
import 'package:maleva/features/planning/widgets/plan_flows.dart';

/// The plan screen: a saved plan [planId], or a new plan. Phone, tablet portrait and tablet
/// landscape layouts share one [PlanCubit], so rotating or resizing keeps everything.
class PlanPage extends StatelessWidget {
  const PlanPage({super.key, this.planId});

  final int? planId;

  @override
  Widget build(BuildContext context) => MalevaThemeScope(
        child: BlocProvider<PlanCubit>(
          create: (_) => GetIt.instance<PlanCubit>()..start(planId: planId),
          child: const PlanScreen(),
        ),
      );
}

/// The screen under a provided [PlanCubit] (tests provide their own).
class PlanScreen extends StatelessWidget {
  const PlanScreen({super.key});

  static bool _typing() {
    final focus = FocusManager.instance.primaryFocus;
    return focus?.context?.widget is EditableText || focus?.context?.findAncestorWidgetOfExactType<EditableText>() != null;
  }

  /// Delete (Alt+Delete while typing) removes the selected row after its confirm (`:389-402`).
  static void _deleteKey(BuildContext context, {required bool alt}) {
    if (_typing() && !alt) return;
    final uid = context.read<PlanCubit>().state.selectedUid;
    if (uid != null) PlanFlows.remove(context, uid);
  }

  @override
  Widget build(BuildContext context) => MultiBlocListener(
        listeners: [
          BlocListener<PlanCubit, PlanState>(
            listenWhen: (a, b) => b.notice != null && a.notice?.seq != b.notice!.seq,
            listener: (context, s) {
              final n = s.notice!;
              showSnack(context, n.message,
                  kind: switch (n.kind) {
                    NoticeKind.success => SnackKind.success,
                    NoticeKind.info => SnackKind.info,
                    NoticeKind.error => SnackKind.error
                  },
                  duration: n.message.contains('\n') ? const Duration(seconds: 7) : null);
            },
          ),
          // Someone else saved the plan after it was opened (change plan-save-keeps-changes).
          BlocListener<PlanCubit, PlanState>(
            listenWhen: (a, b) => b.conflict != null && a.conflict?.seq != b.conflict!.seq,
            listener: (context, s) async {
              final cubit = context.read<PlanCubit>();
              final overwrite = await showPlanConflictDialog(context, s.conflict!.conflict);
              if (overwrite != null) await cubit.resolveConflict(overwrite: overwrite);
            },
          ),
        ],
        child: BlocBuilder<PlanCubit, PlanState>(
          buildWhen: (a, b) => a.phase != b.phase || a.access.canView != b.access.canView || a.hasChanges != b.hasChanges,
          builder: (context, s) {
            if (s.phase == PlanPhase.loading) {
              return Scaffold(
                appBar: AppBar(title: const Text('Planning')),
                body: const Column(children: [
                  Padding(padding: EdgeInsets.only(top: 16), child: Text('Loading planning data...')),
                  Expanded(child: SkeletonList()),
                ]),
              );
            }
            if (!s.access.canView) {
              return Scaffold(
                appBar: AppBar(title: const Text('Planning')),
                body: EmptyState(
                  title: 'Access Denied',
                  message: "You don't have permission to access this resource. Please contact your administrator if you believe this is an error.",
                  icon: Icons.lock_outline,
                  actionLabel: Navigator.of(context).canPop() ? 'Back' : null,
                  onAction: () => Navigator.of(context).maybePop(),
                ),
              );
            }
            if (s.phase == PlanPhase.employeesFailed) {
              return Scaffold(
                appBar: AppBar(title: const Text('Planning')),
                body: ErrorState(
                    title: 'Error loading employees', onRetry: () => context.read<PlanCubit>().start(planId: s.editId > 0 ? s.editId : null)),
              );
            }
            return PopScope(
              canPop: !s.hasChanges,
              onPopInvokedWithResult: (didPop, _) async {
                if (didPop) return;
                final nav = Navigator.of(context);
                if (await PlanFlows.confirmDiscard(context)) nav.pop();
              },
              child: CallbackShortcuts(
                bindings: {
                  const SingleActivator(LogicalKeyboardKey.f5): () => PlanFlows.openPlans(context),
                  const SingleActivator(LogicalKeyboardKey.delete): () => _deleteKey(context, alt: false),
                  const SingleActivator(LogicalKeyboardKey.delete, alt: true): () => _deleteKey(context, alt: true),
                },
                child: Focus(
                  autofocus: true,
                  child: ResponsiveLayout(
                    phone: (_) => const PhonePlanView(),
                    tabletPortrait: (_) => const TabletPortraitView(),
                    tabletLandscape: (_) => const TabletBoardView(),
                  ),
                ),
              ),
            );
          },
        ),
      );
}

/// "Plan changed by ANNA": true = save over it, false = reload, null = closed without choosing
/// (nothing happens; Save asks again). Change plan-save-keeps-changes.
Future<bool?> showPlanConflictDialog(BuildContext context, PlanSaveConflict c) => showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        key: const Key('plan_conflict_dialog'),
        title: Text('Plan changed by ${c.who}'),
        content: Text('${c.who} saved this plan${c.changedAt.isEmpty ? '' : ' at ${c.changedAt}'} after you opened it.\n\n'
            'Reload: their changes come in; the rows you changed here stay as you have them. Then save again.\n\n'
            'Save over it: your plan replaces what ${c.who} saved.'),
        actions: [
          TextButton(key: const Key('plan_conflict_reload'), onPressed: () => Navigator.pop(context, false), child: const Text('Reload')),
          TextButton(
            key: const Key('plan_conflict_overwrite'),
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Save over it'),
          ),
        ],
      ),
    );
