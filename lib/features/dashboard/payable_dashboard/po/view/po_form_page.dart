import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:maleva/core/files/attachments_api.dart';
import 'package:maleva/core/theme/app_typography.dart';
import 'package:maleva/core/theme/palette.dart';
import 'package:maleva/core/theme/tokens.dart';
import 'package:maleva/core/utils/app_preferences.dart';
import 'package:maleva/core/widgets/ui/formats.dart';

import '../../records/view/record_style.dart';
import '../data/po_ai.dart';
import '../data/po_api.dart';
import '../data/po_draft.dart';
import 'form_parts.dart';
import 'po_pickers.dart';

/// Create or edit a purchase order on the phone (change `payable-po-create`), in three steps:
/// 1 Supplier · 2 Items · 3 Check & save. **Read with AI** fills it from a photo; the person checks and saves.
/// Answers `true` to the caller when a PO was saved.
class PoFormPage extends StatefulWidget {
  const PoFormPage({super.key, required this.api, this.files, this.editId, this.pickPhoto, this.employeeId});

  final PoApi api;
  final AttachmentsApi? files;

  /// The PO to edit; null = new.
  final int? editId;
  final PhotoPicker? pickPhoto;

  /// The signed-in employee (tests give their own).
  final int? employeeId;

  @override
  State<PoFormPage> createState() => _PoFormPageState();
}

class _PoFormPageState extends State<PoFormPage> {
  PoDraft _d = PoDraft();
  int _step = 0;
  bool _loading = true;
  String? _loadError;
  bool _saving = false;
  bool _reading = false;

  /// The form was filled by the AI: the "please check" banner stays until closed.
  bool _aiFilled = false;
  List<String> _aiWarnings = const [];
  List<Option> _aiCandidates = const [];
  final List<File> _photos = [];

  List<Option> _suppliers = const [];
  List<Option> _terms = const [];
  List<Option> _accounts = const [];
  List<Option> _trucks = const [];
  List<Option> _drivers = const [];
  List<String> _descriptions = const [];
  List<String> _payTos = const [];
  final List<String> _lookupErrors = [];

  final _invoice = TextEditingController();
  final _payTo = TextEditingController();
  final _job = TextEditingController();
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
    _payTo.dispose();
    _job.dispose();
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
    final api = widget.api;
    final r = await Future.wait<Object>([
      _safe('Suppliers', api.suppliers, const <Option>[]),
      _safe('Payment terms', api.paymentTerms, const <Option>[]),
      _safe('Accounts', api.accounts, const <Option>[]),
      _safe('Trucks', api.trucks, const <Option>[]),
      _safe('Drivers', api.drivers, const <Option>[]),
      _safe('Expense types', api.descriptions, const <String>[]),
      _safe('Pay to', api.payTos, const <String>[]),
      widget.editId == null ? _safe('PO number', api.nextNumber, '') : Future.value(''),
    ]);
    _suppliers = r[0] as List<Option>;
    _terms = r[1] as List<Option>;
    _accounts = r[2] as List<Option>;
    _trucks = r[3] as List<Option>;
    _drivers = r[4] as List<Option>;
    final desc = r[5] as List<String>;
    _descriptions = desc.isEmpty ? poDefaultDescriptions : desc;
    _payTos = r[6] as List<String>;
    var d = PoDraft(number: r[7] as String);
    String? error;
    if (widget.editId != null) {
      try {
        d = PoDraft.fromEdit(await api.load(widget.editId!), suppliers: _suppliers, trucks: _trucks, drivers: _drivers);
      } catch (e) {
        error = '$e';
      }
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
    _payTo.text = _d.payTo;
    _job.text = _d.jobNo;
    _remarks.text = _d.remarks;
  }

  void _readText() {
    _d.invoiceNo = _invoice.text;
    _d.payTo = _payTo.text;
    _d.jobNo = _job.text;
    _d.remarks = _remarks.text;
  }

  // ── supplier, term, due date (web hooks/usePurchaseOrderTermAndDueDate.ts) ──

  Future<void> _chooseSupplier(Option s) async {
    setState(() => _d.supplier = s);
    var term = s.extra > 0 ? s.extra : null;
    term ??= await _safe('Supplier term', () => widget.api.supplierTerm(s.id), null);
    if (term != null && mounted) await _chooseTerm(term);
  }

  Future<void> _chooseTerm(int termId) async {
    setState(() => _d.paymentTermId = termId);
    await _recomputeDue();
  }

  Future<void> _recomputeDue() async {
    final t = _d.paymentTermId;
    if (t == null || t <= 0) return;
    final days = await _safe('Due days', () => widget.api.dueDays(t), 0);
    if (!mounted) return;
    setState(() => _d.dueDate = _d.invoiceDate.add(Duration(days: days)));
  }

  Future<DateTime?> _date(DateTime initial) => showDatePicker(
      context: context, initialDate: initial, firstDate: DateTime(2015), lastDate: DateTime(Fmt.today().year + 2));

