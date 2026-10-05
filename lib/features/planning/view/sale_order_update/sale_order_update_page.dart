import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:maleva/core/widgets/ui/ui.dart';
import 'package:maleva/features/planning/bloc/sale_order_update_cubit.dart';
import 'package:maleva/features/planning/data/planning_repository.dart';
import 'package:maleva/features/planning/data/sale_order_update.dart';
import 'package:maleva/features/planning/view/sale_order_update/stop_editor.dart';
import 'package:maleva/features/planning/widgets/date_fields.dart';

/// The Planning "Update" window (`FE/components/modals/UpdateSaleOrderModal.tsx`): full screen
/// on the phone, a side sheet on a tablet. Answers the saved values and the message.
class SaleOrderUpdatePage extends StatelessWidget {
  const SaleOrderUpdatePage({super.key, required this.jobNo});

  final String jobNo;

  static Future<(Map<String, dynamic>, String)?> open(BuildContext context,
      {required int saleOrderId, required String jobNo, PlanningRepository? repo}) {
    final repository = repo ?? GetIt.instance<PlanningRepository>();
    Widget page(BuildContext _) => MalevaThemeScope(
          child: BlocProvider(
            create: (_) => SaleOrderUpdateCubit(repo: repository, saleOrderId: saleOrderId)..load(),
            child: SaleOrderUpdatePage(jobNo: jobNo),
          ),
        );
    if (FormFactor.of(context).isTablet) {
      return showGeneralDialog<(Map<String, dynamic>, String)>(
        context: context,
        useRootNavigator: true,
        barrierDismissible: true,
        barrierLabel: 'Close',
        transitionDuration: const Duration(milliseconds: 220),
        pageBuilder: (ctx, _, __) => Align(
          alignment: Alignment.centerRight,
          child: Material(
            elevation: 8,
            child: SizedBox(
                width: MediaQuery.sizeOf(ctx).width > 1000 ? 720 : MediaQuery.sizeOf(ctx).width * 0.86, height: double.infinity, child: page(ctx)),
          ),
        ),
        transitionBuilder: (ctx, a, _, child) => SlideTransition(
            position: Tween(begin: const Offset(1, 0), end: Offset.zero).animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
            child: child),
      );
    }
    return Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(fullscreenDialog: true, builder: page));
  }

  Future<void> _save(BuildContext context) async {
    final cubit = context.read<SaleOrderUpdateCubit>();
    final refusal = cubit.saveRefusal();
    if (refusal != null) {
      showSnack(context, refusal, kind: SnackKind.error);
      return;
    }
    final ok =
        await showConfirm(context, title: 'Sale Order Update', message: 'Do you Want to Update the Details?', confirmLabel: 'Yes', cancelLabel: 'No');
    if (!ok || cubit.isClosed) return;
    final saved = await cubit.save();
    if (saved != null && context.mounted) Navigator.of(context).pop((saved, cubit.state.message));
  }

  @override
  Widget build(BuildContext context) => BlocConsumer<SaleOrderUpdateCubit, SaleOrderUpdateState>(
        listenWhen: (a, b) => a.messageSeq != b.messageSeq && b.stage != UpdateStage.saved,
        listener: (context, s) => showSnack(context, s.message, kind: SnackKind.error),
        builder: (context, s) {
          final d = s.draft;
          final mc = context.mc;
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(tooltip: 'Close', icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
              title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Sale Order Update'),
                Text(
                  [
                    if (d != null && d.orderNo.isNotEmpty) d.orderNo else (jobNo.isNotEmpty ? jobNo : 'Pending'),
                    if (d != null) d.customerName,
                    if (d != null) '${d.pickups.length} pickup · ${d.deliveries.length} delivery',
                  ].join(' · '),
                  style: TextStyle(fontSize: 14, color: mc.muted, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ]),
            ),
            body: switch (s.stage) {
              UpdateStage.loading => const Center(
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [CircularProgressIndicator(), SizedBox(height: 12), Text('Loading sale order details...')]),
                ),
              UpdateStage.failed => ErrorState(
                  title: 'Unable to load the selected sale order.', message: s.error, onRetry: () => context.read<SaleOrderUpdateCubit>().load()),
              _ => d == null ? const SizedBox.shrink() : _Form(draft: d),
            },
            bottomNavigationBar: s.stage == UpdateStage.ready || s.stage == UpdateStage.saving
                ? StickyActionBar(
                    leading: Text('Saves only the fields on this form. Totals, line items and other job details are not changed.',
                        style: TextStyle(color: mc.muted, fontSize: 14)),
                    actions: [
                      FilledButton.icon(
                        onPressed: s.stage == UpdateStage.saving ? null : () => _save(context),
                        icon: s.stage == UpdateStage.saving
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.save_outlined),
                        label: Text(s.stage == UpdateStage.saving ? 'Saving...' : 'Save All'),
                      ),
                    ],
                  )
                : null,
          );
        },
      );
}

