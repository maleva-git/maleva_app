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
import '../data/levy_api.dart';
import '../data/levy_draft.dart';

/// Create or edit a levy (levi entry) on the phone (change `payable-levy-form`): the web levi entry form's fields and
/// rules on one page — date, truck, driver, RTI, enter / exit link, amount, remarks — and photos filed under
/// `LeviEntry`. Closes with `true` after a successful save.
class LevyFormPage extends StatefulWidget {
  const LevyFormPage({super.key, required this.api, required this.files, this.editId});

  final LevyApi api;
  final AttachmentsApi files;
  final int? editId;

  @override
  State<LevyFormPage> createState() => _LevyFormPageState();
}

class _LevyFormPageState extends State<LevyFormPage> {
  LevyDraft _d = LevyDraft();
  bool _loading = true;
  String? _loadError;
  bool _saving = false;

  List<Option> _trucks = const [];
  List<Option> _drivers = const [];
  List<Option> _rtis = const [];
  List<RecordFile> _saved = const [];
  final List<File> _photos = [];
  final List<String> _lookupErrors = [];

  final _amount = TextEditingController();
  final _remarks = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _amount.dispose();
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
      _safe('Trucks', api.trucks, const <Option>[]),
      _safe('Drivers', api.drivers, const <Option>[]),
      _safe('RTI numbers', api.rtiOptions, const <Option>[]),
      widget.editId == null ? _safe('Levy number', api.nextNumber, '') : Future.value(''),
    ]);
    _trucks = r[0] as List<Option>;
    _drivers = r[1] as List<Option>;
    _rtis = r[2] as List<Option>;
    var d = LevyDraft(number: r[3] as String);
    String? error;
    if (widget.editId != null) {
      try {
        d = LevyDraft.fromEdit(await api.load(widget.editId!), trucks: _trucks, drivers: _drivers, rtis: _rtis);
        final rows = await _safe('Files',
            () => widget.files.list(folder: levyFolder, recordId: widget.editId!), const <Map<String, dynamic>>[]);
        _saved = [for (final m in rows) RecordFile.fromJava(m)];
      } catch (e) {
        error = '$e';
      }
    }
    if (!mounted) return;
    setState(() {
      _d = d;
      _loadError = error;
      _loading = false;
      _amount.text = d.amount == null ? '' : _n(d.amount!);
      _remarks.text = d.remarks;
    });
  }

  static String _n(double v) => v % 1 == 0 ? v.toStringAsFixed(0) : '$v';

  void _readText() {
    final t = _amount.text.replaceAll(',', '').trim();
    _d.amount = t.isEmpty ? null : double.tryParse(t);
    _d.remarks = _remarks.text;
  }

  int? _employeeId() {
    try {
      final id = AppPreferences.getEmpRefId();
      return id > 0 ? id : null;
    } catch (_) {
      return null; // preferences not ready (tests)
    }
  }

  Future<void> _addPhoto(ImageSource source) async {
    final f = await defaultPhotoPicker(source);
    if (f != null && mounted) setState(() => _photos.add(f));
  }

  Future<void> _save() async {
    _readText();
    final typed = _amount.text.trim();
    final problems = [
      for (final p in _d.problems())
        p == 'Type the amount' && typed.isNotEmpty ? 'Type the amount as a number' : p,
    ];
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
        title: Text(_d.isNew ? 'Save this levy?' : 'Save the changes?'),
        content: Text([
          '${_d.truck?.name ?? ''} · ${_d.rti?.name ?? ''}',
          Fmt.rm(_d.amount),
          if (_photos.isNotEmpty) '${_photos.length} photos',
        ].join('\n')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          FilledButton(
              key: const ValueKey('levy-confirm'), onPressed: () => Navigator.pop(c, true), child: const Text('Save')),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => _saving = true);
    try {
      final saved = await widget.api.save(_d.toJson(companyId: widget.api.companyId, employeeId: _employeeId()));
      String? fileError;
      if (_photos.isNotEmpty) {
        try {
          await widget.files.add(_photos, folder: levyFolder, recordId: saved.id);
        } catch (e) {
          fileError = '$e';
        }
      }
      if (!mounted) return;
      final number = saved.number.isEmpty ? 'the levy' : saved.number;
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

  InputDecoration _dec(String label, {IconData? icon}) => InputDecoration(
        labelText: label,
        isDense: true,
        prefixIcon: icon == null ? null : Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      );

  Future<void> _choose(String title, List<Option> list, Option? current, ValueChanged<Option> set) async {
    final o = await pickOption(context, title: title, options: list, selected: current);
    if (o != null && o.id >= 0) setState(() => set(o));
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.editId != null ? 'Edit ${_d.number.isEmpty ? 'levy' : _d.number}' : 'New levy';
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
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
                      children: [
                        if (_lookupErrors.isNotEmpty) InfoBanner(color: Palette.amberGold, lines: _lookupErrors),
                        _levyPanel(),
                        const SizedBox(height: 12),
                        _amountPanel(),
                        const SizedBox(height: 12),
                        _filesPanel(),
                      ],
                    ),
                  ),
                  _bottomBar(),
                ]),
    );
  }

  Widget _levyPanel() => Panel(
        title: 'Levy',
        icon: Icons.local_shipping_outlined,
        trailing: SoftChip(text: _d.number.isEmpty ? 'New' : _d.number),
        child: Column(children: [
          DateField(
              key: const ValueKey('levy-date'),
              label: 'Date',
              value: _d.date,
              onTap: () async {
                final v = await showDatePicker(
                    context: context,
                    initialDate: _d.date,
                    firstDate: DateTime(2015),
                    lastDate: DateTime(Fmt.today().year + 2));
                if (v != null) setState(() => _d.date = v);
              }),
          const SizedBox(height: 10),
          PickField(
            key: const ValueKey('levy-truck'),
            label: 'Truck',
            required: true,
            value: _d.truck?.name,
            icon: Icons.local_shipping_outlined,
            onTap: () => _choose('Truck', _withCurrent(_trucks, _d.truck), _d.truck, (o) => _d.truck = o),
          ),
          PickField(
            key: const ValueKey('levy-driver'),
            label: 'Driver',
            required: true,
            value: _d.driver?.name,
            icon: Icons.badge_outlined,
            onTap: () => _choose('Driver', _withCurrent(_drivers, _d.driver), _d.driver, (o) => _d.driver = o),
          ),
          PickField(
            key: const ValueKey('levy-rti'),
            label: 'RTI no',
            required: true,
            value: _d.rti?.name,
            icon: Icons.receipt_outlined,
            onTap: () => _choose('RTI no', _withCurrent(_rtis, _d.rti), _d.rti, (o) => _d.rti = o),
          ),
          TextPickField(
            key: const ValueKey('levy-enter'),
            label: 'Enter link',
            icon: Icons.login,
            value: _d.enterLink,
            options: const ['', ...levyEnterLinks],
            labelOf: (v) => v.isEmpty ? 'Not set' : v,
            onChanged: (v) => setState(() => _d.enterLink = v),
          ),
          TextPickField(
            key: const ValueKey('levy-exit'),
            label: 'Exit link',
            icon: Icons.logout,
            value: _d.exitLink,
            options: const ['', ...levyExitLinks],
            labelOf: (v) => v.isEmpty ? 'Not set' : v,
            onChanged: (v) => setState(() => _d.exitLink = v),
          ),
        ]),
      );

  /// The saved choice stays in the list even when it is no longer offered (web does the same).
  static List<Option> _withCurrent(List<Option> list, Option? current) =>
      current == null || list.contains(current) ? list : [current, ...list];

  Widget _amountPanel() => Panel(
        title: 'Amount',
        icon: Icons.payments_outlined,
        child: Column(children: [
          TextField(
            key: const ValueKey('levy-amount'),
            controller: _amount,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: _dec('Amount (RM) *', icon: Icons.payments_outlined),
            onChanged: (_) => setState(_readText),
          ),
          const SizedBox(height: 10),
          TextField(
            key: const ValueKey('levy-remarks'),
            controller: _remarks,
            maxLines: 3,
            minLines: 2,
            maxLength: levyRemarksMax,
            decoration: _dec('Remarks'),
          ),
        ]),
      );

  Widget _filesPanel() => Panel(
        title: 'Photos and files',
        icon: Icons.photo_library_outlined,
        trailing: SoftChip(text: '${_saved.length + _photos.length}'),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          if (_saved.isNotEmpty) ...[
            RecordFilesGrid(files: _saved),
            const SizedBox(height: 10),
          ],
          if (_photos.isNotEmpty) ...[
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
            const SizedBox(height: 4),
            Text('New photos upload when you save.', style: AppTypography.bodySmall(color: AppTokens.textMuted)),
            const SizedBox(height: 8),
          ],
          if (_saved.isEmpty && _photos.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(_d.isNew ? 'Add a photo of the levy receipt.' : 'No files yet.',
                  style: AppTypography.bodySmall(color: AppTokens.textMuted)),
            ),
          Wrap(spacing: 8, runSpacing: 8, children: [
            OutlinedButton.icon(
                key: const ValueKey('levy-photo-camera'),
                onPressed: () => _addPhoto(ImageSource.camera),
                icon: const Icon(Icons.photo_camera_outlined, size: 18),
                label: const Text('Camera')),
            OutlinedButton.icon(
                key: const ValueKey('levy-photo-gallery'),
                onPressed: () => _addPhoto(ImageSource.gallery),
                icon: const Icon(Icons.photo_library_outlined, size: 18),
                label: const Text('Gallery')),
          ]),
        ]),
      );

  Widget _bottomBar() => SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          decoration: const BoxDecoration(
              color: AppTokens.surfaceCard, border: Border(top: BorderSide(color: AppTokens.surfaceBorder))),
          child: Row(children: [
            Expanded(
              child: Text(Fmt.rm(_d.amount ?? 0),
                  key: const ValueKey('levy-total'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodyLarge(color: AppTokens.textPrimary, fontWeight: FontWeight.w800)),
            ),
            const SizedBox(width: 8),
            FilledButton.icon(
                key: const ValueKey('levy-save'),
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.save_outlined),
                label: const Text('Save')),
          ]),
        ),
      );
}
