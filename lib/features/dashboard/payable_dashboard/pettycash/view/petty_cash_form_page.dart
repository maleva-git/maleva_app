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
import '../../records/view/record_files.dart';
import '../../records/view/record_style.dart';
import '../data/petty_cash_ai.dart';
import '../data/petty_cash_api.dart';
import '../data/petty_cash_draft.dart';

/// The folder the web files petty cash documents under (`ATTACHMENT_FOLDERS.pettyCash`).
const pettyCashFolder = 'PettyCash';

/// Create or edit a petty cash sheet on the phone (change `payable-pettycash-form`), the web form
/// (`PettyCashFormPage.tsx`) on one page: sheet, balance (the person's petty cash book), items, files.
/// **Read with AI** fills it from a photo of the sheet; the person checks and saves. Pops `true` after a save.
class PettyCashFormPage extends StatefulWidget {
  const PettyCashFormPage({super.key, required this.api, required this.files, this.editId});

  final PettyCashApi api;
  final AttachmentsApi files;
  final int? editId;

  /// Tests give their own photo picker; null = camera / gallery.
  @visibleForTesting
  static PhotoPicker? debugPickPhoto;

  /// Tests give the signed-in employee; null = the saved sign-in.
  @visibleForTesting
  static int? debugEmployeeId;

  @override
  State<PettyCashFormPage> createState() => _PettyCashFormPageState();
}

class _PettyCashFormPageState extends State<PettyCashFormPage> {
  PettyCashDraft _d = PettyCashDraft();
  bool _loading = true;
  String? _loadError;
  bool _saving = false;
  bool _reading = false;
  bool _following = false;
  int _lastAsk = 0;

  bool _aiFilled = false;
  List<String> _aiWarnings = const [];
  List<Option> _aiCandidates = const [];
  String _aiName = '';
  bool _aiUnmatched = false;

  final List<File> _photos = [];
  List<RecordFile> _savedFiles = const [];

  List<Option> _employees = const [];
  List<String> _types = pettyCashFallbackTypes;
  List<PettyCashAccount> _accounts = const [];
  final List<String> _lookupErrors = [];

  final _remark = TextEditingController();
  final _before = TextEditingController();
  final _cash = TextEditingController();

  PettyCashApi get _api => widget.api;
  PhotoPicker get _pick => PettyCashFormPage.debugPickPhoto ?? defaultPhotoPicker;

