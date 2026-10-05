import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:maleva/core/utils/app_preferences.dart';
import 'package:maleva/core/widgets/ui/ui.dart';
import 'package:maleva/features/rti/bloc/rti_entry_bloc.dart';
import 'package:maleva/features/rti/models/planning_transfer_item.dart';
import 'package:maleva/features/rti/view/phone/rti_entry_phone.dart';
import 'package:maleva/features/rti/view/tablet/rti_entry_tablet.dart';
import 'package:maleva/features/rti/widgets/rti_entry_actions.dart';

/// The RTI entry (Add / Edit RTI) on phone and tablet (change `planning-rti-phone-tablet`, §9–§12).
/// [rtiId] opens a saved RTI; with [revise] it goes straight into the revise flow (its confirm
/// still shows); [fromPlanning] opens a new RTI pre-filled from Planning's Push RTI.
class RtiEntryPage extends StatelessWidget {
  const RtiEntryPage({super.key, this.rtiId, this.revise = false, this.fromPlanning = const []});

  final int? rtiId;
  final bool revise;
  final List<PlanningTransferItem> fromPlanning;

  RtiEntryStarted get _started => RtiEntryStarted(rtiId: rtiId, revise: revise, fromPlanning: fromPlanning);

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => GetIt.I<RtiEntryBloc>()..add(_started),
        child: MalevaThemeScope(child: _RtiEntryBody(revise: revise, started: _started)),
      );
}

class _RtiEntryBody extends StatefulWidget {
  const _RtiEntryBody({required this.revise, required this.started});

  final bool revise;
  final RtiEntryStarted started;

  @override
  State<_RtiEntryBody> createState() => _RtiEntryBodyState();
}

class _RtiEntryBodyState extends State<_RtiEntryBody> {
  bool _reviseAsked = false;

  /// The web's heading uses the signed-in employee's name (`localStorage.EmployeeName`).
  static String _employeeName() {
    try {
      return AppPreferences.getUsername();
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = _employeeName();
    void retry() => context.read<RtiEntryBloc>().add(widget.started);
    return MultiBlocListener(
      listeners: [
        BlocListener<RtiEntryBloc, RtiEntryState>(
          listenWhen: (a, b) => b.notice != null && a.notice != b.notice,
          listener: (context, s) {
            final n = s.notice!;
            showSnack(
              context,
              n.text,
              kind: switch (n.kind) {
                RtiNoticeKind.success => SnackKind.success,
                RtiNoticeKind.info || RtiNoticeKind.warning => SnackKind.info,
                RtiNoticeKind.error => SnackKind.error,
              },
              duration: n.long ? const Duration(seconds: 7) : null,
            );
          },
        ),
        // ?revise=1 (RTIPage.tsx:129-150): once the RTI is loaded, the revise flow starts with its confirm.
        BlocListener<RtiEntryBloc, RtiEntryState>(
          listenWhen: (a, b) => a.status != b.status && b.status == RtiLoadStatus.ready,
          listener: (context, s) {
            if (!widget.revise || _reviseAsked || !s.form.isEdit) return;
            _reviseAsked = true;
            RtiEntryActions.revise(context);
          },
        ),
      ],
      child: ResponsiveLayout(
        phone: (_) => RtiEntryPhone(employeeName: name, onRetry: retry),
        tabletPortrait: (_) => RtiEntryTablet(employeeName: name, columns: 2, onRetry: retry),
        tabletLandscape: (_) => RtiEntryTablet(employeeName: name, columns: 3, onRetry: retry),
      ),
    );
  }
}
