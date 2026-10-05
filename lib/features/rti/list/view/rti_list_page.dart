import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:maleva/core/widgets/ui/ui.dart';
import 'package:maleva/features/rti/list/bloc/rti_list_bloc.dart';
import 'package:maleva/features/rti/list/models/rti_list_notice.dart';
import 'package:maleva/features/rti/list/view/phone/rti_list_phone_view.dart';
import 'package:maleva/features/rti/list/view/tablet/rti_list_tablet_view.dart';
import 'package:maleva/features/rti/rti_navigation.dart';

/// The RTI list (RTI View) on phone and tablet (change `planning-rti-phone-tablet`, rows
/// RLs1–RLs8, RS1, RS2). Register the feature with `registerRtiListFeature` first.
class RtiListPage extends StatelessWidget {
  const RtiListPage({super.key});

  @override
  Widget build(BuildContext context) => MalevaThemeScope(
        child: BlocProvider<RtiListBloc>(
          create: (_) => GetIt.I<RtiListBloc>()..add(const RtiListStarted()),
          child: const _RtiListBody(),
        ),
      );
}

class _RtiListBody extends StatelessWidget {
  const _RtiListBody();

  Future<void> _assignments(BuildContext context) async {
    try {
      await RtiNavigation.openAssignments(context);
    } on UnimplementedError {
      if (context.mounted) showSnack(context, 'Employee assignments are not available yet', kind: SnackKind.info);
    }
  }

  static SnackKind _kind(RtiNoticeKind k) => switch (k) {
        RtiNoticeKind.success => SnackKind.success,
        RtiNoticeKind.info => SnackKind.info,
        RtiNoticeKind.error => SnackKind.error,
      };

  void _show(BuildContext context, RtiListNotice n) {
    showSnack(context, n.message, kind: _kind(n.kind), duration: n.duration);
    final next = n.followUp;
    if (next == null) return;
    // Queued after the first (showSnack would replace it): the message went, the report did not.
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(
      duration: next.duration ?? const Duration(seconds: 10),
      content: Row(children: [
        const Icon(Icons.description_outlined),
        const SizedBox(width: 12),
        Expanded(child: Text(next.message)),
      ]),
    ));
  }

  @override
  Widget build(BuildContext context) => BlocListener<RtiListBloc, RtiListState>(
        listenWhen: (a, b) => b.notice != null && a.notice != b.notice,
        listener: (context, s) => _show(context, s.notice!),
        child: ResponsiveLayout(
          phone: (context) => RtiListPhoneView(onAssignments: () => _assignments(context)),
          tabletPortrait: (context) => RtiListTabletPortraitView(onAssignments: () => _assignments(context)),
          tabletLandscape: (context) => RtiListTabletLandscapeView(onAssignments: () => _assignments(context)),
        ),
      );
}