  int get _me {
    final test = PettyCashFormPage.debugEmployeeId;
    if (test != null) return test;
    try {
      return AppPreferences.getEmpRefId();
    } catch (_) {
      return 0;
    }
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _remark.dispose();
    _before.dispose();
    _cash.dispose();
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
    final r = await Future.wait<Object>([
      _safe('People', _api.employees, const <Option>[]),
      _safe('Employee types', _api.employeeTypes, pettyCashFallbackTypes),
      _safe('Accounts', _api.accounts, const <PettyCashAccount>[]),
      widget.editId == null ? _safe('Petty cash number', _api.nextNumber, '') : Future.value(''),
    ]);
    _employees = r[0] as List<Option>;
    _types = r[1] as List<String>;
    _accounts = r[2] as List<PettyCashAccount>;
    var d = PettyCashDraft(number: r[3] as String);
    String? error;
    try {
      if (widget.editId != null) {
        d = PettyCashDraft.fromEdit(await _api.load(widget.editId!), employees: _employees);
        _savedFiles = await _safe('Files', () => _listFiles(widget.editId!), const <RecordFile>[]);
      } else {
        final me = _me;
        if (me > 0) d.employee = _employees.where((e) => e.id == me).firstOrNull ?? Option(me, '#$me');
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
    if (error == null) await _refreshLast();
  }

  Future<List<RecordFile>> _listFiles(int id) async =>
      [for (final m in await widget.files.list(folder: pettyCashFolder, recordId: id)) RecordFile.fromJava(m)];

  /// The person's last sheet for the date (web usePettyCashLastBalance); an older answer never overwrites a newer one.
  Future<void> _refreshLast() async {
    final ask = ++_lastAsk;
    final d = _d;
    final last = await _safe(
        'Last balance',
        () => _api.lastBalance(employeeId: d.employee?.id ?? 0, date: d.date, excludeId: d.isNew ? null : d.id),
        null);
    if (!mounted || ask != _lastAsk) return;
    setState(() {
      _d.lastBalance = last;
      if (!_d.typed) _before.text = _d.balanceBefore;
    });
  }

  void _syncText() {
    _remark.text = _d.remark;
    _before.text = _d.balanceBefore;
    _cash.text = _d.cashReceived;
  }

  void _readText() {
    _d.remark = _remark.text;
  }

  Future<void> _chooseEmployee(Option e) async {
    setState(() => _d.employee = e);
    await _refreshLast();
  }

  // ── AI ───────────────────────────────────────────────────────────────────────

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
    if (_d.hasData) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          title: const Text('Replace the form?'),
          content: const Text('The AI will fill the form from the photo. What is on the form now will be replaced.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
            FilledButton(
                key: const ValueKey('ai-replace'), onPressed: () => Navigator.pop(c, true), child: const Text('Replace')),
          ],
        ),
      );
      if (ok != true || !mounted) return;
    }
    setState(() => _reading = true);
    try {
      final res = applyPettyCashExtraction(await _api.extract(file), _d,
          accounts: _accounts, types: _types, employees: _employees);
      if (!mounted) return;
      setState(() {
        _d = res.draft;
        _aiFilled = true;
        _aiWarnings = res.warnings;
        _aiCandidates = res.candidates;
        _aiName = res.unmatchedName;
        _aiUnmatched = res.unmatched;
        if (!_photos.any((p) => p.path == file.path)) _photos.add(file);
        _syncText();
      });
      await _refreshLast();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('AI could not read it: $e')));
    } finally {
      if (mounted) setState(() => _reading = false);
    }
  }

  // ── chain ────────────────────────────────────────────────────────────────────

  Future<void> _follow() async {
    if (_d.isNew) return;
    setState(() => _following = true);
    try {
      final r = await _api.follow(_d.id);
      final d = PettyCashDraft.fromEdit(await _api.load(_d.id), employees: _employees);
      if (!mounted) return;
      setState(() {
        _d = d;
        _syncText();
      });
      await _refreshLast();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(r.message)));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not update: $e')));
    } finally {
      if (mounted) setState(() => _following = false);
    }
  }

  // ── save ─────────────────────────────────────────────────────────────────────

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
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(_d.isNew ? 'Save this petty cash?' : 'Save the changes?'),
        content: Text([
          _d.employee?.name ?? '',
          '${Fmt.rm(_d.total)} · ${_d.savedLines.length} items',
          if (_d.ready) 'This balance ${Fmt.rm(_d.thisBalance)}',
          if (_d.ready && _d.short) 'More spent than cash in hand',
          if (_photos.isNotEmpty) '${_photos.length} photos',
        ].where((t) => t.isNotEmpty).join('\n')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          FilledButton(key: const ValueKey('pc-confirm'), onPressed: () => Navigator.pop(c, true), child: const Text('Save')),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => _saving = true);
    try {
      final saved = await _api.save(_d.toJson(employeeId: _me));
      final id = saved.id > 0 ? saved.id : _d.id;
      String? fileError;
      if (_photos.isNotEmpty && id > 0) {
        try {
          await widget.files.add(_photos, folder: pettyCashFolder, recordId: id);
        } catch (e) {
          fileError = '$e';
        }
      }
      if (!mounted) return;
      final name = saved.number.isNotEmpty ? saved.number : (_d.number.isNotEmpty ? _d.number : 'petty cash');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(fileError == null
              ? 'Saved $name'
              : 'Saved $name, but the photos did not upload: $fileError. Add them on the web.')));
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Not saved: $e')));
      }
    }
  }

  // ── page ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final title = widget.editId != null ? 'Edit ${_d.number}' : 'New petty cash';
    return Scaffold(
      backgroundColor: AppTokens.surfacePage,
      appBar: AppBar(
        backgroundColor: AppTokens.brandGradientStart,
        foregroundColor: AppTokens.textOnDark,
        title: Text(title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodyLarge(color: AppTokens.textOnDark, fontWeight: FontWeight.w700)),
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
                  if (_reading) const LinearProgressIndicator(minHeight: 3),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 24),
                      children: [
                        if (_lookupErrors.isNotEmpty) InfoBanner(color: Palette.amberGold, lines: _lookupErrors),
                        if (_aiFilled) _aiBanner(),
                        if (_chainNote) ...[_chainBanner(), const SizedBox(height: 10)],
                        _aiCard(),
                        const SizedBox(height: 12),
                        _sheetPanel(),
                        const SizedBox(height: 12),
                        _balancePanel(),
                        const SizedBox(height: 12),
                        _itemsPanel(),
                        const SizedBox(height: 12),
                        _filesPanel(),
                      ],
                    ),
                  ),
                  _bottomBar(),
                ]),
    );
  }

  Widget _aiCard() => Material(
        color: AppTokens.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          key: const ValueKey('pc-ai'),
          borderRadius: BorderRadius.circular(14),
          onTap: _reading ? null : _readWithAi,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTokens.brandPrimary.withValues(alpha: 0.35))),
            child: Row(children: [
              const CircleAvatar(
                  backgroundColor: AppTokens.brandLight, child: Icon(Icons.auto_awesome, color: AppTokens.brandPrimary)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(_reading ? 'Reading…' : 'Read with AI',
                      style: AppTypography.bodyLarge(color: AppTokens.textPrimary, fontWeight: FontWeight.w700)),
                  Text('Photo of the petty cash sheet fills the form for you',
                      style: AppTypography.bodySmall(color: AppTokens.textMuted)),
                ]),
              ),
              const Icon(Icons.photo_camera_outlined, color: AppTokens.brandPrimary),
            ]),
          ),
        ),
      );

  Widget _aiBanner() => Container(
        key: const ValueKey('pc-ai-banner'),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: AppTokens.brandLight, borderRadius: BorderRadius.circular(12)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.auto_awesome, size: 18, color: AppTokens.brandPrimary),
            const SizedBox(width: 6),
            Expanded(
                child: Text('Filled by AI — please check',
                    style: AppTypography.bodyMedium(color: AppTokens.brandPrimary, fontWeight: FontWeight.w700))),
            InkWell(
                onTap: () => setState(() {
                      _aiFilled = false;
                      _aiWarnings = const [];
                      _aiCandidates = const [];
                      _aiUnmatched = false;
                    }),
                child: const Icon(Icons.close, size: 18)),
          ]),
          for (final w in _aiWarnings)
            Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('• $w', style: AppTypography.bodySmall(color: AppTokens.textPrimary))),
          if (_aiUnmatched) ...[
            const SizedBox(height: 6),
            Text(
                _aiName.isNotEmpty
                    ? "Requested by '$_aiName' not found for sure.${_aiCandidates.isEmpty ? '' : ' Choose:'}"
                    : 'Requested by not found for sure.${_aiCandidates.isEmpty ? '' : ' Choose:'}',
                style: AppTypography.bodySmall(color: AppTokens.textPrimary, fontWeight: FontWeight.w600)),
            if (_aiCandidates.isNotEmpty)
              Wrap(spacing: 6, children: [
                for (final c in _aiCandidates)
                  ActionChip(
                      key: ValueKey('pc-candidate-${c.id}'),
                      label: Text(c.name),
                      onPressed: () {
                        setState(() {
                          _aiCandidates = const [];
                          _aiUnmatched = false;
                        });
                        _chooseEmployee(c);
                      }),
              ]),
          ],
        ]),
      );

  bool get _chainNote => !_d.isNew && (_d.saved?.ready ?? false) && _d.saved?.expectedBefore != null;

  Widget _chainBanner() => Container(
        key: const ValueKey('pc-chain'),
        padding: const EdgeInsets.fromLTRB(12, 10, 8, 8),
        decoration: BoxDecoration(
          color: Palette.amberGold.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Palette.amberGold.withValues(alpha: 0.5)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.sync_problem, size: 18, color: Palette.amberGold),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                  'Last balance changed: was ${Fmt.rm(_d.saved?.balanceBefore ?? 0)}, '
                  'now ${Fmt.rm(_d.saved!.expectedBefore!)}',
                  style: AppTypography.bodySmall(color: AppTokens.textPrimary, fontWeight: FontWeight.w600)),
            ),
          ]),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              key: const ValueKey('pc-follow'),
              onPressed: _following ? null : _follow,
              icon: _following
                  ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.refresh, size: 18),
              label: const Text('Update'),
            ),
          ),
        ]),
      );

  Widget _sheetPanel() => Panel(
        title: 'Petty cash',
        icon: Icons.payments_outlined,
        trailing: _d.number.isEmpty ? null : SoftChip(text: _d.number),
        child: Column(children: [
          DateField(
              label: 'Date',
              value: _d.date,
              onTap: () async {
                final v = await showDatePicker(
                    context: context,
                    initialDate: _d.date,
                    firstDate: DateTime(2015),
                    lastDate: DateTime(Fmt.today().year + 2));
                if (v != null) {
                  setState(() => _d.date = v);
                  await _refreshLast();
                }
              }),
          const SizedBox(height: 10),
          PickField(
            key: const ValueKey('pc-employee'),
            label: 'Requested by',
            value: _d.employee?.name,
            icon: Icons.person_outline,
            onTap: () async {
              final e = await pickOption(context, title: 'Requested by', options: _employees, selected: _d.employee);
              if (e != null) await _chooseEmployee(e);
            },
          ),
          TextPickField(
            key: const ValueKey('pc-type'),
            label: 'Employee type',
            required: true,
            icon: Icons.badge_outlined,
            value: _d.department,
            options: _types,
            onChanged: (t) => setState(() => _d.department = t),
          ),
          TextPickField(
            key: const ValueKey('pc-status'),
            label: 'Status',
            icon: Icons.flag_outlined,
            value: _d.paymentStatus,
            options: pettyCashStatuses,
            labelOf: (s) => s.isEmpty ? 'No status' : s,
            onChanged: (s) => setState(() => _d.paymentStatus = s),
          ),
          TextField(
            key: const ValueKey('pc-remark'),
            controller: _remark,
            maxLines: 2,
            minLines: 1,
            decoration: InputDecoration(
                labelText: 'Remark', isDense: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
          ),
        ]),
      );

  // ── balance ──────────────────────────────────────────────────────────────────

  Widget _box({required Widget child, Color? tint, Key? key}) => Container(
        key: key,
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
        decoration: BoxDecoration(
          color: tint == null ? AppTokens.surfacePage : tint.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: tint == null ? AppTokens.surfaceBorder : tint.withValues(alpha: 0.45)),
        ),
        child: child,
      );

  Widget _label(String t) => Text(t,
      maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTypography.bodySmall(color: AppTokens.textMuted));

  Widget _moneyInput(TextEditingController c, Key key, {required bool readOnly, required ValueChanged<String> onChanged}) =>
      TextField(
        key: key,
        controller: c,
        readOnly: readOnly,
        textAlign: TextAlign.right,
        keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
        style: AppTypography.bodyLarge(color: AppTokens.textPrimary, fontWeight: FontWeight.w800),
        decoration: InputDecoration(
          isDense: true,
          hintText: '0.00',
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          filled: !readOnly,
          fillColor: AppTokens.surfaceCard,
          border: readOnly ? InputBorder.none : OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onChanged: onChanged,
      );

  Widget _totalBox() => _box(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _label('Total (RM)'),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(Fmt.rm(_d.total),
                key: const ValueKey('pc-total'), style: AppTypography.heading3(color: Palette.redDanger)),
          ),
        ]),
      );

  Widget _balancePanel() {
    if (!_d.ready) {
      return Panel(title: 'Total', icon: Icons.calculate_outlined, child: _totalBox());
    }
    final note = _d.sourceNote;
    final short = _d.short;
    final lastBox = _box(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: _label('Last balance (RM)')),
          InkWell(
            key: const ValueKey('pc-pencil'),
            borderRadius: BorderRadius.circular(12),
            onTap: () => setState(() {
              if (_d.typed) {
                _d.typedBefore = null;
                _before.text = _d.balanceBefore;
              } else {
                _d.typedBefore = _d.balanceBefore;
              }
              _d.dirty = true;
            }),
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: Icon(_d.typed ? Icons.undo : Icons.edit_outlined, size: 16, color: AppTokens.brandPrimary),
            ),
          ),
        ]),
        const SizedBox(height: 4),
        _moneyInput(_before, const ValueKey('pc-before'),
            readOnly: !_d.typed,
            onChanged: (v) => setState(() {
                  _d.typedBefore = v;
                  _d.dirty = true;
                })),
        if (note.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(note,
                key: const ValueKey('pc-before-note'),
                style: AppTypography.badgeText(color: _d.typed ? Palette.amberGold : AppTokens.textMuted)),
          ),
      ]),
    );
    final cashBox = _box(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _label('Cash received (RM)'),
        const SizedBox(height: 4),
        _moneyInput(_cash, const ValueKey('pc-cash'),
            readOnly: false,
            onChanged: (v) => setState(() {
                  _d.cashReceived = v;
                  _d.dirty = true;
                })),
      ]),
    );
    final thisBox = _box(
      tint: short ? Palette.redDanger : Palette.greenEco,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _label('This balance (RM)'),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(Fmt.rm(_d.thisBalance),
              key: const ValueKey('pc-this'),
              style: AppTypography.heading3(color: short ? Palette.redDanger : Palette.greenEco)),
        ),
        if (short)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text('More spent than cash in hand',
                key: const ValueKey('pc-short'),
                style: AppTypography.badgeText(color: Palette.redDanger, fontWeight: FontWeight.w700)),
          ),
      ]),
    );
    return Panel(
      title: 'Balance',
      icon: Icons.account_balance_wallet_outlined,
      child: Column(children: [
        IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Expanded(child: lastBox),
            const SizedBox(width: 8),
            Expanded(child: cashBox),
          ]),
        ),
        const SizedBox(height: 8),
        IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Expanded(child: _totalBox()),
            const SizedBox(width: 8),
            Expanded(child: thisBox),
          ]),
        ),
        const SizedBox(height: 6),
        Text('This balance = Last balance + Cash received − Total',
            style: AppTypography.badgeText(color: AppTokens.textMuted)),
      ]),
    );
  }

  // ── items ────────────────────────────────────────────────────────────────────

  Widget _itemsPanel() => Panel(
        title: 'Items',
        icon: Icons.list_alt_outlined,
        trailing: SoftChip(text: '${_d.savedLines.length}'),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          if (_d.lines.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text('No items yet. Add what the cash was spent on.',
                  style: AppTypography.bodySmall(color: AppTokens.textMuted)),
            ),
          for (var i = 0; i < _d.lines.length; i++) _lineTile(i),
          const SizedBox(height: 6),
          OutlinedButton.icon(
              key: const ValueKey('pc-add-line'),
              onPressed: () => _editLine(null),
              icon: const Icon(Icons.add),
              label: const Text('Add item')),
        ]),
      );

  Widget _lineTile(int i) {
    final l = _d.lines[i];
    final bad = l.hasData && l.incomplete;
    final amount = double.tryParse(l.amount.trim());
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: AppTokens.surfacePage,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: bad ? Palette.redDanger.withValues(alpha: 0.5) : AppTokens.surfaceBorder),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          key: ValueKey('pc-line-$i'),
          onTap: () => _editLine(i),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
            child: Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(l.items.trim().isEmpty ? 'Type the item' : l.items.trim(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodyMedium(
                          color: l.items.trim().isEmpty ? Palette.redDanger : AppTokens.textPrimary,
                          fontWeight: FontWeight.w600)),
                  if (l.notes.trim().isNotEmpty)
                    Text(l.notes.trim(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodySmall(color: AppTokens.textMuted)),
                  Text(l.account == null ? 'No account' : '${l.account!.code.isEmpty ? '' : '${l.account!.code} · '}${l.account!.name}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodySmall(color: l.account == null ? Palette.amberGold : AppTokens.brandPrimary)),
                ]),
              ),
              const SizedBox(width: 6),
              Text(amount == null ? '-' : Fmt.rm(amount),
                  style: AppTypography.bodyMedium(
                      color: amount == null ? Palette.redDanger : AppTokens.textPrimary, fontWeight: FontWeight.w700)),
              IconButton(
                  tooltip: 'Remove',
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.delete_outline, size: 20),
                  onPressed: () => setState(() {
                        _d.lines.removeAt(i);
                        _d.dirty = true;
                      })),
            ]),
          ),
        ),
      ),
    );
  }

  Future<void> _editLine(int? index) async {
    final line = index == null ? PettyCashLine() : _d.lines[index].copy();
    final before = index == null ? '' : _d.lines[index].amount;
    final result = await showModalBottomSheet<PettyCashLine>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppTokens.surfaceCard,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
      builder: (_) => _PettyCashLineSheet(line: line, accounts: _accounts),
    );
    if (result == null || !mounted) return;
    setState(() {
      index == null ? _d.lines.add(result) : _d.lines[index] = result;
      // only amounts move the balance; picking an account does not (web updateLine)
      if (result.amount.trim() != before.trim()) _d.dirty = true;
    });
  }

  // ── files ────────────────────────────────────────────────────────────────────

  Widget _filesPanel() => Panel(
        title: 'Files',
        icon: Icons.photo_library_outlined,
        trailing: SoftChip(text: '${_savedFiles.length + _photos.length}'),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          if (_savedFiles.isNotEmpty) ...[
            RecordFilesGrid(files: _savedFiles),
            const SizedBox(height: 10),
          ],
          if (_photos.isNotEmpty) ...[
            Text('New (uploaded when you save)', style: AppTypography.bodySmall(color: AppTokens.textMuted)),
            const SizedBox(height: 6),
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
          ],
          if (_savedFiles.isEmpty && _photos.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text('No files yet', style: AppTypography.bodySmall(color: AppTokens.textMuted)),
            ),
          Wrap(spacing: 8, runSpacing: 8, children: [
            OutlinedButton.icon(
                key: const ValueKey('pc-photo-camera'),
                onPressed: () => _addPhoto(ImageSource.camera),
                icon: const Icon(Icons.photo_camera_outlined, size: 18),
                label: const Text('Camera')),
            OutlinedButton.icon(
                key: const ValueKey('pc-photo-gallery'),
                onPressed: () => _addPhoto(ImageSource.gallery),
                icon: const Icon(Icons.photo_library_outlined, size: 18),
                label: const Text('Gallery')),
          ]),
        ]),
      );

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
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                Text('Total', style: AppTypography.bodySmall(color: AppTokens.textMuted)),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(Fmt.rm(_d.total),
                      style: AppTypography.bodyLarge(color: AppTokens.textPrimary, fontWeight: FontWeight.w800)),
                ),
              ]),
            ),
            const SizedBox(width: 8),
            FilledButton.icon(
                key: const ValueKey('pc-save'),
                onPressed: _saving || _reading ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.save_outlined),
                label: const Text('Save')),
          ]),
        ),
      );
}

