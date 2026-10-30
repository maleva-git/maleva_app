import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:maleva/core/files/attachments_api.dart';
import 'package:maleva/core/theme/app_typography.dart';
import 'package:maleva/core/theme/palette.dart';
import 'package:maleva/core/theme/tokens.dart';
import 'package:maleva/core/utils/app_preferences.dart';
import 'package:maleva/core/widgets/ui/formats.dart';

import '../../bill/view/bill_form_page.dart' show CarriedFile;
import '../../po/data/po_draft.dart';
import '../../po/view/form_parts.dart';
import '../../po/view/po_pickers.dart';
import '../../records/data/payable_record.dart';
import '../../records/view/record_style.dart';
import '../../voucher/data/voucher_draft.dart' show voucherDefaultHeads;
import '../data/paybill_api.dart';
import '../data/paybill_draft.dart';

/// Pay a supplier's bills on the phone (change `payable-paybill-form`): 1 Supplier · 2 Bills · 3 Check & save.
/// The supplier's open bills load with their balances; the person puts an amount on each (or Pay all).
/// [fromBillId] = "Pay this bill": that bill's supplier is chosen and the bill gets its full balance.
class PayBillFormPage extends StatefulWidget {
  const PayBillFormPage({super.key, required this.api, this.files, this.editId, this.fromBillId, this.pickPhoto, this.employeeId});

  final PayBillApi api;
  final AttachmentsApi? files;
  final int? editId;
  final int? fromBillId;
  final PhotoPicker? pickPhoto;
  final int? employeeId;

  @override
  State<PayBillFormPage> createState() => _PayBillFormPageState();
}

class _PayBillFormPageState extends State<PayBillFormPage> {
  PayBillDraft _d = PayBillDraft();
  int _step = 0;
  bool _loading = true;
  bool _loadingBills = false;
  String? _loadError;
  String? _billsError;
  bool _saving = false;
  final List<File> _photos = [];
  List<CarriedFile> _carried = [];
  String _carriedFor = '';

  List<Option> _suppliers = const [];
  List<Option> _banks = const [];
  final List<String> _lookupErrors = [];

  final _ref = TextEditingController();
  final _payTo = TextEditingController();
  final _remarks = TextEditingController();
  final _charges = TextEditingController();

