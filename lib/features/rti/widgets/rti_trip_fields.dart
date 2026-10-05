import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/widgets/ui/ui.dart';
import 'package:maleva/features/rti/bloc/rti_entry_bloc.dart';
import 'package:maleva/features/rti/models/rti_form.dart';
import 'package:maleva/features/rti/widgets/rti_pickers.dart';
import 'package:maleva/features/rti/widgets/rti_text_field.dart';

/// The trip part of the RTI form (`R/components/RTIFormFields.tsx:343-478, 573-590`): RTI No,
/// RTI Date, Driver, Outside Driver, Vehicle (+ licence banner), Outside Truck, Enter / Exit,
/// Destination, Seal By, Break Seal By. [columns] lays them out 1 (phone), 2 or 3 wide.
class RtiTripFields extends StatelessWidget {
  const RtiTripFields({super.key, this.columns = 1});

  final int columns;

  @override
  Widget build(BuildContext context) => BlocBuilder<RtiEntryBloc, RtiEntryState>(
        buildWhen: (a, b) => a.form != b.form || a.refs != b.refs || a.licenceWarning != b.licenceWarning || a.errors != b.errors,
        builder: (context, s) {
          final bloc = context.read<RtiEntryBloc>();
          final f = s.form;
          void set(RtiForm Function(RtiForm) c) => bloc.add(RtiFormChanged(c));
          final showErrors = s.errors.isNotEmpty;
          final drivers = RtiPickers.drivers(s.refs.drivers);
          final trucks = RtiPickers.trucks(s.refs.trucks);
          final fields = <Widget>[
            RtiTextField(label: 'RTI No', value: f.rtiNo, onChanged: (_) {}, readOnly: true),
            PickerField(
              label: 'RTI Date',
              value: f.rtiDate.isEmpty ? '' : Fmt.ddMMyyyy(DateTime.tryParse(f.rtiDate)),
              icon: Icons.event_outlined,
              required: true,
              errorText: showErrors && f.rtiDate.isEmpty ? 'Please select RTI Date' : null,
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.tryParse(f.rtiDate) ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) set((x) => x.copyWith(rtiDate: DateFormat('yyyy-MM-dd').format(picked)));
              },
            ),
            PickerField(
              label: 'Driver',
              value: RtiPickers.label(drivers, f.driverRefId),
              hint: 'Select driver',
              required: true,
              errorText: showErrors && f.driverRefId.isEmpty ? 'Please select Driver Name' : null,
              onTap: () => RtiPickers.pickDriver(context),
            ),
            RtiTextField(label: 'Outside Driver', value: f.outsideDriver, hint: 'Enter outside driver name', onChanged: (v) => set((x) => x.copyWith(outsideDriver: v))),
            PickerField(
              label: 'Vehicle',
              value: RtiPickers.label(trucks, f.truckRefId),
              hint: 'Select vehicle',
              required: true,
              errorText: showErrors && f.truckRefId.isEmpty ? 'Please select Vehicle Number' : null,
              onTap: () => RtiPickers.pickTruck(context),
            ),
            RtiTextField(label: 'Outside Truck', value: f.outsideTruck, hint: 'Enter outside truck plate', onChanged: (v) => set((x) => x.copyWith(outsideTruck: v))),
            _Link(label: 'Enter', value: f.eLink, onChanged: (v) => set((x) => x.copyWith(eLink: v))),
            _Link(label: 'Exit', value: f.exLink, onChanged: (v) => set((x) => x.copyWith(exLink: v))),
            RtiTextField(label: 'Destination', value: f.destination, onChanged: (v) => set((x) => x.copyWith(destination: v))),
            RtiTextField(label: 'Seal By', value: f.sealBy, onChanged: (v) => set((x) => x.copyWith(sealBy: v))),
            RtiTextField(label: 'Break Seal By', value: f.breakSealBy, onChanged: (v) => set((x) => x.copyWith(breakSealBy: v))),
          ];
          return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            if (s.licenceWarning != null) ...[RtiBanner(text: s.licenceWarning!, tone: StatusTone.danger), const SizedBox(height: 12)],
            RtiFieldGrid(columns: columns, children: fields),
          ]);
        },
      );
}

class _Link extends StatelessWidget {
  const _Link({required this.label, required this.value, required this.onChanged});

  final String label;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: context.mc.muted)),
        const SizedBox(height: 4),
        SegmentedChoice<String>(values: RtiChoices.links, selected: value, onChanged: onChanged, labelOf: (v) => v.isEmpty ? 'None' : v),
      ]);
}

/// Lays fields out [columns] wide, each row as tall as its tallest field.
class RtiFieldGrid extends StatelessWidget {
  const RtiFieldGrid({super.key, required this.columns, required this.children, this.gap = 12});

  final int columns;
  final List<Widget> children;
  final double gap;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i += columns) {
      final slice = children.sublist(i, (i + columns).clamp(0, children.length));
      rows.add(Padding(
        padding: EdgeInsets.only(bottom: gap),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          for (var j = 0; j < columns; j++) ...[
            if (j > 0) SizedBox(width: gap),
            Expanded(child: j < slice.length ? slice[j] : const SizedBox.shrink()),
          ],
        ]),
      ));
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: rows);
  }
}

/// A coloured notice line (licence warning, revise summary, errors).
class RtiBanner extends StatelessWidget {
  const RtiBanner({super.key, required this.text, this.tone = StatusTone.info, this.icon, this.title});

  final String text;
  final StatusTone tone;
  final IconData? icon;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final mc = context.mc;
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(color: mc.toneBg(tone), borderRadius: BorderRadius.circular(14)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon ?? (tone == StatusTone.danger ? Icons.warning_amber_rounded : Icons.info_outline), color: mc.toneFg(tone), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (title != null) Text(title!, style: TextStyle(color: mc.toneFg(tone), fontWeight: FontWeight.w800)),
              Text(text, style: TextStyle(color: mc.toneFg(tone), fontWeight: FontWeight.w600)),
            ]),
          ),
        ]),
      ),
    );
  }
}