  // ── AI read ──

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
    if (_d.supplier != null || _d.filledLines.isNotEmpty || _d.invoiceNo.trim().isNotEmpty) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          title: const Text('Replace the form?'),
          content: const Text('The AI will fill the form from the photo. What you typed will be replaced.'),
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
      final ai = await widget.api.extract(file);
      final res = applyPoExtraction(ai, _d,
          suppliers: _suppliers, accounts: _accounts, trucks: _trucks, drivers: _drivers, descriptions: _descriptions);
      if (!mounted) return;
      setState(() {
        _d = res.draft;
        _aiFilled = true;
        _aiWarnings = res.warnings;
        _aiCandidates = res.candidates;
        if (!_photos.any((p) => p.path == file.path)) _photos.add(file); // the read document is kept with the PO
        _syncText();
        _step = 0;
      });
      if (_d.supplier != null && (_d.paymentTermId == null)) await _chooseSupplier(_d.supplier!);
      if (_d.dueDate == null) await _recomputeDue();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('AI could not read it: $e')));
      }
    } finally {
      if (mounted) setState(() => _reading = false);
    }
  }

  // ── save ──

  Future<void> _save() async {
    _readText();
    Set<String> used = const {};
    if (_d.isNew) used = await _safe('Invoice check', widget.api.usedInvoiceNumbers, const <String>{});
    final problems = _d.problems(usedInvoiceNos: used);
    if (problems.isNotEmpty) {
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (c) => AlertDialog(
          title: const Text('Please check'),
          content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            for (final p in problems)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Icon(Icons.error_outline, size: 16, color: Palette.redDanger),
                  const SizedBox(width: 6),
                  Expanded(child: Text(p)),
                ]),
              ),
          ]),
          actions: [FilledButton(onPressed: () => Navigator.pop(c), child: const Text('OK'))],
        ),
      );
      return;
    }
    if (!mounted) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(_d.isNew ? 'Save this purchase order?' : 'Save the changes?'),
        content: Text('${_d.supplier?.name ?? ''}\n${Fmt.rm(_d.total)} · ${_d.filledLines.length} items'
            '${_photos.isEmpty ? '' : ' · ${_photos.length} photos'}'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          FilledButton(
              key: const ValueKey('po-confirm'), onPressed: () => Navigator.pop(c, true), child: const Text('Save')),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => _saving = true);
    try {
      final saved = await widget.api.save(
          _d.toJson(companyId: widget.api.companyId, employeeId: widget.employeeId ?? AppPreferences.getEmpRefId()));
      String? fileError;
      if (_photos.isNotEmpty && widget.files != null) {
        try {
          await widget.files!.add(_photos, folder: 'BillOrderMaster', recordId: saved.id);
        } catch (e) {
          fileError = '$e';
        }
      }
      if (!mounted) return;
      final number = saved.number.isNotEmpty ? saved.number : _d.number;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(fileError == null
              ? 'Saved $number'
              : 'Saved $number, but the photos did not upload: $fileError. Add them on the web.')));
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Not saved: $e')));
      }
    }
  }

  // ── build ──

  @override
  Widget build(BuildContext context) {
    final title = widget.editId == null ? 'New purchase order' : 'Edit ${_d.number}';
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
              : _d.fromJobOrder
                  ? Center(
                      child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text('This PO was raised from a workshop job order. Please edit it on the web.',
                          textAlign: TextAlign.center, style: AppTypography.bodyMedium(color: AppTokens.textPrimary)),
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
      if (widget.editId == null || _d.isNew)
        Material(
          color: AppTokens.surfaceCard,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            key: const ValueKey('po-ai'),
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
                    Text('Photo of the quotation or invoice fills the form for you',
                        style: AppTypography.bodySmall(color: AppTokens.textMuted)),
                  ]),
                ),
                const Icon(Icons.photo_camera_outlined, color: AppTokens.brandPrimary),
              ]),
            ),
          ),
        ),
      const SizedBox(height: 12),
      Panel(
        title: 'Supplier',
        icon: Icons.storefront_outlined,
        child: Column(children: [
          PickField(
            key: const ValueKey('po-supplier'),
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
            key: const ValueKey('po-term'),
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
            key: const ValueKey('po-invoice'),
            controller: _invoice,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
                labelText: 'Invoice / quotation no. *',
                isDense: true,
                prefixIcon: const Icon(Icons.tag, size: 20),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
          ),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
                child: DateField(
                    label: 'PO date',
                    value: _d.poDate,
                    onTap: () async {
                      final v = await _date(_d.poDate);
                      if (v != null) setState(() => _d.poDate = v);
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
        ]),
      ),
      const SizedBox(height: 12),
      Panel(
        title: 'Expense type *',
        icon: Icons.category_outlined,
        child: TextPickField(
          key: const ValueKey('po-desc'),
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
          TextField(
            key: const ValueKey('po-payto'),
            controller: _payTo,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              labelText: 'Pay to',
              isDense: true,
              prefixIcon: const Icon(Icons.person_outline, size: 20),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              suffixIcon: _payTos.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Past names',
                      icon: const Icon(Icons.history),
                      onPressed: () async {
                        final o = await pickOption(context,
                            title: 'Pay to', options: [for (var i = 0; i < _payTos.length; i++) Option(i, _payTos[i])]);
                        if (o != null) setState(() => _payTo.text = o.name);
                      },
                    ),
            ),
          ),
          const SizedBox(height: 10),
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
          TextField(
            controller: _job,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
                labelText: 'Job no.',
                isDense: true,
                prefixIcon: const Icon(Icons.work_outline, size: 20),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
          ),
          const SizedBox(height: 10),
          TextPickField(
            key: const ValueKey('po-status'),
            label: 'Status',
            icon: Icons.flag_outlined,
            value: _d.status,
            options: poStatuses,
            onChanged: (s) => setState(() => _d.status = s),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _remarks,
            maxLines: 2,
            maxLength: 300,
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
          trailing: SoftChip(text: '${_d.filledLines.length}'),
          child: Column(children: [
            if (_d.lines.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text('No items yet. Add what you are buying.',
                    style: AppTypography.bodySmall(color: AppTokens.textMuted)),
              ),
            for (var i = 0; i < _d.lines.length; i++) _lineTile(i),
            const SizedBox(height: 6),
            OutlinedButton.icon(
              key: const ValueKey('po-add-line'),
              onPressed: () => _editLine(null),
              icon: const Icon(Icons.add),
              label: const Text('Add item'),
            ),
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
          key: ValueKey('line-$i'),
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
              onPressed: () => setState(() => _d.lines.removeAt(i)),
            ),
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
    setState(() {
      if (index == null) {
        _d.lines.add(result);
      } else {
        _d.lines[index] = result;
      }
    });
  }

  List<Widget> _stepCheck() {
    _readText();
    final problems = _d.problems();
    return [
      Panel(
        title: 'Check',
        icon: Icons.fact_check_outlined,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          KeyValueLine('PO no.', _d.number.isEmpty ? 'New' : _d.number),
          KeyValueLine('Supplier', _d.supplier?.name ?? '-'),
          KeyValueLine('Invoice', '${_d.invoiceNo.isEmpty ? '-' : _d.invoiceNo} · ${Fmt.ddMMyyyy(_d.invoiceDate)}'),
          KeyValueLine('Due', _d.dueDate == null ? '-' : Fmt.ddMMyyyy(_d.dueDate)),
          KeyValueLine('Expense type', _d.description.isEmpty ? '-' : _d.description),
          KeyValueLine('Pay to', _d.payTo),
          if (_d.truck != null) KeyValueLine('Truck', _d.truck!.name),
          KeyValueLine('Status', _d.status),
          KeyValueLine('Items', '${_d.filledLines.length}'),
          const Divider(),
          Row(children: [
            Expanded(
                child: Text('Total',
                    style: AppTypography.bodyLarge(color: AppTokens.textPrimary, fontWeight: FontWeight.w800))),
            Text(Fmt.rm(_d.total), style: AppTypography.heading3(color: AppTokens.textPrimary)),
          ]),
        ]),
      ),
      if (problems.isNotEmpty) ...[
        const SizedBox(height: 12),
        InfoBanner(color: Palette.redDanger, lines: problems),
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
              key: const ValueKey('po-photo-camera'),
              onPressed: () => _addPhoto(ImageSource.camera),
              icon: const Icon(Icons.photo_camera_outlined, size: 18),
              label: const Text('Camera'),
            ),
            OutlinedButton.icon(
              onPressed: () => _addPhoto(ImageSource.gallery),
              icon: const Icon(Icons.photo_library_outlined, size: 18),
              label: const Text('Gallery'),
            ),
          ]),
          if (widget.editId != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text('Files already on this PO stay; new photos are added.',
                  style: AppTypography.badgeText(color: AppTokens.textMuted)),
            ),
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
                key: const ValueKey('po-back'),
                onPressed: () => setState(() {
                  _readText();
                  _step--;
                }),
                child: const Text('Back'),
              ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(Fmt.rm(_d.total),
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyLarge(color: AppTokens.textPrimary, fontWeight: FontWeight.w800)),
            ),
            const SizedBox(width: 8),
            _step < 2
                ? FilledButton(
                    key: const ValueKey('po-next'),
                    onPressed: () => setState(() {
                          _readText();
                          _step++;
                        }),
                    child: const Text('Next'))
                : FilledButton.icon(
                    key: const ValueKey('po-save'),
                    onPressed: _saving ? null : _save,
                    icon: _saving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.save_outlined),
                    label: const Text('Save'),
                  ),
          ]),
        ),
      );
}