  PhotoPicker get _pick => widget.pickPhoto ?? defaultPhotoPicker;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _ref.dispose();
    _payTo.dispose();
    _remarks.dispose();
    _charges.dispose();
    super.dispose();
  }

  Future<T> _safe<T>(String what, Future<T> Function() call, T fallback) async {
    try {
      return await call();
    } catch (e) {
      _lookupErrors.add('$what: $e');
      return fallback;
    }
  }

  Future<void> _load() async {
    final api = widget.api;
    final r = await Future.wait<Object>([
      _safe('Suppliers', api.po.suppliers, const <Option>[]),
      _safe('Banks', api.banks, const <Option>[]),
      widget.editId == null ? _safe('Payment number', api.nextNumber, '') : Future.value(''),
    ]);
    _suppliers = r[0] as List<Option>;
    _banks = r[1] as List<Option>;
    var d = PayBillDraft(number: r[2] as String);
    String? error;
    try {
      if (widget.editId != null) {
        d = PayBillDraft.fromEdit(await api.load(widget.editId!), suppliers: _suppliers, banks: _banks);
      }
    } catch (e) {
      error = '$e';
    }
    if (!mounted) return;
    setState(() {
      _d = d;
      _loadError = error;
      _loading = false;
      _syncText();
    });
    if (widget.fromBillId != null && error == null) {
      final supplierId = await _safe('Bill', () => api.supplierOfBill(widget.fromBillId!), 0);
      Option? s;
      for (final o in _suppliers) {
        if (o.id == supplierId) s = o;
      }
      if (supplierId > 0) {
        await _chooseSupplier(s ?? Option(supplierId, '#$supplierId'));
        if (!mounted) return;
        setState(() {
          for (final row in _d.rows) {
            if (row.billMasterRefId == widget.fromBillId && row.balance > 0) row.amount = row.balance;
          }
          _step = 1;
        });
      }
    }
  }

  void _syncText() {
    _ref.text = _d.refNo;
    _payTo.text = _d.payTo;
    _remarks.text = _d.remarks;
    _charges.text = _d.bankCharges == 0 ? '' : '${_d.bankCharges}';
  }

  void _readText() {
    _d.refNo = _ref.text;
    _d.payTo = _payTo.text;
    _d.remarks = _remarks.text;
    _d.bankCharges = double.tryParse(_charges.text.replaceAll(',', '').trim()) ?? 0;
  }

  /// A new supplier: their open bills (no amounts yet) and their bank and tax details.
  Future<void> _chooseSupplier(Option s) async {
    _readText();
    setState(() {
      _d.supplier = s;
      _d.rows = [];
      _loadingBills = true;
      _billsError = null;
    });
    try {
      final rows = await widget.api.supplierBills(s.id, excludePaymentId: _d.id);
      final bank = await _safe('Supplier bank', () => widget.api.supplierBank(s.id), null);
      if (!mounted) return;
      setState(() {
        _d.rows = rows;
        if (bank != null) {
          _d
            ..bankName = bank.bankName
            ..accountNo = bank.accountNo
            ..tinNo = bank.tinNo
            ..sstNo = bank.sstNo
            ..msicCode = bank.msicCode
            ..serviceTaxType = bank.serviceTaxType;
        }
      });
    } catch (e) {
      if (mounted) setState(() => _billsError = '$e');
    } finally {
      if (mounted) setState(() => _loadingBills = false);
    }
  }

  /// The bills paid bring their files (new pay bill only, as on the web).
  Future<void> _loadCarried() async {
    final files = widget.files;
    if (files == null || !_d.isNew) return;
    final ids = [for (final r in _d.selected) if (r.billMasterRefId != null) r.billMasterRefId!];
    final key = ids.join(',');
    if (key == _carriedFor) return;
    _carriedFor = key;
    final out = <CarriedFile>[];
    for (final id in ids) {
      final rows = await _safe('Bill files', () => files.list(folder: 'BillMaster', recordId: id), const <Map<String, dynamic>>[]);
      out.addAll([for (final m in rows) CarriedFile(RecordFile.fromJava(m))]);
    }
    if (mounted) setState(() => _carried = out);
  }

  void _goTo(int step) {
    _readText();
    setState(() => _step = step);
    if (step == 2) _loadCarried();
  }

  Future<void> _save() async {
    _readText();
    final problems = _d.problems();
    if (problems.isNotEmpty) {
      await showDialog<void>(
        context: context,
        builder: (c) => AlertDialog(
          title: const Text('Please check'),
          content: InfoBanner(color: Palette.redDanger, lines: problems),
          actions: [FilledButton(onPressed: () => Navigator.pop(c), child: const Text('OK'))],
        ),
      );
      return;
    }
    final keep = _carried.where((c) => c.keep).toList();
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(_d.isNew ? 'Save this payment?' : 'Update ${_d.number}?'),
        content: Text(_d.isNew
            ? 'Pays ${Fmt.rm(_d.total)} to ${_d.supplier?.name ?? ''} across ${_d.selected.length} bill(s) from ${_d.bank?.name ?? ''}.'
            : 'Replaces what ${_d.number} pays with ${Fmt.rm(_d.total)} across ${_d.selected.length} bill(s).'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          FilledButton(key: const ValueKey('pb-confirm'), onPressed: () => Navigator.pop(c, true), child: const Text('Save')),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => _saving = true);
    try {
      final saved = await widget.api.save(_d.toJson(employeeId: widget.employeeId ?? AppPreferences.getEmpRefId()));
      if (!mounted) return;
      if (saved.duplicate) {
        await showDialog<void>(
          context: context,
          builder: (c) => AlertDialog(
            title: const Text('Already saved'),
            content: Text('This payment was already saved as ${saved.number}. Nothing new was saved.'),
            actions: [FilledButton(onPressed: () => Navigator.pop(c), child: const Text('OK'))],
          ),
        );
        if (mounted) Navigator.pop(context, true);
        return;
      }
      String? fileError;
      final files = widget.files;
      if (files != null) {
        try {
          if (keep.isNotEmpty) await files.copyFrom([for (final c in keep) c.file.path], folder: 'PayBills', recordId: saved.id);
          if (_photos.isNotEmpty) await files.add(_photos, folder: 'PayBills', recordId: saved.id);
        } catch (e) {
          fileError = '$e';
        }
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(fileError == null
              ? 'Saved ${saved.number}'
              : 'Saved ${saved.number}, but the files did not upload: $fileError. Add them on the web.')));
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Not saved: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.editId != null ? 'Edit ${_d.number}' : 'Pay bills';
    return Scaffold(
      backgroundColor: AppTokens.surfacePage,
      appBar: AppBar(
        backgroundColor: AppTokens.brandGradientStart,
        foregroundColor: AppTokens.textOnDark,
        title: Text(title, style: AppTypography.bodyLarge(color: AppTokens.textOnDark, fontWeight: FontWeight.w700)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _loadError != null
              ? Center(
                  child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(_loadError!, textAlign: TextAlign.center, style: AppTypography.bodyMedium(color: Palette.redDanger))))
              : Column(children: [
                  StepHeader(step: _step, names: const ['Supplier', 'Bills', 'Check & save'], onTap: _goTo),
                  Expanded(
                    child: ListView(padding: const EdgeInsets.fromLTRB(12, 8, 12, 24), children: [
                      if (_lookupErrors.isNotEmpty) InfoBanner(color: Palette.amberGold, lines: _lookupErrors),
                      ...switch (_step) { 0 => _stepSupplier(), 1 => _stepBills(), _ => _stepCheck() },
                    ]),
                  ),
                  _bottomBar(),
                ]),
    );
  }

  InputDecoration _dec(String label, {IconData? icon}) => InputDecoration(
      labelText: label,
      isDense: true,
      prefixIcon: icon == null ? null : Icon(icon, size: 20),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)));

  List<Widget> _stepSupplier() => [
        Panel(
          title: 'Supplier',
          icon: Icons.storefront_outlined,
          child: Column(children: [
            PickField(
              key: const ValueKey('pb-supplier'),
              label: 'Supplier',
              required: true,
              value: _d.supplier?.name,
              icon: Icons.storefront_outlined,
              onTap: () async {
                final s = await pickOption(context, title: 'Supplier', options: _suppliers, selected: _d.supplier);
                if (s != null) await _chooseSupplier(s);
              },
            ),
            if (_d.supplier != null && (_d.bankName.isNotEmpty || _d.accountNo.isNotEmpty))
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppTokens.surfacePage, borderRadius: BorderRadius.circular(10)),
                child: Text('Their bank: ${_d.bankName}  ${_d.accountNo}', style: AppTypography.bodySmall(color: AppTokens.textPrimary)),
              ),
            TextField(key: const ValueKey('pb-payto'), controller: _payTo, textCapitalization: TextCapitalization.characters, decoration: _dec('Pay to', icon: Icons.person_outline)),
          ]),
        ),
        const SizedBox(height: 12),
        Panel(
          title: 'Payment',
          icon: Icons.account_balance_outlined,
          child: Column(children: [
            PickField(
              key: const ValueKey('pb-bank'),
              label: 'Payment by (bank)',
              required: true,
              value: _d.bank?.name,
              icon: Icons.account_balance_outlined,
              onTap: () async {
                final b = await pickOption(context, title: 'Payment by', options: _banks, selected: _d.bank);
                if (b != null) setState(() => _d.bank = b);
              },
            ),
            DateField(
                label: 'Payment date',
                value: _d.date,
                onTap: () async {
                  final v = await showDatePicker(
                      context: context, initialDate: _d.date, firstDate: DateTime(2015), lastDate: DateTime(Fmt.today().year + 1));
                  if (v != null) setState(() => _d.date = v);
                }),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: TextField(key: const ValueKey('pb-ref'), controller: _ref, decoration: _dec('Reference no. *'))),
              const SizedBox(width: 8),
              Expanded(
                  child: TextField(
                      key: const ValueKey('pb-charges'),
                      controller: _charges,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: _dec('Bank charges'))),
            ]),
          ]),
        ),
        const SizedBox(height: 12),
        Panel(
          title: 'Description *',
          icon: Icons.category_outlined,
          child: TextPickField(
            key: const ValueKey('pb-desc'),
            label: 'Description',
            required: true,
            value: _d.description,
            options: voucherDefaultHeads,
            onChanged: (x) => setState(() => _d.description = x),
          ),
        ),
        const SizedBox(height: 12),
        Panel(
          title: 'Status',
          icon: Icons.flag_outlined,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            TextPickField(
              key: const ValueKey('pb-status'),
              label: 'Status',
              icon: Icons.flag_outlined,
              value: _d.status,
              options: payBillStatuses,
              labelOf: statusLabel,
              onChanged: (s) => setState(() => _d.status = s),
            ),
            Material(
              type: MaterialType.transparency,
              child: SwitchListTile(
                key: const ValueKey('pb-send-voucher'),
                contentPadding: EdgeInsets.zero,
                value: _d.sendToVoucher,
                onChanged: (v) => setState(() => _d.sendToVoucher = v),
                title: const Text('Send for approval (to the voucher queue)'),
              ),
            ),
            TextField(controller: _remarks, maxLines: 2, decoration: _dec('Remarks')),
          ]),
        ),
      ];

  List<Widget> _stepBills() {
    if (_d.supplier == null) {
      return [Panel(child: Text('Choose the supplier first.', style: AppTypography.bodyMedium(color: AppTokens.textMuted)))];
    }
    return [
      Panel(
        title: 'Open bills of ${_d.supplier!.name}',
        icon: Icons.receipt_long_outlined,
        trailing: _d.rows.isEmpty
            ? null
            : TextButton(key: const ValueKey('pb-pay-all'), onPressed: () => setState(_d.payAll), child: const Text('Pay all')),
        child: _loadingBills
            ? const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator()))
            : _billsError != null
                ? Row(children: [
                    Expanded(child: Text(_billsError!, style: AppTypography.bodySmall(color: Palette.redDanger))),
                    TextButton(onPressed: () => _chooseSupplier(_d.supplier!), child: const Text('Retry')),
                  ])
                : _d.rows.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text('Nothing open: this supplier is fully paid.', style: AppTypography.bodySmall(color: AppTokens.textMuted)))
                    : Material(
                        type: MaterialType.transparency,
                        child: Column(children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text('Owed ${Fmt.rm(_d.outstanding)} · tap a bill to put an amount',
                                style: AppTypography.bodySmall(color: AppTokens.textMuted)),
                          ),
                          for (var i = 0; i < _d.rows.length; i++) _rowTile(i),
                        ]),
                      ),
      ),
      const SizedBox(height: 12),
      TotalsCard(total: _d.total, tax: 0),
    ];
  }

  Widget _rowTile(int i) {
    final r = _d.rows[i];
    final on = r.amount != 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: on ? AppTokens.brandLight : AppTokens.surfacePage,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: r.overpaid ? Palette.redDanger : (on ? AppTokens.brandPrimary : AppTokens.surfaceBorder))),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          key: ValueKey('pb-row-$i'),
          onTap: () => _editRow(i),
          leading: Icon(on ? Icons.check_circle : Icons.radio_button_unchecked, color: on ? AppTokens.brandPrimary : AppTokens.textMuted),
          title: Text([r.label, if (r.invoiceNo.isNotEmpty && r.invoiceNo != r.label) 'Inv ${r.invoiceNo}'].join(' · '),
              style: AppTypography.bodyMedium(color: AppTokens.textPrimary, fontWeight: FontWeight.w600)),
          subtitle: Text(
              [
                if (readDate(r.billDate) != null) Fmt.ddMMyyyy(readDate(r.billDate)),
                'balance ${Fmt.rm(r.balance)}',
                if (r.paid > 0) 'paid ${Fmt.rm(r.paid)}',
              ].join(' · '),
              style: AppTypography.bodySmall(color: r.overpaid ? Palette.redDanger : AppTokens.textMuted)),
          trailing: Text(on ? Fmt.rm(r.amount) : '-',
              style: AppTypography.bodyMedium(color: AppTokens.textPrimary, fontWeight: FontWeight.w800)),
        ),
      ),
    );
  }

  Future<void> _editRow(int i) async {
    final r = _d.rows[i];
    final value = await showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppTokens.surfaceCard,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
      builder: (_) => _AmountSheet(row: r),
    );
    if (value != null) setState(() => r.amount = (value * 100).roundToDouble() / 100);
  }

  List<Widget> _stepCheck() {
    _readText();
    final problems = _d.problems();
    return [
      Panel(
        title: 'Check',
        icon: Icons.fact_check_outlined,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          KeyValueLine('Payment no.', _d.number.isEmpty ? 'New' : _d.number),
          KeyValueLine('Supplier', _d.supplier?.name ?? '-'),
          KeyValueLine('Payment by', _d.bank?.name ?? '-'),
          KeyValueLine('Date', Fmt.ddMMyyyy(_d.date)),
          KeyValueLine('Reference', _d.refNo.trim().isEmpty ? '-' : _d.refNo.trim()),
          KeyValueLine('Description', _d.description.isEmpty ? '-' : _d.description),
          KeyValueLine('Status', statusLabel(_d.status)),
          for (final r in _d.selected) KeyValueLine(r.label, Fmt.rm(r.amount)),
          const Divider(),
          Row(children: [
            Expanded(child: Text('Total', style: AppTypography.bodyLarge(color: AppTokens.textPrimary, fontWeight: FontWeight.w800))),
            Text(Fmt.rm(_d.total), style: AppTypography.heading3(color: AppTokens.textPrimary)),
          ]),
        ]),
      ),
      if (problems.isNotEmpty) ...[const SizedBox(height: 12), InfoBanner(color: Palette.redDanger, lines: problems)],
      if (_carried.isNotEmpty) ...[
        const SizedBox(height: 12),
        Panel(
          title: 'Files from the bills',
          icon: Icons.drive_file_move_outline,
          trailing: SoftChip(text: '${_carried.where((c) => c.keep).length}/${_carried.length}'),
          child: Material(
            type: MaterialType.transparency,
            child: Column(children: [
              for (final c in _carried)
                CheckboxListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  value: c.keep,
                  onChanged: (v) => setState(() => c.keep = v ?? false),
                  title: Text(c.file.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                  secondary: Icon(c.file.isImage ? Icons.image_outlined : Icons.picture_as_pdf_outlined),
                ),
            ]),
          ),
        ),
      ],
      const SizedBox(height: 12),
      Panel(
        title: 'Photos (transfer slip)',
        icon: Icons.photo_library_outlined,
        trailing: SoftChip(text: '${_photos.length}'),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (var i = 0; i < _photos.length; i++)
              Stack(children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(_photos[i], width: 84, height: 84, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(width: 84, height: 84, color: AppTokens.surfaceChip, child: const Icon(Icons.image_outlined))),
                ),
                Positioned(
                  right: 2,
                  top: 2,
                  child: InkWell(
                    onTap: () => setState(() => _photos.removeAt(i)),
                    child: const CircleAvatar(radius: 11, backgroundColor: Colors.black54, child: Icon(Icons.close, size: 14, color: Colors.white)),
                  ),
                ),
              ]),
          ]),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: [
            OutlinedButton.icon(
                key: const ValueKey('pb-photo-camera'),
                onPressed: () async {
                  final f = await _pick(ImageSource.camera);
                  if (f != null && mounted) setState(() => _photos.add(f));
                },
                icon: const Icon(Icons.photo_camera_outlined, size: 18),
                label: const Text('Camera')),
            OutlinedButton.icon(
                onPressed: () async {
                  final f = await _pick(ImageSource.gallery);
                  if (f != null && mounted) setState(() => _photos.add(f));
                },
                icon: const Icon(Icons.photo_library_outlined, size: 18),
                label: const Text('Gallery')),
          ]),
        ]),
      ),
    ];
  }

  Widget _bottomBar() => SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          decoration: const BoxDecoration(color: AppTokens.surfaceCard, border: Border(top: BorderSide(color: AppTokens.surfaceBorder))),
          child: Row(children: [
            if (_step > 0) OutlinedButton(key: const ValueKey('pb-back'), onPressed: () => _goTo(_step - 1), child: const Text('Back')),
            const SizedBox(width: 8),
            Expanded(
              child: Text(Fmt.rm(_d.total),
                  textAlign: TextAlign.center, style: AppTypography.bodyLarge(color: AppTokens.textPrimary, fontWeight: FontWeight.w800)),
            ),
            const SizedBox(width: 8),
            _step < 2
                ? FilledButton(key: const ValueKey('pb-next'), onPressed: () => _goTo(_step + 1), child: const Text('Next'))
                : FilledButton.icon(
                    key: const ValueKey('pb-save'),
                    onPressed: _saving ? null : _save,
                    icon: _saving
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.save_outlined),
                    label: const Text('Save')),
          ]),
        ),
      );
}