/// Add or change one row: item, notes, amount, account (its classification comes with it).
class _PettyCashLineSheet extends StatefulWidget {
  const _PettyCashLineSheet({required this.line, required this.accounts});

  final PettyCashLine line;
  final List<PettyCashAccount> accounts;

  @override
  State<_PettyCashLineSheet> createState() => _PettyCashLineSheetState();
}

class _PettyCashLineSheetState extends State<_PettyCashLineSheet> {
  late final PettyCashLine l = widget.line;
  late final _items = TextEditingController(text: l.items);
  late final _notes = TextEditingController(text: l.notes);
  late final _amount = TextEditingController(text: l.amount);

  @override
  void dispose() {
    _items.dispose();
    _notes.dispose();
    _amount.dispose();
    super.dispose();
  }

  InputDecoration _dec(String label) => InputDecoration(
      labelText: label, isDense: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)));

  @override
  Widget build(BuildContext context) {
    final a = l.account;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text('Item', style: AppTypography.heading3(color: AppTokens.textPrimary)),
          const SizedBox(height: 12),
          TextField(
              key: const ValueKey('pcl-items'),
              controller: _items,
              maxLength: 100,
              decoration: _dec('Item (pay to) *')),
          TextField(
              key: const ValueKey('pcl-notes'), controller: _notes, maxLength: 255, decoration: _dec('Notes (what for)')),
          TextField(
              key: const ValueKey('pcl-amount'),
              controller: _amount,
              keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
              decoration: _dec('Amount (RM) *')),
          const SizedBox(height: 12),
          PickField(
            key: const ValueKey('pcl-account'),
            label: 'Account',
            value: a == null ? null : '${a.name}${a.code.isEmpty ? '' : '  (${a.code})'}',
            icon: Icons.account_tree_outlined,
            onTap: () async {
              final p = await pickOption(context, title: 'Account', options: widget.accounts, selected: a, allowClear: true);
              if (p == null) return;
              setState(() => l.account = p is PettyCashAccount ? p : null);
            },
          ),
          if (a != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                  a.classificationName.isNotEmpty
                      ? 'e-Invoice classification: ${a.classificationName}'
                      : (a.classification > 0 ? 'e-Invoice classification #${a.classification}' : 'No e-Invoice classification on this account'),
                  key: const ValueKey('pcl-class'),
                  style: AppTypography.bodySmall(color: AppTokens.textMuted)),
            ),
          const SizedBox(height: 8),
          FilledButton(
            key: const ValueKey('pcl-done'),
            onPressed: () {
              l
                ..items = _items.text
                ..notes = _notes.text
                ..amount = _amount.text.replaceAll(',', '').trim();
              Navigator.pop(context, l);
            },
            child: const Text('Done'),
          ),
        ]),
      ),
    );
  }
}
