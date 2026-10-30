import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:maleva/core/theme/app_typography.dart';
import 'package:maleva/core/theme/tokens.dart';
import 'package:maleva/core/widgets/ui/formats.dart';

import '../data/po_draft.dart';
import 'po_pickers.dart';

/// Parts shared by the payable forms (PO, bill…; changes `payable-po-create`, `payable-bill-form`).

/// Picks one photo from the camera or the gallery (tests give their own).
typedef PhotoPicker = Future<File?> Function(ImageSource source);

Future<File?> defaultPhotoPicker(ImageSource source) async {
  final x = await ImagePicker().pickImage(source: source, imageQuality: 85, maxWidth: 2400);
  return x == null ? null : File(x.path);
}

class StepHeader extends StatelessWidget {
  const StepHeader(
      {super.key, required this.step, required this.onTap, this.names = const ['Supplier', 'Items', 'Check & save']});

  final int step;
  final ValueChanged<int> onTap;
  final List<String> names;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTokens.surfaceCard,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      // each step shrinks (its name gets "…") rather than overflow a narrow phone
      child: Row(children: [
        for (var i = 0; i < names.length; i++) ...[
          if (i > 0)
            Container(width: 12, height: 2, color: i <= step ? AppTokens.brandPrimary : AppTokens.surfaceBorder),
          Expanded(
            child: InkWell(
              key: ValueKey('step-$i'),
              onTap: () => onTap(i),
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  CircleAvatar(
                    radius: 11,
                    backgroundColor: i <= step ? AppTokens.brandPrimary : AppTokens.surfaceBorder,
                    child: i < step
                        ? const Icon(Icons.check, size: 13, color: Colors.white)
                        : Text('${i + 1}',
                            style: AppTypography.badgeText(color: i <= step ? Colors.white : AppTokens.textMuted)),
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(names[i],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodySmall(
                            color: i == step ? AppTokens.brandPrimary : AppTokens.textMuted,
                            fontWeight: i == step ? FontWeight.w700 : FontWeight.w500)),
                  ),
                ]),
              ),
            ),
          ),
        ],
      ]),
    );
  }
}

class DateField extends StatelessWidget {
  const DateField({super.key, required this.label, required this.value, required this.onTap});

  final String label;
  final DateTime? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            isDense: true,
            prefixIcon: const Icon(Icons.event, size: 18),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(value == null ? '-' : Fmt.ddMMyyyy(value),
              style: AppTypography.bodyMedium(color: AppTokens.textPrimary)),
        ),
      );
}

class InfoBanner extends StatelessWidget {
  const InfoBanner({super.key, required this.color, required this.lines});

  final Color color;
  final List<String> lines;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(10)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          for (final l in lines)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(Icons.info_outline, size: 15, color: color),
                const SizedBox(width: 6),
                Expanded(child: Text(l, style: AppTypography.bodySmall(color: color, fontWeight: FontWeight.w600))),
              ]),
            ),
        ]),
      );
}

class KeyValueLine extends StatelessWidget {
  const KeyValueLine(this.label, this.value, {super.key});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(width: 100, child: Text(label, style: AppTypography.bodySmall(color: AppTokens.textMuted))),
          Expanded(
              child: Text(value,
                  style: AppTypography.bodyMedium(color: AppTokens.textPrimary, fontWeight: FontWeight.w600))),
        ]),
      );
}

class TotalsCard extends StatelessWidget {
  const TotalsCard({super.key, required this.total, required this.tax});

  final double total;
  final double tax;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [AppTokens.brandGradientStart, AppTokens.brandGradientEnd]),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Total', style: AppTypography.bodySmall(color: AppTokens.textOnDark)),
              Text(Fmt.rm(total),
                  key: const ValueKey('po-total'),
                  style: AppTypography.heading2(color: AppTokens.textOnDark, fontWeight: FontWeight.w800)),
            ]),
          ),
          if (tax > 0) Text('incl. tax ${Fmt.rm(tax)}', style: AppTypography.bodySmall(color: AppTokens.textOnDark)),
        ]),
      );
}

/// Add or change one item: account, what it is, qty, rate, tax % → amount.
class LineSheet extends StatefulWidget {
  const LineSheet({super.key, required this.line, required this.accounts});

  final PoLine line;
  final List<Option> accounts;

  @override
  State<LineSheet> createState() => _LineSheetState();
}

class _LineSheetState extends State<LineSheet> {
  late final PoLine l = widget.line;
  late final _qty = TextEditingController(text: _n(l.qty));
  late final _rate = TextEditingController(text: l.rate == 0 ? '' : _n(l.rate));
  late final _tax = TextEditingController(text: l.taxPercent == 0 ? '' : _n(l.taxPercent));
  late final _remarks = TextEditingController(text: l.remarks);

  static String _n(double v) => v % 1 == 0 ? v.toStringAsFixed(0) : '$v';
  static double _p(String t) => double.tryParse(t.replaceAll(',', '').trim()) ?? 0;

  @override
  void dispose() {
    _qty.dispose();
    _rate.dispose();
    _tax.dispose();
    _remarks.dispose();
    super.dispose();
  }

  void _read() {
    l.qty = _p(_qty.text);
    l.rate = _p(_rate.text);
    l.taxPercent = _p(_tax.text);
    l.remarks = _remarks.text;
  }

  InputDecoration _dec(String label) => InputDecoration(
      labelText: label, isDense: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)));

  @override
  Widget build(BuildContext context) {
    _read();
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text('Item', style: AppTypography.heading3(color: AppTokens.textPrimary)),
          const SizedBox(height: 12),
          PickField(
            key: const ValueKey('line-account'),
            label: 'Account',
            required: true,
            value:
                l.account == null ? null : '${l.account!.name}${l.account!.sub.isEmpty ? '' : '  (${l.account!.sub})'}',
            icon: Icons.account_tree_outlined,
            onTap: () async {
              final a = await pickOption(context, title: 'Account', options: widget.accounts, selected: l.account);
              if (a != null) setState(() => l.account = a);
            },
          ),
          TextField(
              key: const ValueKey('line-remarks'),
              controller: _remarks,
              maxLength: 300,
              decoration: _dec('What it is (description)'),
              onChanged: (_) => setState(() {})),
          Row(children: [
            Expanded(
                child: TextField(
                    key: const ValueKey('line-qty'),
                    controller: _qty,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: _dec('Qty'),
                    onChanged: (_) => setState(() {}))),
            const SizedBox(width: 8),
            Expanded(
                flex: 2,
                child: TextField(
                    key: const ValueKey('line-rate'),
                    controller: _rate,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: _dec('Rate (RM)'),
                    onChanged: (_) => setState(() {}))),
            const SizedBox(width: 8),
            Expanded(
                child: TextField(
                    key: const ValueKey('line-tax'),
                    controller: _tax,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: _dec('Tax %'),
                    onChanged: (_) => setState(() {}))),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: Text('Amount', style: AppTypography.bodyMedium(color: AppTokens.textMuted))),
            Text(Fmt.rm(l.amount),
                key: const ValueKey('line-amount'), style: AppTypography.heading3(color: AppTokens.textPrimary)),
          ]),
          const SizedBox(height: 12),
          FilledButton(
            key: const ValueKey('line-done'),
            onPressed: () {
              _read();
              Navigator.pop(context, l);
            },
            child: const Text('Done'),
          ),
        ]),
      ),
    );
  }
}
