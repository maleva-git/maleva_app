import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:maleva/core/widgets/ui/ui.dart';
import 'package:maleva/features/planning/planning_navigation.dart';
import 'package:maleva/features/planning/plans/bloc/plans_bloc.dart';
import 'package:maleva/features/planning/plans/models/plans_notice.dart';
import 'package:maleva/features/planning/plans/view/phone/plans_phone_view.dart';
import 'package:maleva/features/planning/plans/view/tablet/plans_tablet_view.dart';

/// Planning View (the saved plans) on phone and tablet (change `planning-rti-phone-tablet`,
/// rows PW1–PW6). Register the feature with `registerPlansFeature` first.
class PlansPage extends StatelessWidget {
  const PlansPage({super.key});

  @override
  Widget build(BuildContext context) => MalevaThemeScope(
        child: BlocProvider<PlansBloc>(
          create: (_) => GetIt.I<PlansBloc>()..add(const PlansStarted()),
          child: const _PlansBody(),
        ),
      );
}

class _PlansBody extends StatelessWidget {
  const _PlansBody();

  Future<void> _newPlan(BuildContext context) async {
    final bloc = context.read<PlansBloc>();
    try {
      await PlanningNavigation.openPlan(context);
    } on UnimplementedError {
      if (context.mounted) showSnack(context, 'The plan screen is not available yet', kind: SnackKind.info);
      return;
    }
    if (!bloc.isClosed) bloc.add(const PlansRefreshed());
  }

  @override
  Widget build(BuildContext context) => BlocListener<PlansBloc, PlansState>(
        listenWhen: (a, b) => b.notice != null && a.notice != b.notice,
        listener: (context, s) {
          final n = s.notice!;
          showSnack(context, n.message,
              kind: switch (n.kind) {
                PlansNoticeKind.success => SnackKind.success,
                PlansNoticeKind.info => SnackKind.info,
                PlansNoticeKind.error => SnackKind.error,
              });
        },
        child: ResponsiveLayout(
          phone: (context) => PlansPhoneView(onNewPlan: () => _newPlan(context)),
          tabletPortrait: (context) => PlansTabletPortraitView(onNewPlan: () => _newPlan(context)),
          tabletLandscape: (context) => PlansTabletLandscapeView(onNewPlan: () => _newPlan(context)),
        ),
      );
}
