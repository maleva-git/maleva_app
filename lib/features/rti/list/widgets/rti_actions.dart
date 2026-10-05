import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/widgets/ui/ui.dart';
import 'package:maleva/features/rti/list/bloc/rti_list_bloc.dart';
import 'package:maleva/features/rti/list/models/rti_list_row.dart';
import 'package:maleva/features/rti/rti_navigation.dart';

/// Asks first ("Send {rtiNo} to the truck's WhatsApp group?"), then shares.
Future<void> confirmAndShareRti(BuildContext context, RtiListRow row) async {
  final bloc = context.read<RtiListBloc>();
  final ok = await showConfirm(context,
      title: 'Share to WhatsApp', message: RtiListBloc.shareQuestion(row.rtiNo), confirmLabel: 'Send');
  if (ok && !bloc.isClosed) bloc.add(RtiShareRequested(row));
}

/// Opens the RTI in edit mode, then reloads the list.
Future<void> openRtiEdit(BuildContext context, int id) =>
    _navigate(context, () => RtiNavigation.openEdit(context, id));

/// Opens a new RTI, then reloads the list.
Future<void> openRtiNew(BuildContext context) => _navigate(context, () => RtiNavigation.openNew(context));

Future<void> _navigate(BuildContext context, Future<void> Function() go) async {
  final bloc = context.read<RtiListBloc>();
  try {
    await go();
  } on UnimplementedError {
    if (context.mounted) showSnack(context, 'The RTI screen is not available yet', kind: SnackKind.info);
    return;
  }
  if (!bloc.isClosed) bloc.add(const RtiListRetried());
}

/// Whether React would offer Report / Share for the row (`RTIViewPage.tsx:310-345`: a saved RTI
/// with a number).
bool rtiHasNumber(RtiListRow row) => row.id > 0 && row.rtiNo.isNotEmpty;

/// Report · Share · Edit as one row of buttons (the phone card).
class RtiCardActions extends StatelessWidget {
  const RtiCardActions({super.key, required this.row, required this.state});

  final RtiListRow row;
  final RtiListState state;

  @override
  Widget build(BuildContext context) {
    final mc = context.mc;
    final bloc = context.read<RtiListBloc>();
    final hasNo = rtiHasNumber(row);
    final reportBusy = state.reportBusyId == row.id;
    final shareBusy = state.shareBusyId == row.id;
    Widget button(String label, IconData icon, bool busy, VoidCallback? onTap) => Expanded(
          child: TextButton.icon(
            style: TextButton.styleFrom(minimumSize: const Size(0, 48)),
            onPressed: busy ? null : onTap,
            icon: busy ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : Icon(icon, size: 18),
            label: Text(label),
          ),
        );
    final divider = SizedBox(height: 48, child: VerticalDivider(width: 1, color: mc.outline));
    return Row(children: [
      button('Report', Icons.picture_as_pdf_outlined, reportBusy, hasNo ? () => bloc.add(RtiReportRequested(row)) : null),
      if (!state.isDriver) ...[
        divider,
        button('Share', Icons.send_outlined, shareBusy, hasNo ? () => confirmAndShareRti(context, row) : null),
        divider,
        button('Edit', Icons.edit_outlined, false, () => openRtiEdit(context, row.id)),
      ],
    ]);
  }
}
