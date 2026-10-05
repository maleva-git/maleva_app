import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/utils/json_read.dart';
import 'package:maleva/core/widgets/ui/ui.dart';
import 'package:maleva/features/rti/bloc/levi_bloc.dart';
import 'package:maleva/features/rti/bloc/rti_entry_bloc.dart';
import 'package:maleva/features/rti/models/rti_form.dart';
import 'package:maleva/features/rti/widgets/rti_pickers.dart';
import 'package:maleva/features/rti/widgets/rti_text_field.dart';

/// The Levi entry of the RTI on screen (`R/components/RTILeviEntryModal.tsx`): a bottom sheet
/// on the phone, a side sheet on a tablet.
class LeviSheet extends StatelessWidget {
  const LeviSheet({super.key, required this.drivers, required this.trucks});

  final List<Map<String, dynamic>> drivers;
  final List<Map<String, dynamic>> trucks;

  static Future<void> open(BuildContext context, RtiForm rti) async {
    final entry = context.read<RtiEntryBloc>().state;
    final theme = Theme.of(context);
    final bloc = GetIt.I<LeviBloc>(param1: LeviContext(
      rtiId: rti.editId,
      rtiNo: rti.rtiNo,
      truckRefId: rti.truckRefId,
      driverRefId: rti.driverRefId,
      eLink: rti.eLink,
      exLink: rti.exLink,
      employeeRefId: context.read<RtiEntryBloc>().employeeId,
    ))
      ..add(const LeviOpened());
    final sheet = Theme(
      data: theme,
      child: BlocProvider.value(value: bloc, child: LeviSheet(drivers: entry.refs.drivers, trucks: entry.refs.trucks)),
    );
    if (FormFactor.of(context).isTablet) {
      await showGeneralDialog<void>(
        context: context,
        barrierDismissible: true,
        barrierLabel: 'Close',
        pageBuilder: (_, __, ___) => Align(
          alignment: Alignment.centerRight,
          child: Material(
            elevation: 8,
            child: SizedBox(width: 520, height: double.infinity, child: SafeArea(child: sheet)),
          ),
        ),
        transitionBuilder: (_, a, __, child) => SlideTransition(
          position: Tween(begin: const Offset(1, 0), end: Offset.zero).animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
          child: child,
        ),
      );
    } else {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (ctx) => SizedBox(height: MediaQuery.sizeOf(ctx).height * 0.92, child: sheet),
      );
    }
    await bloc.close();
  }

  @override
  Widget build(BuildContext context) => BlocConsumer<LeviBloc, LeviState>(
        listenWhen: (a, b) => a.messageSeq != b.messageSeq && b.message != null,
        listener: (context, s) => showSnack(context, s.message!, kind: s.messageIsError ? SnackKind.error : SnackKind.success),
        builder: (context, s) {
          final bloc = context.read<LeviBloc>();
          final ctx = bloc.context;
          final mc = context.mc;
          void patch(LeviForm Function(LeviForm) c) => bloc.add(LeviFormPatched(c));
          final truckOptions = RtiPickers.trucks(trucks);
          final driverOptions = RtiPickers.drivers(drivers);
          return ScaffoldMessenger(
            child: Scaffold(
              backgroundColor: context.cs.surface,
              body: Column(children: [
                ListTile(
                  title: const Text('Levi entry', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                  subtitle: Text('Filed against RTI ${ctx.rtiNo.isEmpty ? ctx.rtiId : ctx.rtiNo} · ${s.entryId != 0 ? 'editing ${s.documentNumber}' : 'new entry'}'),
                  trailing: IconButton(tooltip: 'Close', icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).maybePop()),
                ),
                Expanded(
                  child: ListView(padding: const EdgeInsets.fromLTRB(16, 4, 16, 16), children: [
                    Row(children: [
                      for (final type in RtiChoices.leviEntryTypes) ...[
                        if (type != RtiChoices.leviEntryTypes.first) const SizedBox(width: 10),
                        Expanded(child: _Slot(type: type, state: s, onTap: s.busy ? null : () => bloc.add(LeviTypeSelected(type)))),
                      ],
                    ]),
                    const SizedBox(height: 16),
                    RtiTextField(label: 'Levi no', value: s.documentNumber.isEmpty ? '—' : s.documentNumber, readOnly: true, onChanged: (_) {}),
                    const SizedBox(height: 12),
                    PickerField(
                      label: 'Date',
                      value: Fmt.ddMMyyyy(DateTime.tryParse(s.form.saleDate)),
                      icon: Icons.event_outlined,
                      enabled: !s.busy,
                      onTap: () async {
                        final d = await showDatePicker(context: context, initialDate: DateTime.tryParse(s.form.saleDate) ?? DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));
                        if (d != null) patch((f) => f.copyWith(saleDate: DateFormat('yyyy-MM-dd').format(d)));
                      },
                    ),
                    const SizedBox(height: 12),
                    const _Label('Entry type'),
                    SegmentedChoice<String>(values: const ['', 'IN', 'OUT'], selected: s.form.entryType, labelOf: (v) => v.isEmpty ? 'Not set' : v, onChanged: (v) => bloc.add(LeviEntryTypeChanged(v))),
                    const SizedBox(height: 12),
                    const _Label('Link'),
                    SegmentedChoice<String>(values: const ['', '1ST LINK', '2ND LINK'], selected: s.form.link, labelOf: (v) => v.isEmpty ? 'Not set' : v, onChanged: (v) => patch((f) => f.copyWith(link: v))),
                    const SizedBox(height: 12),
                    RtiTextField(label: 'RTI no', value: ctx.rtiNo.isEmpty ? '${ctx.rtiId}' : ctx.rtiNo, readOnly: true, onChanged: (_) {}),
                    const SizedBox(height: 12),
                    PickerField(
                      label: 'Truck',
                      hint: 'Select truck',
                      value: RtiPickers.label(truckOptions, s.form.truckRefId),
                      enabled: !s.busy,
                      onTap: () async {
                        final r = await showPickerSheet<String>(context, title: 'Truck', options: truckOptions, current: s.form.truckRefId, allowClear: true);
                        if (r != null) patch((f) => f.copyWith(truckRefId: r.cleared ? '' : r.value));
                      },
                    ),
                    const SizedBox(height: 12),
                    PickerField(
                      label: 'Driver',
                      hint: 'Select driver',
                      value: RtiPickers.label(driverOptions, s.form.driverRefId),
                      enabled: !s.busy,
                      onTap: () async {
                        final r = await showPickerSheet<String>(context, title: 'Driver', options: driverOptions, current: s.form.driverRefId, allowClear: true);
                        if (r != null) patch((f) => f.copyWith(driverRefId: r.cleared ? '' : r.value));
                      },
                    ),
                    const SizedBox(height: 12),
                    RtiTextField(label: 'Amount', hint: '0.00', value: s.form.amount, keyboardType: const TextInputType.numberWithOptions(decimal: true), onChanged: (v) => patch((f) => f.copyWith(amount: v))),
                    const SizedBox(height: 12),
                    RtiTextField(label: 'Remarks', value: s.form.remarks, minLines: 2, maxLines: 4, maxLength: 2000, onChanged: (v) => patch((f) => f.copyWith(remarks: v))),
                    const SizedBox(height: 16),
                    _Attachments(state: s),
                    const SizedBox(height: 16),
                    _Entries(state: s),
                  ]),
                ),
                StickyActionBar(actions: [
                  OutlinedButton(onPressed: () => Navigator.of(context).maybePop(), child: const Text('Close')),
                  FilledButton.icon(onPressed: s.busy ? null : () => bloc.add(const LeviSaveRequested()), icon: const Icon(Icons.save_outlined), label: Text(s.saveLabel)),
                ], leading: Text(s.staged.isEmpty ? '' : '${s.staged.length} file${s.staged.length > 1 ? 's' : ''} will upload when you save.', style: TextStyle(color: mc.toneFg(StatusTone.info), fontWeight: FontWeight.w600))),
              ]),
            ),
          );
        },
      );
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(text, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: context.mc.muted)),
      );
}

