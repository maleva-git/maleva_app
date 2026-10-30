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
import '../data/voucher_api.dart';
import '../data/voucher_draft.dart';

/// Create or edit a payment voucher on the phone (change `payable-voucher-form`): 1 Pay · 2 Lines · 3 Check & save.
/// [fromPoId] = Push to PV: the voucher pays that purchase order; its files are offered to copy.
class VoucherFormPage extends StatefulWidget {
  const VoucherFormPage({super.key, required this.api, this.files, this.editId, this.fromPoId, this.pickPhoto, this.employeeId});

  final VoucherApi api;
  final AttachmentsApi? files;
  final int? editId;
  final int? fromPoId;
  final PhotoPicker? pickPhoto;
  final int? employeeId;

  @override
  State<VoucherFormPage> createState() => _VoucherFormPageState();
}

String voucherStatusLabel(String s) => s.isEmpty ? 'Send for approval' : statusLabel(s);

class _VoucherFormPageState extends State<VoucherFormPage> {
  VoucherDraft _d = VoucherDraft();
  int _step = 0;
  bool _loading = true;
  String? _loadError;
  bool _saving = false;
  final List<File> _photos = [];
  List<CarriedFile> _carried = [];

  List<Option> _banks = const [];
  List<Option> _accounts = const [];
  List<String> _heads = voucherDefaultHeads;
  List<String> _payTos = const [];
  List<String> _payFroms = const [];
  final List<String> _lookupErrors = [];

  final _payTo = TextEditingController();
  final _payFrom = TextEditingController();
  final _refNo = TextEditingController();
  final _charges = TextEditingController();

