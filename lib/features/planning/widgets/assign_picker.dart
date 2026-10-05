import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/widgets/ui/ui.dart';
import 'package:maleva/features/planning/bloc/plan_cubit.dart';
import 'package:maleva/features/planning/models/fleet_options.dart';
import 'package:maleva/features/planning/models/plan_line.dart';

/// The truck and driver pickers of a plan row (the web's `TruckSelectModal` / `DriverSelectModal`):
/// searchable, recent first, "Current" marked, expiry and leave colours, Clear. Picking a truck
/// changes only TRUCK, picking a driver only DRIVER, and only on the rows given.
abstract final class AssignPicker {
  static PickSeverity severityOf(ExpirySeverity s) => switch (s) {
        ExpirySeverity.normal => PickSeverity.normal,
        ExpirySeverity.warning => PickSeverity.warning,
        ExpirySeverity.critical => PickSeverity.critical,
        ExpirySeverity.leaveApproved => PickSeverity.leaveApproved,
        ExpirySeverity.leavePending => PickSeverity.leavePending,
      };

  static String? _subtitle(ExpiryState e, {bool truck = false}) {
    if (e.warnings.isEmpty) return null;
    final lines = e.warnings.map((w) => w.message).join(' · ');
    if (!truck || e.severity == ExpirySeverity.normal) return lines;
    return '${e.severity == ExpirySeverity.critical ? 'Urgent' : 'Due soon'} · $lines';
  }

  static List<PlanLine> _rows(PlanCubit cubit, Set<int> uids) => cubit.state.rows.where((r) => uids.contains(r.uid)).toList();

  static Future<void> truck(BuildContext context, Set<int> uids) async {
    final cubit = context.read<PlanCubit>();
    if (uids.isEmpty || !cubit.guardWrite()) return;
    final rows = _rows(cubit, uids);
    final single = rows.length == 1 ? rows.first : null;
    var current = single == null || single.truckRefid == 0 ? null : single.truckRefid;
    if (single != null && current == null && single.truckName.isNotEmpty) {
      current = cubit.state.trucks.where((t) => t.name.toLowerCase() == single.truckName.trim().toLowerCase()).map((t) => t.id).firstOrNull;
    }
    final options = [
      for (final t in cubit.state.trucks)
        () {
          final e = t.expiry();
          return PickOption<int>(value: t.id, label: t.name, subtitle: _subtitle(e, truck: true), severity: severityOf(e.severity));
        }(),
    ];
    final result = await showPickerSheet<int>(
      context,
      title: rows.length > 1 ? 'Select Truck · ${rows.length} jobs' : 'Select Truck',
      options: options,
      current: current,
      recent: cubit.state.recentTrucks,
      allowClear: true,
      searchHint: 'Search truck...',
    );
    if (result == null || cubit.isClosed) return;
    if (result.cleared) {
      cubit.clearTruck(uids);
    } else if (result.value != null) {
      final picked = cubit.state.trucks.firstWhere((t) => t.id == result.value);
      cubit.assignTruck(uids, picked);
    }
  }

  static Future<void> driver(BuildContext context, Set<int> uids) async {
    final cubit = context.read<PlanCubit>();
    if (uids.isEmpty || !cubit.guardWrite()) return;
    final rows = _rows(cubit, uids);
    // No truck on the row: the driver is typed (the web's free-text cell).
    if (rows.every((r) => !r.hasTruck)) {
      final typed = await typeName(context, title: 'Driver', initial: rows.length == 1 ? rows.first.driverName : '');
      if (typed != null && !cubit.isClosed) cubit.typeDriver(uids, typed);
      return;
    }
    final single = rows.length == 1 ? rows.first : null;
    final current = single == null || single.driverRefid == 0 ? null : single.driverRefid;
    final options = [
      for (final d in cubit.state.drivers)
        () {
          final e = d.expiry();
          return PickOption<int>(value: d.id, label: d.name, subtitle: _subtitle(e), severity: severityOf(e.severity));
        }(),
    ];
    if (!context.mounted) return;
    final result = await showPickerSheet<int>(
      context,
      title: rows.length > 1 ? 'Select Driver · ${rows.length} jobs' : 'Select Driver',
      options: options,
      current: current,
      recent: cubit.state.recentDrivers,
      allowClear: true,
      // the OUTSIDE DRIVER truck takes a typed name as well as the list
      allowTyped: rows.any((r) => r.isOutsideDriverTruck),
      searchHint: 'Search driver...',
    );
    if (result == null || cubit.isClosed) return;
    if (result.cleared) {
      cubit.clearDriver(uids);
    } else if (result.typed != null) {
      cubit.typeDriver(uids, result.typed!);
    } else if (result.value != null) {
      final picked = cubit.state.drivers.firstWhere((d) => d.id == result.value);
      if (picked.isOutsideDriver) {
        if (!context.mounted) return;
        final name = await typeName(context, title: 'Outside Driver', required: true);
        if (name == null || cubit.isClosed) return;
        cubit.assignDriver(uids, picked, outsideName: name);
      } else {
        cubit.assignDriver(uids, picked);
      }
    }
  }

  /// A name box ("Driver name..."). With [required], an empty name says "Enter outside driver name".
  static Future<String?> typeName(BuildContext context, {required String title, String initial = '', bool required = false}) {
    final controller = TextEditingController(text: initial);
    return showDialog<String>(
      context: context,
      useRootNavigator: true,
      builder: (ctx) {
        void done() {
          final v = controller.text.trim();
          if (required && v.isEmpty) {
            showSnack(context, 'Enter outside driver name', kind: SnackKind.error);
            return;
          }
          Navigator.of(ctx).pop(v);
        }

        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            autofocus: true,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(hintText: 'Driver name...'),
            onSubmitted: (_) => done(),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(required ? 'Back' : 'Cancel')),
            FilledButton(onPressed: done, child: const Text('OK')),
          ],
        );
      },
    );
  }
}