/// The amount to pay on one open document (owns its text box, freed when the sheet is gone).
class _AmountSheet extends StatefulWidget {
  const _AmountSheet({required this.row});

  final PayRow row;

  @override
  State<_AmountSheet> createState() => _AmountSheetState();
}

class _AmountSheetState extends State<_AmountSheet> {
  late final _ctrl = TextEditingController(text: widget.row.amount == 0 ? '' : '${widget.row.amount}');

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.row;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.viewInsetsOf(context).bottom),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('Pay ${r.label}', style: AppTypography.heading3(color: AppTokens.textPrimary)),
        Text('Balance ${Fmt.rm(r.balance)}', style: AppTypography.bodySmall(color: AppTokens.textMuted)),
        const SizedBox(height: 12),
        TextField(
          key: const ValueKey('pb-row-amount'),
          controller: _ctrl,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
              labelText: 'Amount (RM)', isDense: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
        ),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
              child: OutlinedButton(
                  key: const ValueKey('pb-row-clear'), onPressed: () => Navigator.pop(context, 0.0), child: const Text('Not paying'))),
          const SizedBox(width: 8),
          Expanded(
              child: OutlinedButton(
                  key: const ValueKey('pb-row-full'), onPressed: () => Navigator.pop(context, r.balance), child: const Text('Full balance'))),
          const SizedBox(width: 8),
          Expanded(
              child: FilledButton(
                  key: const ValueKey('pb-row-done'),
                  onPressed: () => Navigator.pop(context, double.tryParse(_ctrl.text.replaceAll(',', '').trim()) ?? 0),
                  child: const Text('Done'))),
        ]),
      ]),
    );
  }
}