  PhotoPicker get _pick => widget.pickPhoto ?? defaultPhotoPicker;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _payTo.dispose();
    _payFrom.dispose();
    _refNo.dispose();
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
      _safe('Banks', api.banks, const <Option>[]),
      _safe('Accounts', api.po.accounts, const <Option>[]),
      _safe('Expense heads', api.heads, voucherDefaultHeads),
      _safe('Pay to', api.payTos, const <String>[]),
      _safe('Pay from', api.payFroms, const <String>[]),
      widget.editId == null ? _safe('Voucher number', api.nextNumber, '') : Future.value(''),
    ]);
    _banks = r[0] as List<Option>;
    _accounts = r[1] as List<Option>;
    _heads = r[2] as List<String>;
    _payTos = r[3] as List<String>;
    _payFroms = r[4] as List<String>;
    var d = VoucherDraft(number: r[5] as String);
    String? error;
    try {
      if (widget.editId != null) {
        d = VoucherDraft.fromEdit(await api.load(widget.editId!), banks: _banks);
      } else if (widget.fromPoId != null) {
        d = VoucherDraft.fromPo(await api.po.load(widget.fromPoId!), number: r[5] as String);
        if (widget.files != null) {
          final rows = await _safe('PO files',
              () => widget.files!.list(folder: 'BillOrderMaster', recordId: widget.fromPoId!), const <Map<String, dynamic>>[]);
          _carried = [for (final m in rows) CarriedFile(RecordFile.fromJava(m))];
        }
      }
      // fill the account names and classifications the lines only know by id
      for (final l in d.lines) {
        final id = l.account?.id;
        for (final a in _accounts) {
          if (a.id == id) l.account = a;
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
      _payTo.text = d.payTo;
      _payFrom.text = d.payFrom;
      _refNo.text = d.refNo;
      _charges.text = d.bankCharges == 0 ? '' : '${d.bankCharges}';
    });
  }

  void _readText() {
    _d.payTo = _payTo.text;
    _d.payFrom = _payFrom.text;
    _d.refNo = _refNo.text;
    _d.bankCharges = double.tryParse(_charges.text.replaceAll(',', '').trim()) ?? 0;
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
        title: Text(_d.isNew ? 'Save this payment voucher?' : 'Save the changes?'),
        content: Text([
          '${_d.payTo.trim().isEmpty ? '-' : _d.payTo.trim()} · ${_d.head}',
          '${Fmt.rm(_d.total)} from ${_d.bank?.name ?? ''} · ${voucherStatusLabel(_d.status)}',
          if (_d.poId != null && _d.isNew) 'Pays PO ${_d.poNumber}: the PO will be marked PAYMENT COMPLETED',
          if (_photos.isNotEmpty || keep.isNotEmpty) '${_photos.length + keep.length} files',
        ].join('\n')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          FilledButton(key: const ValueKey('pv-confirm'), onPressed: () => Navigator.pop(c, true), child: const Text('Save')),
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
        await showDialog<void>(
          context: context,
          builder: (c) => AlertDialog(
            title: const Text('Already saved'),
            content: Text('This voucher is already in the system as ${saved.number}. Nothing new was saved.'),
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
            await files.copyFrom([for (final c in keep) c.file.path], folder: 'PaymentVoucher', recordId: saved.id);
          }
          if (_photos.isNotEmpty) await files.add(_photos, folder: 'PaymentVoucher', recordId: saved.id);
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
            ? 'Pay ${_d.poNumber.isEmpty ? 'PO' : _d.poNumber}'
            : 'New payment voucher';
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
                  StepHeader(
                      step: _step,
                      names: const ['Pay', 'Lines', 'Check & save'],
                      onTap: (i) => setState(() {
                            _readText();
                            _step = i;
                          })),
                  Expanded(
                    child: ListView(padding: const EdgeInsets.fromLTRB(12, 8, 12, 24), children: [
                      if (_lookupErrors.isNotEmpty) InfoBanner(color: Palette.amberGold, lines: _lookupErrors),
                      if (_d.poId != null && _d.isNew)
                        InfoBanner(color: AppTokens.brandPrimary, lines: ['Pays purchase order ${_d.poNumber}']),
                      ...switch (_step) { 0 => _stepPay(), 1 => _stepLines(), _ => _stepCheck() },
                    ]),
                  ),
                  _bottomBar(),
                ]),
    );
  }

  Widget _nameField(TextEditingController c, String label, IconData icon, List<String> past, Key key) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: TextField(
          key: key,
          controller: c,
          textCapitalization: TextCapitalization.characters,
          decoration: InputDecoration(
            labelText: label,
            isDense: true,
            prefixIcon: Icon(icon, size: 20),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            suffixIcon: past.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Past names',
                    icon: const Icon(Icons.history),
                    onPressed: () async {
                      final o = await pickOption(context, title: label, options: [for (var i = 0; i < past.length; i++) Option(i, past[i])]);
                      if (o != null) setState(() => c.text = o.name);
                    },
                  ),
          ),
        ),
      );

  List<Widget> _stepPay() => [
        Panel(
          title: 'Pay',
          icon: Icons.payments_outlined,
          child: Column(children: [
            _nameField(_payTo, 'Pay to', Icons.person_outline, _payTos, const ValueKey('pv-payto')),
            PickField(
              key: const ValueKey('pv-bank'),
              label: 'Payment by (bank)',
              required: true,
              value: _d.bank?.name,
              icon: Icons.account_balance_outlined,
              onTap: () async {
                final b = await pickOption(context, title: 'Payment by', options: _banks, selected: _d.bank);
                if (b != null) setState(() => _d.bank = b);
              },
            ),
            _nameField(_payFrom, 'Pay from', Icons.business_outlined, _payFroms, const ValueKey('pv-payfrom')),
            DateField(
                label: 'Voucher date',
                value: _d.date,
                onTap: () async {
                  final v = await showDatePicker(
                      context: context, initialDate: _d.date, firstDate: DateTime(2015), lastDate: DateTime(Fmt.today().year + 1));
                  if (v != null) setState(() => _d.date = v);
                }),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(
                child: TextField(
                  key: const ValueKey('pv-ref'),
                  controller: _refNo,
                  decoration: InputDecoration(
                      labelText: 'Reference', isDense: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  key: const ValueKey('pv-charges'),
                  controller: _charges,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                      labelText: 'Bank charges', isDense: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                ),
              ),
            ]),
          ]),
        ),
        const SizedBox(height: 12),
        Panel(
          title: 'Expense head *',
          icon: Icons.category_outlined,
          child: TextPickField(
            key: const ValueKey('pv-head'),
            label: 'Expense head',
            required: true,
            value: _d.head,
            options: _heads,
            onChanged: (x) => setState(() => _d.head = x),
          ),
        ),
        const SizedBox(height: 12),
        Panel(
          title: 'Status',
          icon: Icons.flag_outlined,
          child: TextPickField(
            key: const ValueKey('pv-status'),
            label: 'Status',
            icon: Icons.flag_outlined,
            value: _d.status,
            options: voucherStatuses,
            labelOf: voucherStatusLabel,
            onChanged: (s) => setState(() => _d.status = s),
          ),
        ),
      ];

  List<Widget> _stepLines() => [
        Panel(
          title: 'Lines',
          icon: Icons.list_alt_outlined,
          trailing: SoftChip(text: '${_d.filledLines.length}'),
          child: Column(children: [
            if (_d.lines.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text('No lines yet. Add what is paid.', style: AppTypography.bodySmall(color: AppTokens.textMuted)),
              ),
            for (var i = 0; i < _d.lines.length; i++) _lineTile(i),
            const SizedBox(height: 6),
            OutlinedButton.icon(
                key: const ValueKey('pv-add-line'), onPressed: () => _editLine(null), icon: const Icon(Icons.add), label: const Text('Add line')),
          ]),
        ),
        const SizedBox(height: 12),
        TotalsCard(total: _d.total, tax: 0),
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
          key: ValueKey('pv-line-$i'),
          onTap: () => _editLine(i),
          title: Text(noAccount ? 'Choose the account' : l.account!.name,
              style: AppTypography.bodyMedium(color: noAccount ? Palette.redDanger : AppTokens.textPrimary, fontWeight: FontWeight.w600)),
          subtitle: Text([if (l.description.trim().isNotEmpty) l.description.trim(), if (l.linkLabel.isNotEmpty) '🔗 ${l.linkLabel}'].join(' · '),
              style: AppTypography.bodySmall(color: AppTokens.textMuted)),
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(Fmt.rm(l.amount), style: AppTypography.bodyMedium(color: AppTokens.textPrimary, fontWeight: FontWeight.w700)),
            // a line paying a levy or a monthly bill is not removed here: the server links it (edit on the web)
            if (l.linkLabel.isEmpty)
              IconButton(tooltip: 'Remove', icon: const Icon(Icons.delete_outline, size: 20), onPressed: () => setState(() => _d.lines.removeAt(i))),
          ]),
        ),
      ),
    );
  }

  Future<void> _editLine(int? index) async {
    final line = index == null ? VoucherLine() : _d.lines[index].copy();
    final result = await showModalBottomSheet<VoucherLine>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppTokens.surfaceCard,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
      builder: (_) => _VoucherLineSheet(line: line, accounts: _accounts),
    );
    if (result == null) return;
    setState(() => index == null ? _d.lines.add(result) : _d.lines[index] = result);
  }

  List<Widget> _stepCheck() {
    _readText();
    final problems = _d.problems();
    return [
      Panel(
        title: 'Check',
        icon: Icons.fact_check_outlined,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          KeyValueLine('Voucher no.', _d.number.isEmpty ? 'New' : _d.number),
          if (_d.poId != null) KeyValueLine('Pays PO', _d.poNumber.isEmpty ? '#${_d.poId}' : _d.poNumber),
          KeyValueLine('Pay to', _d.payTo.trim().isEmpty ? '-' : _d.payTo.trim()),
          KeyValueLine('Payment by', _d.bank?.name ?? '-'),
          KeyValueLine('Date', Fmt.ddMMyyyy(_d.date)),
          KeyValueLine('Expense head', _d.head.isEmpty ? '-' : _d.head),
          KeyValueLine('Status', voucherStatusLabel(_d.status)),
          if (_d.bankCharges > 0) KeyValueLine('Bank charges', Fmt.rm(_d.bankCharges)),
          KeyValueLine('Lines', '${_d.filledLines.length}'),
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
        title: 'Photos (receipt, transfer slip)',
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
                key: const ValueKey('pv-photo-camera'),
                onPressed: () => _addPhoto(ImageSource.camera),
                icon: const Icon(Icons.photo_camera_outlined, size: 18),
                label: const Text('Camera')),
            OutlinedButton.icon(
                onPressed: () => _addPhoto(ImageSource.gallery), icon: const Icon(Icons.photo_library_outlined, size: 18), label: const Text('Gallery')),
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
          decoration: const BoxDecoration(color: AppTokens.surfaceCard, border: Border(top: BorderSide(color: AppTokens.surfaceBorder))),
          child: Row(children: [
            if (_step > 0)
              OutlinedButton(
                  key: const ValueKey('pv-back'),
                  onPressed: () => setState(() {
                        _readText();
                        _step--;
                      }),
                  child: const Text('Back')),
            const SizedBox(width: 8),
            Expanded(
              child: Text(Fmt.rm(_d.total),
                  textAlign: TextAlign.center, style: AppTypography.bodyLarge(color: AppTokens.textPrimary, fontWeight: FontWeight.w800)),
            ),
            const SizedBox(width: 8),
            _step < 2
                ? FilledButton(
                    key: const ValueKey('pv-next'),
                    onPressed: () => setState(() {
                          _readText();
                          _step++;
                        }),
                    child: const Text('Next'))
                : FilledButton.icon(
                    key: const ValueKey('pv-save'),
                    onPressed: _saving ? null : _save,
                    icon: _saving
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.save_outlined),
                    label: const Text('Save')),
          ]),
        ),
      );
}

