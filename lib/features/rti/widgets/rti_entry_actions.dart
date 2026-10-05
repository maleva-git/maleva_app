import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:maleva/core/rti/rti_api.dart';
import 'package:maleva/core/utils/json_read.dart';
import 'package:maleva/core/widgets/ui/ui.dart';
import 'package:maleva/features/rti/bloc/rti_entry_bloc.dart';
import 'package:maleva/features/rti/rti_navigation.dart';
import 'package:maleva/features/rti/widgets/levi_sheet.dart';
import 'package:url_launcher/url_launcher.dart';

/// The RTI page's actions, shared by the phone menu and the tablet toolbar, with the web's
/// confirms and messages (`R/hooks/useRTIOperations.ts`, `R/components/RtiShareWhatsAppButton.tsx`,
/// `R/api/rtiReportApi.ts`).
abstract final class RtiEntryActions {
  static RtiEntryBloc _bloc(BuildContext c) => c.read<RtiEntryBloc>();

  /// Save (F1). A revise asks once more before it overwrites the RTI (decision Q-REV = B).
  static Future<void> save(BuildContext context) async {
    final bloc = _bloc(context);
    if (bloc.state.isBusy && bloc.state.busy != RtiBusy.lookingUp) return;
    if (bloc.state.inRevise) {
      final ok = await showConfirm(context,
          title: 'Save revised RTI?',
          message: 'The RTI is updated with the values from the sales orders and your edits.',
          confirmLabel: 'Save');
      if (!ok) return;
    }
    bloc.add(const RtiSaveRequested());
  }

  /// Delete RTI.
  static Future<void> delete(BuildContext context) async {
    final bloc = _bloc(context);
    if (!bloc.state.form.isEdit) {
      showSnack(context, 'No RTI selected for delete.', kind: SnackKind.info);
      return;
    }
    final ok = await showConfirm(context,
        title: 'Delete RTI',
        message: 'Do you want to permanently delete this RTI? This action cannot be undone.',
        confirmLabel: 'Yes, Delete',
        cancelLabel: 'Cancel',
        destructive: true);
    if (ok) bloc.add(const RtiDeleteRequested());
  }

  /// Revise from the sales orders.
  static Future<void> revise(BuildContext context) async {
    final bloc = _bloc(context);
    if (!bloc.state.form.isEdit) {
      showSnack(context, 'No RTI selected to revise.', kind: SnackKind.info);
      return;
    }
    final ok = await showConfirm(context,
        title: 'Revise RTI',
        message: 'Do you want to revise data from the Sales Order? This will overwrite the current RTI information.',
        confirmLabel: 'Yes, Revise',
        cancelLabel: 'Cancel');
    if (ok) bloc.add(const RtiReviseRequested());
  }

  /// Clear (F10): a new RTI.
  static void clear(BuildContext context) => _bloc(context).add(const RtiClearRequested());

  /// View (F5): the RTI list.
  static Future<void> view(BuildContext context) async {
    await RtiNavigation.openList(context, replace: true);
  }

  /// Levi Entry: a bottom sheet (phone) or side sheet (tablet).
  static Future<void> levi(BuildContext context) => LeviSheet.open(context, _bloc(context).state.form);

  /// Share to WhatsApp: the truck's group gets the RTI and its report.
  static Future<void> share(BuildContext context) async {
    final bloc = _bloc(context);
    final f = bloc.state.form;
    if (!f.isEdit) return;
    final ok = await showConfirm(context, title: 'Share to WhatsApp', message: "Send ${f.rtiNo} to the truck's WhatsApp group?", confirmLabel: 'Send');
    if (!ok || !context.mounted) return;
    try {
      final r = await GetIt.I<RtiApi>().shareWhatsApp(f.editId);
      if (!context.mounted) return;
      if (JsonRead.boolean(r['sent'])) {
        final truck = JsonRead.string(r['truck']);
        showSnack(context, '${JsonRead.string(r['rtiNo'])} sent to the group of ${truck.isEmpty ? 'the truck' : truck}');
        final skipped = JsonRead.stringOrNull(r['documentSkipped']);
        if (skipped != null) {
          await Future<void>.delayed(const Duration(seconds: 3));
          if (context.mounted) showSnack(context, skipped, kind: SnackKind.info, duration: const Duration(seconds: 10));
        }
      } else {
        final detail = JsonRead.string(r['detail']);
        showSnack(context, detail.isEmpty ? 'The message was not sent' : detail, kind: SnackKind.error, duration: const Duration(seconds: 8));
      }
    } catch (e) {
      if (!context.mounted) return;
      final text = '$e'.trim();
      showSnack(context, text.isEmpty ? 'Could not share this RTI' : text, kind: SnackKind.error, duration: const Duration(seconds: 8));
    }
  }

  /// RTI report: the PDF through its ticket link.
  static Future<void> report(BuildContext context) async {
    final f = _bloc(context).state.form;
    if (!f.isEdit) {
      showSnack(context, 'RTI details are missing for the RTI report.', kind: SnackKind.error);
      return;
    }
    try {
      final url = await GetIt.I<RtiApi>().reportUrl(f.editId);
      final opened = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      if (!opened) throw Exception();
    } catch (_) {
      if (context.mounted) showSnack(context, 'Could not open the RTI report', kind: SnackKind.error);
    }
  }
}
