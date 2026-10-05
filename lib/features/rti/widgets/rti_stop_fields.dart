import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/widgets/ui/ui.dart';
import 'package:maleva/features/rti/bloc/rti_entry_bloc.dart';
import 'package:maleva/features/rti/models/rti_form.dart';
import 'package:maleva/features/rti/models/rti_stop.dart';
import 'package:maleva/features/rti/widgets/rti_text_field.dart';

/// The route-activity cells (`R/components/RTIRouteActivitiesGrid.tsx`), shared by the phone
/// card and the tablet grid.
abstract final class RtiStopFields {
  static void _edit(BuildContext c, int i, RtiStop Function(RtiStop) change) => c.read<RtiEntryBloc>().add(RtiStopEdited(i, change));

  static Future<void> confirmDelete(BuildContext context, int index) async {
    final bloc = context.read<RtiEntryBloc>();
    final ok = await showConfirm(context,
        title: 'Delete Activity?', message: 'This route activity will be removed.', confirmLabel: 'Delete', cancelLabel: 'Cancel', destructive: true);
    if (ok) bloc.add(RtiStopDeleted(index));
  }

  static Widget sequence(BuildContext c, int i, RtiStop s, {bool dense = false}) => RtiTextField(
      label: dense ? '' : 'Seq No',
      dense: dense,
      value: s.sequenceNo == 0 ? '' : '${s.sequenceNo}',
      keyboardType: TextInputType.number,
      inputFormatters: RtiTextField.digits,
      onChanged: (v) => _edit(c, i, (x) => x.copyWith(sequenceNo: int.tryParse(v) ?? 0)));

  static Widget location(BuildContext c, int i, RtiStop s) => PickerField(
        label: 'Destination',
        hint: '-- Select Destination --',
        value: s.locationName,
        onTap: () async {
          final r = await showPickerSheet<String>(c,
              title: 'Destination', options: [for (final l in RtiChoices.routeLocations) PickOption(value: l, label: l)], current: s.locationName, allowTyped: true, allowClear: true);
          if (r == null || !c.mounted) return;
          _edit(c, i, (x) => x.copyWith(locationName: r.cleared ? '' : (r.value ?? r.typed ?? '')));
        },
      );

  static Widget agent(BuildContext c, int i, RtiStop s) {
    final employees = c.read<RtiEntryBloc>().state.refs.employees;
    final name = s.employeeRefId != null
        ? (employees.where((e) => e.id == s.employeeRefId).firstOrNull?.fullName ?? '#${s.employeeRefId}')
        : (s.agentName ?? '');
    return PickerField(
      label: 'Agent Name',
      hint: '-- Select Agent Name --',
      value: name,
      onTap: () async {
        final r = await showPickerSheet<int>(c,
            title: 'Agent Name', options: [for (final e in employees) PickOption(value: e.id, label: e.fullName, subtitle: e.mobileNo)], current: s.employeeRefId, allowTyped: true, allowClear: true);
        if (r == null || !c.mounted) return;
        final bloc = c.read<RtiEntryBloc>();
        if (r.value != null) {
          bloc.add(RtiStopAgentPicked(i, employee: employees.firstWhere((e) => e.id == r.value)));
        } else {
          bloc.add(RtiStopAgentPicked(i, typed: r.typed));
        }
      },
    );
  }

  static Widget mobile(BuildContext c, int i, RtiStop s, {bool dense = false}) => RtiTextField(
      label: dense ? '' : 'Agent Mobile No', dense: dense, value: s.agentMobileNo, keyboardType: TextInputType.phone, onChanged: (v) => _edit(c, i, (x) => x.copyWith(agentMobileNo: v)));

  static Widget driverNumber(BuildContext c, int i, RtiStop s, {bool dense = false}) => RtiTextField(
      label: dense ? '' : 'Driver Number', dense: dense, value: s.driverNumber, keyboardType: TextInputType.phone, onChanged: (v) => _edit(c, i, (x) => x.copyWith(driverNumber: v)));

  static Widget jobType(BuildContext c, int i, RtiStop s) => PickerField(
        label: 'Job Type',
        hint: '-- Select Job Type --',
        value: s.jobType.isEmpty ? '' : RtiChoices.jobTypeLabel(s.jobType),
        onTap: () async {
          final r = await showPickerSheet<String>(c,
              title: 'Job Type', options: [for (final t in RtiChoices.jobTypes) PickOption(value: t.$1, label: t.$2)], current: s.jobType, allowClear: true);
          if (r == null || !c.mounted) return;
          _edit(c, i, (x) => x.copyWith(jobType: r.cleared ? '' : (r.value ?? '')));
        },
      );

