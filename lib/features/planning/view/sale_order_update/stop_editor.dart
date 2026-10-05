import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/widgets/ui/ui.dart';
import 'package:maleva/features/planning/bloc/sale_order_update_cubit.dart';
import 'package:maleva/features/planning/data/sale_order_update.dart';
import 'package:maleva/features/planning/widgets/date_fields.dart';

/// Pickup or delivery stops of the Update window (the web's `MultiAddressManager`):
/// address, date & time, weight (kg), quantity; Add and Delete.
class StopEditor extends StatelessWidget {
  const StopEditor({super.key, required this.pickup, required this.stops});

  final bool pickup;
  final List<StopRow> stops;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SaleOrderUpdateCubit>();
    final weight = stops.fold<double>(0, (sum, s) => sum + (double.tryParse(s.weight.trim()) ?? 0));
    final quantity = stops.fold<double>(0, (sum, s) => sum + (double.tryParse(s.quantity.trim()) ?? 0));
    final qtyText = quantity == quantity.truncateToDouble() ? quantity.toInt().toString() : quantity.toString();
    return DetailSection(
      title: pickup ? 'Pickup Addresses' : 'Delivery Addresses',
      icon: pickup ? Icons.north_east : Icons.south_west,
      trailing: TextButton.icon(onPressed: () => cubit.addStop(pickup: pickup), icon: const Icon(Icons.add), label: const Text('Add')),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Wrap(spacing: 8, children: [
          StatusPill('Stops ${stops.length}', tone: pickup ? StatusTone.primary : StatusTone.success, showDot: false),
          StatusPill('${weight.toStringAsFixed(2)} kg', tone: StatusTone.neutral, showDot: false),
          StatusPill('$qtyText pkg', tone: StatusTone.neutral, showDot: false),
        ]),
        const SizedBox(height: 10),
        if (stops.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(children: [
              const Text('No addresses added', style: TextStyle(fontWeight: FontWeight.w700)),
              Text('Add the first stop to continue planning.', style: TextStyle(color: context.mc.muted)),
            ]),
          ),
        for (var i = 0; i < stops.length; i++) _StopCard(index: i, stop: stops[i], pickup: pickup),
      ]),
    );
  }
}

class _StopCard extends StatelessWidget {
  const _StopCard({required this.index, required this.stop, required this.pickup});

  final int index;
  final StopRow stop;
  final bool pickup;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SaleOrderUpdateCubit>();
    void edit(StopRow Function(StopRow) change) => cubit.editStop(stop.key, change, pickup: pickup);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(12, 4, 4, 12),
      decoration: BoxDecoration(color: context.mc.surface2, borderRadius: BorderRadius.circular(14), border: Border.all(color: context.mc.outline)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Expanded(child: Text('Stop ${index + 1}', style: const TextStyle(fontWeight: FontWeight.w800))),
          IconButton(
              tooltip: 'Delete',
              onPressed: () => cubit.removeStop(stop.key, pickup: pickup),
              icon: Icon(Icons.delete_outline, color: context.cs.error)),
        ]),
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            TextFormField(
              key: ValueKey('${stop.key}-address'),
              initialValue: stop.address,
              minLines: 1,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Address', hintText: 'Type or search'),
              onChanged: (v) => edit((s) => s.copyWith(address: v)),
            ),
            const SizedBox(height: 10),
            DateTimeField(
              label: 'Date & Time',
              value: stop.dateRequired ? stop.datetime : '',
              onChanged: (v) => edit((s) => s.copyWith(datetime: v, dateRequired: v.isNotEmpty)),
            ),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(
                child: TextFormField(
                  key: ValueKey('${stop.key}-weight'),
                  initialValue: stop.weight,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Weight (kg)', hintText: '0.00'),
                  onChanged: (v) => edit((s) => s.copyWith(weight: v)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  key: ValueKey('${stop.key}-quantity'),
                  initialValue: stop.quantity,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Quantity', hintText: '0'),
                  onChanged: (v) => edit((s) => s.copyWith(quantity: v)),
                ),
              ),
            ]),
          ]),
        ),
      ]),
    );
  }
}
