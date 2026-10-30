import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:maleva/core/files/attachments_api.dart';
import 'package:maleva/core/theme/app_typography.dart';
import 'package:maleva/core/theme/palette.dart';
import 'package:maleva/core/theme/tokens.dart';
import 'package:maleva/core/utils/app_preferences.dart';
import 'package:maleva/core/widgets/ui/formats.dart';

import '../../po/data/po_draft.dart';
import '../../po/view/form_parts.dart';
import '../../po/view/po_pickers.dart';
import '../../records/data/payable_record.dart';
import '../../records/view/record_style.dart';
import '../data/bill_ai.dart';
import '../data/bill_api.dart';
import '../data/bill_draft.dart';

/// A purchase order file offered to carry onto the bill (Push to Bill); the person can leave any out.
class CarriedFile {
  CarriedFile(this.file, {this.keep = true});

  final RecordFile file;
  bool keep;
}

/// Create or edit a supplier bill on the phone (change `payable-bill-form`), in three steps like the PO form:
/// 1 Supplier · 2 Items · 3 Check & save. [fromPoId] = Push to Bill: the bill is filled from that purchase order and
/// its files are offered to copy. **Read with AI** fills it from a bill photo; the person checks and saves.
class BillFormPage extends StatefulWidget {
  const BillFormPage(
      {super.key, required this.api, this.files, this.editId, this.fromPoId, this.pickPhoto, this.employeeId});

  final BillApi api;
  final AttachmentsApi? files;
  final int? editId;
  final int? fromPoId;
  final PhotoPicker? pickPhoto;
  final int? employeeId;

  @override
  State<BillFormPage> createState() => _BillFormPageState();
}

class _BillFormPageState extends State<BillFormPage> {
  BillDraft _d = BillDraft();
  int _step = 0;
  bool _loading = true;
  String? _loadError;
  bool _saving = false;
  bool _reading = false;
  bool _aiFilled = false;
  List<String> _aiWarnings = const [];
  List<Option> _aiCandidates = const [];
  final List<File> _photos = [];
  List<CarriedFile> _carried = [];
  double _paid = 0;

  List<Option> _suppliers = const [];
  List<Option> _terms = const [];
  List<Option> _accounts = const [];
  List<Option> _trucks = const [];
  List<Option> _drivers = const [];
  List<String> _descriptions = const [];
  final List<String> _lookupErrors = [];

  final _invoice = TextEditingController();
  final _remarks = TextEditingController();