class _Form extends StatelessWidget {
  const _Form({required this.draft});

  final SaleOrderDraft draft;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SaleOrderUpdateCubit>();
    final d = draft;
    final key = d.saleOrderId;
    Widget text(String id, String label, String value, ValueChanged<String> onChanged,
            {String? hint, String? suffix, TextInputType? keyboard, int lines = 1}) =>
        TextFormField(
          key: ValueKey('$key-$id'),
          initialValue: value,
          keyboardType: keyboard,
          minLines: lines,
          maxLines: lines,
          decoration: InputDecoration(labelText: label, hintText: hint, suffixText: suffix),
          onChanged: onChanged,
        );
    final wide = FormFactor.of(context).isTablet;
    final schedule = DetailSection(
      title: 'Job & Schedule',
      icon: Icons.route_outlined,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        KeyValueRow('Job No', d.orderNo),
        KeyValueRow('Customer', d.customerName),
        const SizedBox(height: 8),
        DateTimeField(label: 'Pickup Date', value: d.pickupDate, onChanged: (v) => cubit.edit((x) => x.withPickupDate(v))),
        const SizedBox(height: 10),
        DateTimeField(label: 'Delivery Date', value: d.deliveryDate, onChanged: (v) => cubit.edit((x) => x.withDeliveryDate(v))),
        const SizedBox(height: 10),
        // a typed route clears the picked location, as the web's text boxes do
        text('origin', 'Origin', d.origin, (v) => cubit.edit((x) => x.copyWith(origin: v, originRefId: '')), hint: 'Route origin'),
        const SizedBox(height: 10),
        text('destination', 'Destination', d.destination, (v) => cubit.edit((x) => x.copyWith(destination: v, destinationRefId: '')),
            hint: 'Route destination'),
      ]),
    );
    final cargo = DetailSection(
      title: 'Cargo',
      icon: Icons.inventory_2_outlined,
      child: Row(children: [
        Expanded(child: text('qty', 'Quantity', d.quantity, (v) => cubit.edit((x) => x.copyWith(quantity: v)), suffix: 'PKG')),
        const SizedBox(width: 10),
        Expanded(child: text('weight', 'Total Weight', d.weight, (v) => cubit.edit((x) => x.copyWith(weight: v)), suffix: 'KG')),
      ]),
    );
    final warehouse = DetailSection(
      title: 'Warehouse',
      icon: Icons.warehouse_outlined,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        text('wh', 'Warehouse Address', d.warehouseAddress, (v) => cubit.edit((x) => x.copyWith(warehouseAddress: v)),
            hint: 'Enter warehouse address', lines: 3),
        const SizedBox(height: 10),
        DateTimeField(
            label: 'Enter Date & Time', value: d.warehouseEnterDate, onChanged: (v) => cubit.edit((x) => x.copyWith(warehouseEnterDate: v))),
        const SizedBox(height: 10),
        DateTimeField(label: 'Exit Date & Time', value: d.warehouseExitDate, onChanged: (v) => cubit.edit((x) => x.copyWith(warehouseExitDate: v))),
      ]),
    );
    final pickups = StopEditor(pickup: true, stops: d.pickups);
    final deliveries = StopEditor(pickup: false, stops: d.deliveries);
    const gap = SizedBox(height: 12, width: 12);
    if (!wide) {
      return ListView(padding: const EdgeInsets.all(16), children: [schedule, gap, cargo, gap, warehouse, gap, pickups, gap, deliveries]);
    }
    return ListView(padding: const EdgeInsets.all(16), children: [
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: schedule),
        gap,
        Expanded(child: Column(children: [cargo, gap, warehouse])),
      ]),
      gap,
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: pickups), gap, Expanded(child: deliveries)]),
    ]);
  }
}