class _Slot extends StatelessWidget {
  const _Slot({required this.type, required this.state, required this.onTap});

  final String type;
  final LeviState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final filed = state.entryOfType(type);
    final active = state.form.entryType == type;
    final mc = context.mc;
    final status = state.listStatus == LeviListStatus.loading ? 'Loading…' : (filed != null ? filed.cNumberDisplay : 'Not filed');
    final tone = state.listStatus == LeviListStatus.loading ? StatusTone.neutral : (filed != null ? StatusTone.warning : StatusTone.success);
    return Semantics(
      button: true,
      selected: active,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: active ? mc.primarySoft : context.cs.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: active ? context.cs.primary : mc.outline, width: active ? 2 : 1),
          ),
          child: Row(children: [
            Text(type, style: TextStyle(fontWeight: FontWeight.w800, color: active ? context.cs.primary : null)),
            const Spacer(),
            Flexible(child: StatusPill(status, tone: tone)),
          ]),
        ),
      ),
    );
  }
}

class _Attachments extends StatelessWidget {
  const _Attachments({required this.state});
  final LeviState state;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<LeviBloc>();
    final names = [for (final a in state.attachments) JsonRead.string(a['fileName'])];
    return DetailSection(
      title: 'Attachments',
      icon: Icons.attach_file,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        if (names.isEmpty && state.staged.isEmpty)
          Text(state.entryId != 0 ? 'No files attached yet.' : 'Files you add here upload once the entry is saved.', style: TextStyle(color: context.mc.muted)),
        for (final n in names)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.insert_drive_file_outlined),
            title: Text(n, style: state.stagedDeletions.contains(n) ? const TextStyle(decoration: TextDecoration.lineThrough) : null),
            trailing: IconButton(
              tooltip: state.stagedDeletions.contains(n) ? 'Undo' : 'Remove',
              icon: Icon(state.stagedDeletions.contains(n) ? Icons.undo : Icons.delete_outline),
              onPressed: () => bloc.add(LeviAttachmentDeletionToggled(n)),
            ),
          ),
        for (var i = 0; i < state.staged.length; i++)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.upload_file_outlined),
            title: Text(state.staged[i].uri.pathSegments.last),
            trailing: IconButton(tooltip: 'Remove', icon: const Icon(Icons.close), onPressed: () => bloc.add(LeviStagedFileRemoved(i))),
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            icon: const Icon(Icons.add_a_photo_outlined),
            label: const Text('Add photo or file'),
            onPressed: () async {
              final picked = await ImagePicker().pickMultiImage();
              if (picked.isNotEmpty) bloc.add(LeviFilesAdded([for (final x in picked) File(x.path)]));
            },
          ),
        ),
      ]),
    );
  }
}

