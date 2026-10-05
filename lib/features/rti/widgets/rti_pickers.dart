import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/widgets/ui/ui.dart';
import 'package:maleva/features/rti/bloc/rti_entry_bloc.dart';
import 'package:maleva/features/rti/models/fleet_expiry.dart';
import 'package:maleva/features/rti/models/js_values.dart';

/// The driver and truck pickers of the RTI form (`R/components/RTIFormFields.tsx:224-262`):
/// the option id, its name, its expiry warnings and colour.
abstract final class RtiPickers {
  static String idOf(Map<String, dynamic> r) => Js.str(Js.field(r, ['id', 'Id', 'value']));

  static String driverName(Map<String, dynamic> r) => Js.fieldText(r, ['name', 'DriverName', 'AccountName']);
  static String truckName(Map<String, dynamic> r) => Js.fieldText(r, ['name', 'truckName', 'AccountName']);

  static List<PickOption<String>> drivers(List<Map<String, dynamic>> rows) => [
        for (final r in rows)
          if (idOf(r).isNotEmpty && driverName(r).isNotEmpty) _option(idOf(r), driverName(r), FleetExpiry.driver(r), badge: false),
      ];

  static List<PickOption<String>> trucks(List<Map<String, dynamic>> rows) => [
        for (final r in rows)
          if (idOf(r).isNotEmpty && truckName(r).isNotEmpty) _option(idOf(r), truckName(r), FleetExpiry.truck(r), badge: true),
      ];

  static PickOption<String> _option(String id, String label, List<FleetWarning> w, {required bool badge}) {
    final severity = FleetExpiry.severityOf(w);
    final shown = badge ? w : w.take(3).toList();
    final lines = [
      if (badge && severity == PickSeverity.critical) 'Urgent' else if (badge && severity == PickSeverity.warning) 'Due soon',
      ...shown.map((x) => x.message),
      if (!badge && w.length > 3) '+${w.length - 3} more',
    ];
    return PickOption(value: id, label: label, subtitle: lines.isEmpty ? null : lines.join('\n'), severity: severity);
  }

  static String label(List<PickOption<String>> options, String id) =>
      id.isEmpty ? '' : (options.where((o) => o.value == id).firstOrNull?.label ?? '#$id');

  static Future<void> pickDriver(BuildContext context) async {
    final bloc = context.read<RtiEntryBloc>();
    final s = bloc.state;
    final r = await showPickerSheet<String>(context,
        title: 'Driver', options: drivers(s.refs.drivers), current: s.form.driverRefId, allowClear: true, searchHint: 'Select driver');
    if (r == null) return;
    bloc.add(RtiDriverPicked(r.cleared ? '' : (r.value ?? '')));
  }

  static Future<void> pickTruck(BuildContext context) async {
    final bloc = context.read<RtiEntryBloc>();
    final s = bloc.state;
    final r = await showPickerSheet<String>(context,
        title: 'Vehicle', options: trucks(s.refs.trucks), current: s.form.truckRefId, allowClear: true, searchHint: 'Select vehicle');
    if (r == null) return;
    bloc.add(RtiTruckPicked(r.cleared ? '' : (r.value ?? '')));
  }
}