/// Add or change one voucher line: account, what it is for, amount.
class _VoucherLineSheet extends StatefulWidget {
  const _VoucherLineSheet({required this.line, required this.accounts});

  final VoucherLine line;
  final List<Option> accounts;

  @override
  State<_VoucherLineSheet> createState() => _VoucherLineSheetState();
}

class _VoucherLineSheetState extends State<_VoucherLineSheet> {
  late final VoucherLine l = widget.line;
  late final _desc = TextEditingController(text: l.description);
  late final _amount = TextEditingController(text: l.amount == 0 ? '' : '${l.amount}');

  @override
  void dispose() {
    _desc.dispose();
    _amount.dispose();
    super.dispose();
  }

  InputDecoration _dec(String label) =>
      InputDecoration(labelText: label, isDense: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)));

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + MediaQuery.viewInsetsOf(context).bottom),
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text('Line', style: AppTypography.heading3(color: AppTokens.textPrimary)),
            if (l.linkLabel.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('Linked to a ${l.linkLabel.toLowerCase()}: the server checks the amount.',
                    style: AppTypography.bodySmall(color: AppTokens.textMuted)),
              ),
            const SizedBox(height: 12),
            PickField(
              key: const ValueKey('pv-line-account'),
              label: 'Account',
              required: true,
              value: l.account == null ? null : '${l.account!.name}${l.account!.sub.isEmpty ? '' : '  (${l.account!.sub})'}',
              icon: Icons.account_tree_outlined,
              onTap: () async {
                final a = await pickOption(context, title: 'Account', options: widget.accounts, selected: l.account);
                if (a != null) setState(() => l.account = a);
              },
            ),
            TextField(key: const ValueKey('pv-line-desc'), controller: _desc, decoration: _dec('What it is for')),
            const SizedBox(height: 10),
            TextField(
                key: const ValueKey('pv-line-amount'),
                controller: _amount,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: _dec('Amount (RM)')),
            const SizedBox(height: 12),
            FilledButton(
              key: const ValueKey('pv-line-done'),
              onPressed: () {
                l.description = _desc.text;
                l.amount = double.tryParse(_amount.text.replaceAll(',', '').trim()) ?? 0;
                Navigator.pop(context, l);
              },
              child: const Text('Done'),
            ),
          ]),
        ),
      );
}