  PhotoPicker get _pick => widget.pickPhoto ?? defaultPhotoPicker;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _invoice.dispose();
    _remarks.dispose();
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
    final po = widget.api.po;
    final r = await Future.wait<Object>([
      _safe('Suppliers', po.suppliers, const <Option>[]),
      _safe('Payment terms', po.paymentTerms, const <Option>[]),
      _safe('Accounts', po.accounts, const <Option>[]),
      _safe('Trucks', po.trucks, const <Option>[]),
      _safe('Drivers', po.drivers, const <Option>[]),
      _safe('Expense types', po.descriptions, const <String>[]),
      widget.editId == null ? _safe('Bill number', widget.api.nextNumber, '') : Future.value(''),
    ]);
    _suppliers = r[0] as List<Option>;
    _terms = r[1] as List<Option>;
    _accounts = r[2] as List<Option>;
    _trucks = r[3] as List<Option>;
    _drivers = r[4] as List<Option>;
    final desc = r[5] as List<String>;
    _descriptions = desc.isEmpty ? poDefaultDescriptions : desc;
    var d = BillDraft(number: r[6] as String);
    String? error;
    try {
      if (widget.editId != null) {
        d = BillDraft.fromEdit(await widget.api.load(widget.editId!),
            suppliers: _suppliers, trucks: _trucks, drivers: _drivers);
        _paid = await _safe('Paid amount', () => widget.api.paidAmount(widget.editId!), 0.0);
      } else if (widget.fromPoId != null) {
        d = BillDraft.fromPo(await po.load(widget.fromPoId!),
            number: r[6] as String, suppliers: _suppliers, trucks: _trucks, drivers: _drivers);
        // the supplier's current rate replaces the PO's, as on the web
        if (d.supplier != null) {
          d.currencyValue = await _safe('Currency', () => widget.api.supplierCurrency(d.supplier!.id), 0.0);
        }
        if (widget.files != null) {
          final rows = await _safe(
              'PO files',
              () => widget.files!.list(folder: 'BillOrderMaster', recordId: widget.fromPoId!),
              const <Map<String, dynamic>>[]);
          _carried = [for (final m in rows) CarriedFile(RecordFile.fromJava(m))];
        }
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
  }

  void _syncText() {
    _invoice.text = _d.invoiceNo;
    _remarks.text = _d.remarks;
  }

  void _readText() {
    _d.invoiceNo = _invoice.text;
    _d.remarks = _remarks.text;
  }

  // supplier → its term, currency and due date (web useBillSupplierDefaults.ts)
  Future<void> _chooseSupplier(Option s) async {
    setState(() => _d.supplier = s);
    final cv = await _safe('Currency', () => widget.api.supplierCurrency(s.id), 0.0);
    var term = s.extra > 0 ? s.extra : null;
    term ??= await _safe('Supplier term', () => widget.api.po.supplierTerm(s.id), null);
    if (!mounted) return;
    setState(() => _d.currencyValue = cv);
    if (term != null) await _chooseTerm(term);
  }

  Future<void> _chooseTerm(int termId) async {
    setState(() => _d.paymentTermId = termId);
    await _recomputeDue();
  }

  Future<void> _recomputeDue() async {
    final t = _d.paymentTermId;
    if (t == null || t <= 0) return;
    final days = await _safe('Due days', () => widget.api.po.dueDays(t), 0);
    if (!mounted) return;
    setState(() => _d.dueDate = _d.invoiceDate.add(Duration(days: days)));
  }

  Future<DateTime?> _date(DateTime initial) => showDatePicker(
      context: context, initialDate: initial, firstDate: DateTime(2015), lastDate: DateTime(Fmt.today().year + 2));

  Future<void> _readWithAi() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (c) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
              key: const ValueKey('ai-camera'),
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take a photo'),
              onTap: () => Navigator.pop(c, ImageSource.camera)),
          ListTile(
              key: const ValueKey('ai-gallery'),
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose a photo'),
              onTap: () => Navigator.pop(c, ImageSource.gallery)),
        ]),
      ),
    );
    if (source == null) return;
    final file = await _pick(source);
    if (file == null || !mounted) return;
    _readText();
    if (_d.supplier != null || _d.accountLines.isNotEmpty || _d.invoiceNo.trim().isNotEmpty) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          title: const Text('Replace the form?'),
          content: const Text('The AI will fill the form from the photo. What is on the form now will be replaced.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Replace')),
          ],
        ),
      );
      if (ok != true || !mounted) return;
    }
    setState(() => _reading = true);
    try {
      final res = applyBillExtraction(await widget.api.extract(file), _d,
          suppliers: _suppliers, accounts: _accounts, descriptions: _descriptions);
      if (!mounted) return;
      setState(() {
        _d = res.draft;
        _aiFilled = true;
        _aiWarnings = res.warnings;
        _aiCandidates = res.candidates;
        if (!_photos.any((p) => p.path == file.path)) _photos.add(file);
        _syncText();
        _step = 0;
      });
      if (_d.supplier != null) await _chooseSupplier(_d.supplier!);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('AI could not read it: $e')));
    } finally {
      if (mounted) setState(() => _reading = false);
    }
  }

  Future<void> _save() async {
    _readText();
    var used = false;
    if (_d.isNew && _d.invoiceNo.trim().isNotEmpty) {
      used = await _safe('Invoice check', () => widget.api.invoiceExists(_d.invoiceNo), false);
    }
    final problems = _d.problems(invoiceUsed: used, paid: _paid);
    if (problems.isNotEmpty) {
      if (!mounted) return;
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
    if (!mounted) return;
    final keep = _carried.where((c) => c.keep).toList();
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(_d.isNew ? 'Save this bill?' : 'Save the changes?'),
        content: Text([
          _d.supplier?.name ?? '',
          '${Fmt.rm(_d.total)} · ${_d.accountLines.length} items',
          if (_d.poId != null && _d.isNew) 'From PO ${_d.poNumber}: the PO will be marked INVOICE MADE',
          if (_photos.isNotEmpty || keep.isNotEmpty) '${_photos.length + keep.length} files',
        ].where((t) => t.isNotEmpty).join('\n')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          FilledButton(
              key: const ValueKey('bill-confirm'), onPressed: () => Navigator.pop(c, true), child: const Text('Save')),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => _saving = true);
    try {
      final saved = await widget.api.save(
          _d.toJson(companyId: widget.api.companyId, employeeId: widget.employeeId ?? AppPreferences.getEmpRefId()));
      if (!mounted) return;
      if (saved.duplicate) {
        // the server answered the bill already saved with this invoice: nothing new was saved, no files added
        await showDialog<void>(
          context: context,
          builder: (c) => AlertDialog(
            title: const Text('Already saved'),
            content: Text('This bill is already in the system as ${saved.number}. Nothing new was saved.'),
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
          if (keep.isNotEmpty) {
            await files.copyFrom([for (final c in keep) c.file.path], folder: 'BillMaster', recordId: saved.id);
          }
          if (_photos.isNotEmpty) await files.add(_photos, folder: 'BillMaster', recordId: saved.id);
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
    final title = widget.editId != null
        ? 'Edit ${_d.number}'
        : widget.fromPoId != null
            ? 'Bill from ${_d.poNumber.isEmpty ? 'PO' : _d.poNumber}'
            : 'New bill';
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
                  child: Text(_loadError!,
                      textAlign: TextAlign.center, style: AppTypography.bodyMedium(color: Palette.redDanger)),
                ))
              : Column(children: [
                  StepHeader(
                      step: _step,
                      onTap: (i) => setState(() {
                            _readText();
                            _step = i;
                          })),
                  if (_reading) const LinearProgressIndicator(minHeight: 3),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                      children: [
                        if (_lookupErrors.isNotEmpty) InfoBanner(color: Palette.amberGold, lines: _lookupErrors),
                        if (_d.poId != null && _d.isNew)
                          InfoBanner(color: AppTokens.brandPrimary, lines: ['Made from purchase order ${_d.poNumber}']),
                        if (_aiFilled) _aiBanner(),
                        ...switch (_step) { 0 => _stepSupplier(), 1 => _stepItems(), _ => _stepCheck() },
                      ],
                    ),
                  ),
                  _bottomBar(),
                ]),
    );
  }

  Widget _aiBanner() => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: AppTokens.brandLight, borderRadius: BorderRadius.circular(12)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.auto_awesome, size: 18, color: AppTokens.brandPrimary),
            const SizedBox(width: 6),
            Expanded(
                child: Text('Filled by AI: please check every field',
                    style: AppTypography.bodyMedium(color: AppTokens.brandPrimary, fontWeight: FontWeight.w700))),
            InkWell(
                onTap: () => setState(() {
                      _aiFilled = false;
                      _aiWarnings = const [];
                      _aiCandidates = const [];
                    }),
                child: const Icon(Icons.close, size: 18)),
          ]),
          for (final w in _aiWarnings)
            Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('• $w', style: AppTypography.bodySmall(color: AppTokens.textPrimary))),
          if (_aiCandidates.isNotEmpty) ...[
            const SizedBox(height: 6),
            Wrap(spacing: 6, children: [
              for (final c in _aiCandidates)
                ActionChip(
                    label: Text(c.name),
                    onPressed: () {
                      _chooseSupplier(c);
                      setState(() => _aiCandidates = const []);
                    }),
            ]),
          ],
        ]),
      );

  List<Widget> _stepSupplier() {
    final termName = _terms.where((t) => t.id == _d.paymentTermId).map((t) => t.name).firstOrNull ??
        (_d.paymentTermId == null ? null : '#${_d.paymentTermId}');
    return [
      if (_d.isNew && _d.poId == null) ...[
        Material(
          color: AppTokens.surfaceCard,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            key: const ValueKey('bill-ai'),
            borderRadius: BorderRadius.circular(14),
            onTap: _reading ? null : _readWithAi,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTokens.brandPrimary.withValues(alpha: 0.35))),
              child: Row(children: [
                const CircleAvatar(
                    backgroundColor: AppTokens.brandLight,
                    child: Icon(Icons.auto_awesome, color: AppTokens.brandPrimary)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(_reading ? 'Reading…' : 'Read with AI',
                        style: AppTypography.bodyLarge(color: AppTokens.textPrimary, fontWeight: FontWeight.w700)),
                    Text('Photo of the supplier bill fills the form for you',
                        style: AppTypography.bodySmall(color: AppTokens.textMuted)),
                  ]),
                ),
                const Icon(Icons.photo_camera_outlined, color: AppTokens.brandPrimary),
              ]),
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
      Panel(
        title: 'Supplier',
        icon: Icons.storefront_outlined,
        child: Column(children: [
          PickField(
            key: const ValueKey('bill-supplier'),
            label: 'Supplier',
            required: true,
            value: _d.supplier?.name,
            icon: Icons.storefront_outlined,
            onTap: () async {
              final s = await pickOption(context, title: 'Supplier', options: _suppliers, selected: _d.supplier);
              if (s != null) await _chooseSupplier(s);
            },
          ),
          PickField(
            key: const ValueKey('bill-term'),
            label: 'Payment term',
            required: true,
            value: termName,
            icon: Icons.schedule,
            onTap: () async {
              final t = await pickOption(context, title: 'Payment term', options: _terms);
              if (t != null) await _chooseTerm(t.id);
            },
          ),
          TextField(
            key: const ValueKey('bill-invoice'),
            controller: _invoice,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
                labelText: 'Supplier invoice no. *',
                isDense: true,
                prefixIcon: const Icon(Icons.tag, size: 20),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
          ),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
                child: DateField(
                    label: 'Bill date',
                    value: _d.billDate,
                    onTap: () async {
                      final v = await _date(_d.billDate);
                      if (v != null) setState(() => _d.billDate = v);
                    })),
            const SizedBox(width: 8),
            Expanded(
                child: DateField(
                    label: 'Invoice date',
                    value: _d.invoiceDate,
                    onTap: () async {
                      final v = await _date(_d.invoiceDate);
                      if (v != null) {
                        setState(() => _d.invoiceDate = v);
                        await _recomputeDue();
                      }
                    })),
          ]),
          const SizedBox(height: 10),
          DateField(
              label: 'Due date',
              value: _d.dueDate,
              onTap: () async {
                final v = await _date(_d.dueDate ?? _d.invoiceDate);
                if (v != null) setState(() => _d.dueDate = v);
              }),
          const SizedBox(height: 10),
          Wrap(runSpacing: 6, children: [
            for (final t in const ['CREDIT', 'CASH'])
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ChoiceChip(
                    key: ValueKey('saletype-$t'),
                    label: Text(t == 'CASH' ? 'Cash (paid now)' : 'Credit'),
                    selected: _d.saleType == t,
                    onSelected: (_) => setState(() => _d.saleType = t)),
              ),
          ]),
          if (_d.currencyValue != 0 && _d.currencyValue != 1)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text('Supplier currency rate ${_d.currencyValue}',
                  style: AppTypography.bodySmall(color: AppTokens.textMuted)),
            ),
        ]),
      ),
      const SizedBox(height: 12),
      Panel(
        title: 'Expense type *',
        icon: Icons.category_outlined,
        child: TextPickField(
          key: const ValueKey('bill-desc'),
          label: 'Expense type',
          required: true,
          value: _d.description,
          options: _descriptions,
          onChanged: (x) => setState(() => _d.description = x),
        ),
      ),
      const SizedBox(height: 12),
      Panel(
        title: 'More',
        icon: Icons.tune,
        child: Column(children: [
          PickField(
            label: 'Truck',
            value: _d.truck?.name,
            icon: Icons.local_shipping_outlined,
            onTap: () async {
              final t =
                  await pickOption(context, title: 'Truck', options: _trucks, selected: _d.truck, allowClear: true);
              if (t != null) setState(() => _d.truck = t == noneOption ? null : t);
            },
          ),
          PickField(
            label: 'Driver',
            value: _d.driver?.name,
            icon: Icons.badge_outlined,
            onTap: () async {
              final t =
                  await pickOption(context, title: 'Driver', options: _drivers, selected: _d.driver, allowClear: true);
              if (t != null) setState(() => _d.driver = t == noneOption ? null : t);
            },
          ),
          TextPickField(
            key: const ValueKey('bill-status'),
            label: 'Status',
            icon: Icons.flag_outlined,
            value: _d.status,
            options: billStatuses,
            onChanged: (s) => setState(() => _d.status = s),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _remarks,
            maxLines: 2,
            decoration: InputDecoration(
                labelText: 'Remarks',
                isDense: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
          ),
        ]),
      ),
    ];
  }

  List<Widget> _stepItems() => [
        Panel(
          title: 'Items',
          icon: Icons.list_alt_outlined,
          trailing: SoftChip(text: '${_d.accountLines.length}'),
          child: Column(children: [
            if (_d.lines.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text('No items yet. Add what the supplier billed.',
                    style: AppTypography.bodySmall(color: AppTokens.textMuted)),
              ),
            for (var i = 0; i < _d.lines.length; i++) _lineTile(i),
            const SizedBox(height: 6),
            OutlinedButton.icon(
                key: const ValueKey('bill-add-line'),
                onPressed: () => _editLine(null),
                icon: const Icon(Icons.add),
                label: const Text('Add item')),
          ]),
        ),
        const SizedBox(height: 12),
        TotalsCard(total: _d.total, tax: _d.taxTotal),
      ];

  Widget _lineTile(int i) {
    final l = _d.lines[i];
    final noAccount = l.account == null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: AppTokens.surfacePage,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: noAccount ? Palette.redDanger.withValues(alpha: 0.5) : AppTokens.surfaceBorder),
        ),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          key: ValueKey('bill-line-$i'),
          onTap: () => _editLine(i),
          title: Text(noAccount ? 'Choose the account' : l.account!.name,
              style: AppTypography.bodyMedium(
                  color: noAccount ? Palette.redDanger : AppTokens.textPrimary, fontWeight: FontWeight.w600)),
          subtitle: Text(
              [
                if (l.remarks.trim().isNotEmpty) l.remarks.trim(),
                '${l.qty % 1 == 0 ? l.qty.toStringAsFixed(0) : l.qty} × ${Fmt.rm(l.rate)}${l.taxPercent > 0 ? ' + ${l.taxPercent}% tax' : ''}',
              ].join(' · '),
              style: AppTypography.bodySmall(color: AppTokens.textMuted)),
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(Fmt.rm(l.amount),
                style: AppTypography.bodyMedium(color: AppTokens.textPrimary, fontWeight: FontWeight.w700)),
            IconButton(
                tooltip: 'Remove',
                icon: const Icon(Icons.delete_outline, size: 20),
                onPressed: () => setState(() => _d.lines.removeAt(i))),
          ]),
        ),
      ),
    );
  }

  Future<void> _editLine(int? index) async {
    final line = index == null ? PoLine() : _d.lines[index].copy();
    final result = await showModalBottomSheet<PoLine>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppTokens.surfaceCard,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
      builder: (_) => LineSheet(line: line, accounts: _accounts),
    );
    if (result == null) return;
    setState(() => index == null ? _d.lines.add(result) : _d.lines[index] = result);
  }

  List<Widget> _stepCheck() {
    _readText();
    final problems = _d.problems(paid: _paid);
    return [
      Panel(
        title: 'Check',
        icon: Icons.fact_check_outlined,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          KeyValueLine('Bill no.', _d.number.isEmpty ? 'New' : _d.number),
          if (_d.poId != null) KeyValueLine('From PO', _d.poNumber.isEmpty ? '#${_d.poId}' : _d.poNumber),
          KeyValueLine('Supplier', _d.supplier?.name ?? '-'),
          KeyValueLine('Invoice', '${_d.invoiceNo.isEmpty ? '-' : _d.invoiceNo} · ${Fmt.ddMMyyyy(_d.invoiceDate)}'),
          KeyValueLine('Due', _d.dueDate == null ? '-' : Fmt.ddMMyyyy(_d.dueDate)),
          KeyValueLine('Type', '${_d.description.isEmpty ? '-' : _d.description} · ${_d.saleType}'),
          KeyValueLine('Status', _d.status),
          KeyValueLine('Items', '${_d.accountLines.length}'),
          if (_paid > 0) KeyValueLine('Already paid', Fmt.rm(_paid)),
          const Divider(),
          Row(children: [
            Expanded(
                child: Text('Total',
                    style: AppTypography.bodyLarge(color: AppTokens.textPrimary, fontWeight: FontWeight.w800))),
            Text(Fmt.rm(_d.total), style: AppTypography.heading3(color: AppTokens.textPrimary)),
          ]),
        ]),
      ),
      if (problems.isNotEmpty) ...[const SizedBox(height: 12), InfoBanner(color: Palette.redDanger, lines: problems)],
      if (_carried.isNotEmpty) ...[
        const SizedBox(height: 12),
        Panel(
          title: 'Files from the PO',
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
        title: 'Photos',
        icon: Icons.photo_library_outlined,
        trailing: SoftChip(text: '${_photos.length}'),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (var i = 0; i < _photos.length; i++)
              Stack(children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(_photos[i],
                      width: 84,
                      height: 84,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                          width: 84,
                          height: 84,
                          color: AppTokens.surfaceChip,
                          child: const Icon(Icons.image_outlined))),
                ),
                Positioned(
                  right: 2,
                  top: 2,
                  child: InkWell(
                    onTap: () => setState(() => _photos.removeAt(i)),
                    child: const CircleAvatar(
                        radius: 11,
                        backgroundColor: Colors.black54,
                        child: Icon(Icons.close, size: 14, color: Colors.white)),
                  ),
                ),
              ]),
          ]),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: [
            OutlinedButton.icon(
                key: const ValueKey('bill-photo-camera'),
                onPressed: () => _addPhoto(ImageSource.camera),
                icon: const Icon(Icons.photo_camera_outlined, size: 18),
                label: const Text('Camera')),
            OutlinedButton.icon(
                onPressed: () => _addPhoto(ImageSource.gallery),
                icon: const Icon(Icons.photo_library_outlined, size: 18),
                label: const Text('Gallery')),
          ]),
        ]),
      ),
    ];
  }

  Future<void> _addPhoto(ImageSource source) async {
    final f = await _pick(source);
    if (f != null && mounted) setState(() => _photos.add(f));
  }

  Widget _bottomBar() => SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          decoration: const BoxDecoration(
              color: AppTokens.surfaceCard, border: Border(top: BorderSide(color: AppTokens.surfaceBorder))),
          child: Row(children: [
            if (_step > 0)
              OutlinedButton(
                  key: const ValueKey('bill-back'),
                  onPressed: () => setState(() {
                        _readText();
                        _step--;
                      }),
                  child: const Text('Back')),
            const SizedBox(width: 8),
            Expanded(
              child: Text(Fmt.rm(_d.total),
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyLarge(color: AppTokens.textPrimary, fontWeight: FontWeight.w800)),
            ),
            const SizedBox(width: 8),
            _step < 2
                ? FilledButton(
                    key: const ValueKey('bill-next'),
                    onPressed: () => setState(() {
                          _readText();
                          _step++;
                        }),
                    child: const Text('Next'))
                : FilledButton.icon(
                    key: const ValueKey('bill-save'),
                    onPressed: _saving ? null : _save,
                    icon: _saving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.save_outlined),
                    label: const Text('Save')),
          ]),
        ),
      );
}