class _Entries extends StatelessWidget {
  const _Entries({required this.state});
  final LeviState state;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<LeviBloc>();
    final mc = context.mc;
    Widget body;
    if (state.listStatus == LeviListStatus.loading) {
      body = Text('Loading…', style: TextStyle(color: mc.muted));
    } else if (state.listStatus == LeviListStatus.failed) {
      body = Text('Could not load the levi entries for this RTI.', style: TextStyle(color: context.cs.error));
    } else if (state.items.isEmpty) {
      body = Text('Nothing filed against this RTI yet.', style: TextStyle(color: mc.muted));
    } else {
      body = Column(children: [
        for (final i in state.items)
          ListTile(
            contentPadding: EdgeInsets.zero,
            selected: i.id == state.entryId,
            title: Text('${i.cNumberDisplay} · ${i.enterLink.isEmpty ? '—' : i.enterLink} · ${i.exitLink.isEmpty ? '—' : i.exitLink}', style: const TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Text('${i.saleDate.length >= 10 ? i.saleDate.substring(0, 10) : i.saleDate} · ${i.truckName ?? '—'} · ${i.driverName ?? '—'} · ${(i.amount ?? 0).toStringAsFixed(2)}'),
            trailing: Wrap(children: [
              TextButton(onPressed: state.busy ? null : () => bloc.add(LeviEditTapped(i)), child: const Text('Edit')),
              IconButton(
                tooltip: 'Delete ${i.cNumberDisplay}',
                icon: Icon(Icons.delete_outline, color: context.cs.error),
                onPressed: state.busy
                    ? null
                    : () async {
                        final ok = await showConfirm(context, title: 'Delete levi entry?', message: '${i.cNumberDisplay} will be deleted.', confirmLabel: 'Delete', destructive: true);
                        if (ok) bloc.add(LeviDeleteRequested(i));
                      },
              ),
            ]),
          ),
      ]);
    }
    return DetailSection(
      title: 'Levi entries on this RTI',
      trailing: state.items.isEmpty ? null : Text('Total ${state.amountTotalText}', style: const TextStyle(fontWeight: FontWeight.w700)),
      child: body,
    );
  }
}
