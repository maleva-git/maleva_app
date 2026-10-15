import 'package:flutter/material.dart';
import 'package:maleva/core/colors/colors.dart' as colour;
import 'package:maleva/core/di/injection.dart';
import 'package:maleva/core/end_customer/end_customer_api.dart';
import 'package:maleva/core/theme/app_typography.dart';
import 'package:maleva/core/widgets/ui/ui.dart';

/// The sale order's End Customer: the customer's own customers, filtered as you type, and "Add"
/// for a name not in the list (the server links an existing record of that name instead of a copy).
/// Resolves to the chosen end customer, or null when closed.
Future<EndCustomer?> showEndCustomerSheet(
  BuildContext context, {
  required int customerId,
  required String customerName,
  EndCustomerApi? api,
}) =>
    showModalBottomSheet<EndCustomer>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
        child: SizedBox(
          height: MediaQuery.sizeOf(ctx).height * 0.7,
          child: MalevaThemeScope(
            child: _EndCustomerPicker(api: api ?? sl<EndCustomerApi>(), customerId: customerId, customerName: customerName),
          ),
        ),
      ),
    );

class _EndCustomerPicker extends StatefulWidget {
  const _EndCustomerPicker({required this.api, required this.customerId, required this.customerName});

  final EndCustomerApi api;
  final int customerId;
  final String customerName;

  @override
  State<_EndCustomerPicker> createState() => _EndCustomerPickerState();
}

class _EndCustomerPickerState extends State<_EndCustomerPicker> {
  final TextEditingController _typed = TextEditingController();
  late Future<List<EndCustomer>> _list = widget.api.forCustomer(widget.customerId);
  bool _adding = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _typed.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _typed.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    final name = _typed.text.trim();
    if (name.isEmpty || _adding) return;
    setState(() {
      _adding = true;
      _error = null;
    });
    try {
      final added = await widget.api.quickAdd(widget.customerId, name);
      if (mounted) Navigator.of(context).pop(added);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _adding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final term = _typed.text.trim().toLowerCase();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('End Customer', style: AppTypography.heading2(color: colour.textMain)),
        Text('Customers of ${widget.customerName}', style: AppTypography.bodySmall(color: colour.textSub)),
        const SizedBox(height: 12),
        TextField(
          controller: _typed,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            hintText: 'Search or type a new name',
            prefixIcon: const Icon(Icons.search_rounded),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        if (_error != null)
          Padding(padding: const EdgeInsets.only(top: 8), child: Text(_error!, style: AppTypography.bodySmall(color: Colors.red))),
        const SizedBox(height: 8),
        Expanded(
          child: FutureBuilder<List<EndCustomer>>(
            future: _list,
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
              if (snap.hasError) {
                return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(snap.error.toString(), textAlign: TextAlign.center, style: AppTypography.bodySmall(color: Colors.red)),
                  TextButton(
                    onPressed: () => setState(() => _list = widget.api.forCustomer(widget.customerId)),
                    child: const Text('Retry'),
                  ),
                ]));
              }
              final rows = (snap.data ?? const <EndCustomer>[]).where((e) => e.name.toLowerCase().contains(term)).toList();
              final exact = rows.any((e) => e.name.toLowerCase() == term);
              return ListView(children: [
                for (final row in rows)
                  ListTile(
                    leading: const Icon(Icons.apartment_rounded, color: colour.brand),
                    title: Text(row.name, style: AppTypography.bodyLarge(color: colour.textMain)),
                    onTap: () => Navigator.of(context).pop(row),
                  ),
                if (rows.isEmpty && term.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('No end customers yet. Type a name to add one.',
                        textAlign: TextAlign.center, style: AppTypography.bodySmall(color: colour.textSub)),
                  ),
                if (term.isNotEmpty && !exact)
                  ListTile(
                    leading: _adding
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.add_circle_outline_rounded, color: colour.brand),
                    title: Text('Add "${_typed.text.trim()}"', style: AppTypography.bodyLarge(color: colour.brand)),
                    onTap: _add,
                  ),
              ]);
            },
          ),
        ),
      ]),
    );
  }
}