  static Widget fullRoute(BuildContext c, int i, RtiStop s, {bool dense = false}) =>
      RtiTextField(label: dense ? '' : 'Full Destination', dense: dense, value: s.fullRoute, onChanged: (v) => _edit(c, i, (x) => x.copyWith(fullRoute: v)));

  static Widget marqis(BuildContext c, int i, RtiStop s) => SwitchRow(
      label: 'Marqis Clearance', value: s.marqisStatus == 1, onChanged: (v) => _edit(c, i, (x) => x.copyWith(marqisStatus: v ? 1 : 0)));

  static Widget remarks(BuildContext c, int i, RtiStop s, {bool dense = false}) =>
      RtiTextField(label: dense ? '' : 'Remarks', dense: dense, value: s.remarks, onChanged: (v) => _edit(c, i, (x) => x.copyWith(remarks: v)));

  /// ETA: a date and an `HH:mm` time, kept as `yyyy-MM-ddTHH:mm` (the web's cell).
  static Widget eta(BuildContext c, int i, RtiStop s) {
    final v = s.eta ?? '';
    final parts = v.contains('T') ? v.split('T') : [v, ''];
    final date = parts[0];
    final time = parts.length > 1 && parts[1].length >= 5 ? parts[1].substring(0, 5) : (parts.length > 1 ? parts[1] : '');
    return Row(children: [
      Expanded(
        child: PickerField(
          label: 'ETA',
          value: date.isEmpty ? '' : Fmt.ddMMyyyy(DateTime.tryParse(date)),
          icon: Icons.event_outlined,
          onTap: () async {
            final d = await showDatePicker(context: c, initialDate: DateTime.tryParse(date) ?? DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));
            if (d == null || !c.mounted) return;
            _edit(c, i, (x) => x.copyWith(eta: '${DateFormat('yyyy-MM-dd').format(d)}T${time.isEmpty ? '00:00' : time}'));
          },
        ),
      ),
      const SizedBox(width: 8),
      SizedBox(
        width: 110,
        child: PickerField(
          label: 'HH:mm',
          value: time,
          icon: Icons.schedule,
          onTap: () async {
            final hm = time.split(':');
            final t = await showTimePicker(
                context: c, initialTime: TimeOfDay(hour: int.tryParse(hm.first) ?? 0, minute: hm.length > 1 ? int.tryParse(hm[1]) ?? 0 : 0));
            if (t == null || !c.mounted) return;
            final day = date.isEmpty ? DateFormat('yyyy-MM-dd').format(DateTime.now()) : date;
            _edit(c, i, (x) => x.copyWith(eta: '${day}T${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}'));
          },
        ),
      ),
    ]);
  }

  /// Created Date, read-only: `yyyy-MM-dd HH:mm`.
  static String created(RtiStop s) {
    final v = s.createdDate ?? '';
    return v.contains('T') ? v.replaceFirst('T', ' ').substring(0, v.length >= 16 ? 16 : v.length) : v;
  }
}

/// One route activity on the phone (and in the tablet's stop list).
class RtiStopCard extends StatelessWidget {
  const RtiStopCard({super.key, required this.index, required this.stop});

  final int index;
  final RtiStop stop;

  @override
  Widget build(BuildContext context) {
    final s = stop;
    const gap = SizedBox(height: 10);
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 8, 14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            Expanded(child: Text('Stop ${s.sequenceNo}', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800))),
            IconButton(tooltip: 'Delete activity', icon: const Icon(Icons.delete_outline), onPressed: () => RtiStopFields.confirmDelete(context, index)),
          ]),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Row(children: [
                SizedBox(width: 96, child: RtiStopFields.sequence(context, index, s)),
                const SizedBox(width: 10),
                Expanded(child: RtiStopFields.jobType(context, index, s)),
              ]),
              gap,
              RtiStopFields.location(context, index, s),
              gap,
              RtiStopFields.agent(context, index, s),
              gap,
              Row(children: [
                Expanded(child: RtiStopFields.mobile(context, index, s)),
                const SizedBox(width: 10),
                Expanded(child: RtiStopFields.driverNumber(context, index, s)),
              ]),
              gap,
              RtiStopFields.fullRoute(context, index, s),
              RtiStopFields.marqis(context, index, s),
              RtiStopFields.remarks(context, index, s),
              gap,
              RtiStopFields.eta(context, index, s),
              if ((s.createdDate ?? '').isNotEmpty) KeyValueRow('Created Date', RtiStopFields.created(s)),
            ]),
          ),
        ]),
      ),
    );
  }
}
