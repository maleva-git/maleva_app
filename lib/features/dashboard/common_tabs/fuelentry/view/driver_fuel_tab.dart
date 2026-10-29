import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/di/injection.dart';
import 'package:maleva/core/files/attachments_api.dart';
import 'package:maleva/core/fuel/fuel_entry_api.dart';
import 'package:maleva/core/utils/dialog_helper.dart';
import 'package:maleva/core/utils/json_read.dart';
import 'package:maleva/core/ui/premium.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../bloc/fuelentry_bloc.dart';
import '../bloc/fuelentry_event.dart';
import '../bloc/fuelentry_state.dart';
import '../data/fuelentry_repository.dart';
import '../models/fuelentry_model.dart';
import 'driver_fuel_receipt.dart';

/// The driver's language choice, kept by the Today tab (today_trips_tab.dart `_malayKey`).
const _malayKey = 'today_trips_malay_v1';

/// Litres and amount a driver may type for one fill (a lorry tank is well under 1,000 L).
const double driverFuelMaxLitres = 1000;
const double driverFuelMaxAmount = 5000;

/// Why the driver's fill cannot be saved, or null when it can. Pure (tested).
String? driverFuelProblem({required String litres, required String amount}) {
  final l = double.tryParse(litres.trim());
  final a = double.tryParse(amount.trim());
  if (l == null || l <= 0) return 'Type the litres';
  if (l > driverFuelMaxLitres) return 'Litres look too high (max ${driverFuelMaxLitres.toInt()})';
  if (a == null || a <= 0) return 'Type the amount (RM)';
  if (a > driverFuelMaxAmount) return 'Amount looks too high (max RM ${driverFuelMaxAmount.toInt()})';
  return null;
}

/// "RM 2.15 per litre" from what was typed; "" when it cannot be worked out.
String driverFuelRate({required String litres, required String amount}) {
  final l = double.tryParse(litres.trim());
  final a = double.tryParse(amount.trim());
  if (l == null || a == null || l <= 0 || a <= 0) return '';
  return 'RM ${(a / l).toStringAsFixed(2)} per litre';
}

/// The month's fills added up: (fills, litres, RM).
({int fills, double litres, double amount}) driverFuelTotals(List<FuelEntryModel> entries) => (
      fills: entries.length,
      litres: entries.fold(0.0, (s, e) => s + e.aLiter),
      amount: entries.fold(0.0, (s, e) => s + e.aAmount),
    );

/// The driver's Fuel tab (owner 2026-10-28: "add the fuel entry in the easy way"): one big ADD FUEL button, a short
/// form (date, litres, amount), and this month's own fills. The server puts the driver's own truck on the entry and
/// numbers it (DriverFuelPolicy); a driver sees and changes only their own app entries.
class DriverFuelTab extends StatelessWidget {
  const DriverFuelTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FuelEntryBloc(repository: FuelEntryRepositoryImpl()),
      child: const _DriverFuelView(),
    );
  }
}

class _DriverFuelView extends StatefulWidget {
  const _DriverFuelView();

  @override
  State<_DriverFuelView> createState() => _DriverFuelViewState();
}

class _DriverFuelViewState extends State<_DriverFuelView> {
  static final _iso = DateFormat('yyyy-MM-dd');
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final first = DateTime(_month.year, _month.month, 1);
    final last = DateTime(_month.year, _month.month + 1, 0);
    context.read<FuelEntryBloc>().add(LoadFuelEntries(_iso.format(first), _iso.format(last)));
  }

  void _openForm([FuelEntryModel? entry]) {
    final bloc = context.read<FuelEntryBloc>();
    final state = bloc.state;
    final mine = state is FuelEntryLoaded ? state.entries : const <FuelEntryModel>[];
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => BlocProvider.value(value: bloc, child: DriverFuelForm(entry: entry, mine: mine, onSaved: _load)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final thisMonth = _month.year == now.year && _month.month == now.month;
    return Scaffold(
      backgroundColor: Px.page,
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'driver-add-fuel',
        backgroundColor: Px.brand,
        elevation: 3,
        shape: const StadiumBorder(),
        onPressed: () => _openForm(),
        icon: const Icon(Icons.local_gas_station_rounded, color: Colors.white),
        label: Text('ADD FUEL', style: Px.t(15, weight: FontWeight.w800, color: Colors.white, spacing: 0.4)),
      ),
      body: BlocConsumer<FuelEntryBloc, FuelEntryState>(
        listener: (context, state) {
          if (state is FuelEntryActionSuccess) toastMsg(state.message, '', context);
          if (state is FuelEntryError) toastMsg(state.message, '', context);
        },
        builder: (context, state) {
          final entries = state is FuelEntryLoaded ? state.entries : const <FuelEntryModel>[];
          final totals = driverFuelTotals(entries);
          final noReceipt = entries.where((e) => e.filePath.trim().isEmpty).length;
          return RefreshIndicator(
            onRefresh: () async => _load(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 100),
              children: [
                // month switcher: a white pill with arrows
                Container(
                  decoration:
                      BoxDecoration(color: Px.card, borderRadius: BorderRadius.circular(999), border: Border.all(color: Px.line)),
                  child: Row(children: [
                    IconButton(
                      tooltip: 'Previous month',
                      icon: const Icon(Icons.chevron_left_rounded, color: Px.brand),
                      onPressed: () {
                        setState(() => _month = DateTime(_month.year, _month.month - 1));
                        _load();
                      },
                    ),
                    Expanded(
                      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        const Icon(Icons.calendar_month_rounded, size: 18, color: Px.brand),
                        const SizedBox(width: 8),
                        Text(DateFormat('MMMM yyyy').format(_month), style: Px.t(15, weight: FontWeight.w700)),
                      ]),
                    ),
                    IconButton(
                      tooltip: 'Next month',
                      icon: Icon(Icons.chevron_right_rounded, color: thisMonth ? Px.muted : Px.brand),
                      onPressed: thisMonth
                          ? null
                          : () {
                              setState(() => _month = DateTime(_month.year, _month.month + 1));
                              _load();
                            },
                    ),
                  ]),
                ),
                const SizedBox(height: 14),
                PHero(
                  label: 'Fuel this month',
                  value: 'RM ${NumberFormat('#,##0.00').format(totals.amount)}',
                  footnote: totals.litres > 0
                      ? 'Average RM ${(totals.amount / totals.litres).toStringAsFixed(2)} per litre'
                      : 'No fuel saved this month',
                  icon: Icons.local_gas_station_rounded,
                ),
                const SizedBox(height: 10),
                PStatRow(children: [
                  PStat(label: 'Fills', value: '${totals.fills}', icon: Icons.receipt_long_rounded, tone: Tone.blue),
                  PStat(
                      label: 'Litres',
                      value: NumberFormat('#,##0.#').format(totals.litres),
                      icon: Icons.water_drop_rounded,
                      tone: Tone.green),
                  PStat(
                    label: 'No receipt',
                    value: '$noReceipt',
                    icon: Icons.photo_camera_rounded,
                    tone: noReceipt == 0 ? Tone.green : Tone.red,
                  ),
                ]),
                const PSection('Your fills', subtitle: 'Tap a fill to change it'),
                if (state is FuelEntryLoading)
                  const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator(color: Px.brand))),
                if (state is FuelEntryLoaded && entries.isEmpty)
                  const PCard(
                    child: PEmpty(
                      icon: Icons.local_gas_station_rounded,
                      title: 'No fuel this month',
                      subtitle: 'Tap ADD FUEL after you fill the tank.',
                    ),
                  ),
                for (final e in entries)
                  PCard(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
                    onTap: () => _openForm(e),
                    child: Row(children: [
                      const PIcon(Icons.local_gas_station_rounded, size: 42),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('${NumberFormat('#,##0.##').format(e.aLiter)} L',
                              style: Px.t(17, weight: FontWeight.w800, spacing: -0.3)),
                          const SizedBox(height: 2),
                          Text([e.entryDate, e.entryNo].where((s) => s.trim().isNotEmpty).join('  ·  '), style: Px.small),
                          if (e.remarks.trim().isNotEmpty)
                            Text(e.remarks.trim(), maxLines: 1, overflow: TextOverflow.ellipsis, style: Px.small),
                        ]),
                      ),
                      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Text('RM ${NumberFormat('#,##0.00').format(e.aAmount)}', style: Px.t(15, weight: FontWeight.w800)),
                        const SizedBox(height: 6),
                        e.filePath.trim().isEmpty
                            ? const PChip('No receipt', tone: Tone.red, dot: true)
                            : const PChip('Receipt', tone: Tone.green, dot: true),
                      ]),
                    ]),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// The short fuel form: date, litres, amount (RM), remarks. Big fields, number keypad.
class DriverFuelForm extends StatefulWidget {
  const DriverFuelForm({super.key, this.entry, this.mine = const [], this.onSaved});

  final FuelEntryModel? entry;

  /// The driver's fills of the month, for the "second fill today?" question.
  final List<FuelEntryModel> mine;

  /// Called after a save (the list reloads).
  final VoidCallback? onSaved;

  @override
  State<DriverFuelForm> createState() => _DriverFuelFormState();
}

class _DriverFuelFormState extends State<DriverFuelForm> {
  static final _shown = DateFormat('dd/MM/yyyy');
  late DateTime _date;
  late final TextEditingController _litres;
  late final TextEditingController _amount;
  late final TextEditingController _remarks;
  String? _problem;

  /// Engine while filling: null = not chosen (not sent), true on, false off.
  bool? _engineOn;

  /// Fuel card: null = not chosen (not sent), '' = no card / cash, else the code.
  String? _card;
  List<String> _cards = const [];

  /// The receipt photo taken now (required for a new fill and an old one without a receipt).
  File? _photo;
  bool _busy = false;
  String? _busyText;

  /// Set when the fill is saved but its photo was not sent: TRY AGAIN sends only the photo.
  int _savedId = 0;
  FuelText _t = const FuelText(false);

  @override
  void initState() {
    super.initState();
    final e = widget.entry;
    _date = DateTime.now();
    if (e != null && e.entryDate.isNotEmpty) {
      try {
        _date = _shown.parseStrict(e.entryDate);
      } catch (_) {}
    }
    _litres = TextEditingController(text: e == null || e.aLiter == 0 ? '' : e.aLiter.toString());
    _amount = TextEditingController(text: e == null || e.aAmount == 0 ? '' : e.aAmount.toString());
    _remarks = TextEditingController(text: e?.remarks ?? '');
    _engineOn = e?.engineOn;
    _card = e?.cardCode;
    sl<FuelEntryApi>().cards().then((list) {
      if (mounted) setState(() => _cards = list.take(12).toList());
    });
    SharedPreferences.getInstance().then((prefs) {
      if (mounted) setState(() => _t = FuelText(prefs.getBool(_malayKey) ?? false));
    });
  }

  Future<void> _takePhoto(ImageSource source) async {
    try {
      final picked = await ImagePicker().pickImage(source: source, imageQuality: 70, maxWidth: 1600);
      if (picked != null && mounted) {
        setState(() {
          _photo = File(picked.path);
          _problem = null;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _problem = _t.photoMissing);
    }
  }

  @override
  void dispose() {
    _litres.dispose();
    _amount.dispose();
    _remarks.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: now.subtract(const Duration(days: 30)),
      lastDate: now,
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    if (_savedId > 0) return _sendPhoto(_savedId); // the fill is saved: only the photo is left
    final problem = driverFuelProblem(litres: _litres.text, amount: _amount.text);
    if (problem != null) {
      setState(() => _problem = problem);
      return;
    }
    if (_photo == null && needsReceiptPhoto(widget.entry)) {
      setState(() => _problem = _t.photoMissing);
      return;
    }
    final day = _shown.format(_date);
    final others = sameDayFills(widget.mine, day, excludeId: widget.entry?.id ?? 0);
    if (others.isNotEmpty && !await _askSecondFill(others)) return;

    final model = widget.entry ?? FuelEntryModel();
    model.entryDate = day;
    model.aLiter = double.parse(_litres.text.trim());
    model.aAmount = double.parse(_amount.text.trim());
    model.remarks = _remarks.text.trim();
    model.engineOn = _engineOn;
    model.cardCode = _card;
    setState(() {
      _busy = true;
      _busyText = _t.saving;
      _problem = null;
    });
    int id;
    try {
      id = JsonRead.integer((await sl<FuelEntryApi>().save(model.toJava()))['id']);
    } catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _problem = e.toString();
        });
      }
      return;
    }
    if (_photo == null) return _done();
    await _sendPhoto(id);
  }

  Future<void> _sendPhoto(int id) async {
    setState(() {
      _busy = true;
      _busyText = _t.sendingPhoto;
      _problem = null;
    });
    try {
      await sl<AttachmentsApi>().add([_photo!],
          folder: fuelReceiptFolder, recordId: id, mode: AttachmentMode.imagesOnly, filePathTable: fuelReceiptTable);
      _done();
    } catch (_) {
      if (mounted) {
        setState(() {
          _busy = false;
          _savedId = id;
          _problem = _t.photoFailed;
        });
      }
      widget.onSaved?.call();
    }
  }

  void _done() {
    widget.onSaved?.call();
    if (mounted) {
      toastMsg('Saved successfully', '', context);
      Navigator.pop(context);
    }
  }

  Future<bool> _askSecondFill(List<FuelEntryModel> others) async =>
      await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          title: Text(_t.sameDayTitle(others.length)),
          content: Text(_t.sameDayBody(others)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c, false), child: Text(_t.cancel)),
            ElevatedButton(onPressed: () => Navigator.pop(c, true), child: Text(_t.saveAnyway)),
          ],
        ),
      ) ??
      false;

  Widget _receipt() {
    final needed = needsReceiptPhoto(widget.entry);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _photo != null ? Px.greenSoft : Px.amberSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: (_photo != null ? Px.green : Px.amber).withValues(alpha: 0.25)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          PIcon(_photo != null ? Icons.check_circle_rounded : Icons.receipt_long_rounded,
              tone: _photo != null ? Tone.green : Tone.amber, size: 34),
          const SizedBox(width: 10),
          Expanded(
            child: Text(_photo != null ? _t.photoReady : _t.photoTitle,
                style: Px.t(15, weight: FontWeight.w800, color: _photo != null ? Px.green : Px.amber)),
          ),
        ]),
        if (_photo == null && needed) ...[
          const SizedBox(height: 6),
          for (var i = 0; i < _t.photoSteps.length; i++)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text('${i + 1}. ${_t.photoSteps[i]}', style: Px.t(14, weight: FontWeight.w500, height: 1.35)),
            ),
        ],
        if (_photo == null && !needed)
          Padding(padding: const EdgeInsets.only(top: 6), child: Text(_t.photoOnFile, style: Px.t(14))),
        if (_photo != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(_photo!, height: 140, width: double.infinity, fit: BoxFit.cover),
            ),
          ),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(
            child: SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Px.brand, elevation: 0, shape: const StadiumBorder()),
                onPressed: _busy || _savedId > 0 ? null : () => _takePhoto(ImageSource.camera),
                icon: const Icon(Icons.photo_camera, color: Colors.white),
                label: Text(_photo == null ? _t.takePhoto : _t.retake,
                    overflow: TextOverflow.ellipsis, style: Px.t(14, weight: FontWeight.w800, color: Colors.white)),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: TextButton(
              onPressed: _busy || _savedId > 0 ? null : () => _takePhoto(ImageSource.gallery),
              child: Text(_t.fromGallery,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: Px.t(13, weight: FontWeight.w700, color: Px.brand)),
            ),
          ),
        ]),
      ]),
    );
  }

  InputDecoration _box(String label, {String? suffix, IconData? icon}) => InputDecoration(
        labelText: label,
        labelStyle: Px.t(14, color: Px.sub),
        suffixText: suffix,
        suffixStyle: Px.t(14, weight: FontWeight.w700, color: Px.sub),
        prefixIcon: icon == null ? null : Icon(icon, color: Px.brand),
        filled: true,
        fillColor: Px.soft,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Px.line)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Px.line)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Px.brand, width: 1.5)),
      );

  @override
  Widget build(BuildContext context) {
    final number = [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))];
    final rate = driverFuelRate(litres: _litres.text, amount: _amount.text);
    // Scrolls: with the receipt guide the form is taller than a small phone (owner screenshot 2026-10-29, 58 px overflow).
    final chips = Theme.of(context).chipTheme.copyWith(
          backgroundColor: Px.soft,
          selectedColor: Px.brandSoft,
          checkmarkColor: Px.brand,
          side: const BorderSide(color: Px.line),
          shape: const StadiumBorder(),
          labelStyle: Px.t(14, weight: FontWeight.w600),
          secondaryLabelStyle: Px.t(14, weight: FontWeight.w700, color: Px.brand),
        );
    return Theme(
      data: Theme.of(context).copyWith(chipTheme: chips),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(18, 18, 18, MediaQuery.of(context).viewInsets.bottom + 18),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Center(
            child: Container(
                width: 40, height: 4, decoration: BoxDecoration(color: Px.line, borderRadius: BorderRadius.circular(99))),
          ),
          const SizedBox(height: 14),
          Row(children: [
            const PIcon(Icons.local_gas_station_rounded, size: 44),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(widget.entry == null ? 'Add fuel' : 'Change fuel ${widget.entry!.entryNo}',
                    style: Px.t(20, weight: FontWeight.w800, spacing: -0.3)),
                Text('Your truck is filled in by the office record.', style: Px.small),
              ]),
            ),
          ]),
          const SizedBox(height: 14),
          InkWell(
            onTap: _pickDate,
            child: InputDecorator(
                decoration: _box('Date', icon: Icons.event_rounded),
                child: Text(_shown.format(_date), style: Px.t(16, weight: FontWeight.w700))),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _litres,
            autofocus: widget.entry == null,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: number,
            style: Px.t(20, weight: FontWeight.w800),
            decoration: _box('Litres', suffix: 'L', icon: Icons.water_drop),
            onChanged: (_) => setState(() => _problem = null),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _amount,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: number,
            style: Px.t(20, weight: FontWeight.w800),
            decoration: _box('Amount', suffix: 'RM', icon: Icons.payments),
            onChanged: (_) => setState(() => _problem = null),
          ),
          if (rate.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 6, left: 4), child: Text(rate, style: Px.small)),
          const SizedBox(height: 12),
          Text('Engine while filling', style: Px.t(13, weight: FontWeight.w700, color: Px.sub)),
          const SizedBox(height: 4),
          Wrap(spacing: 8, children: [
            ChoiceChip(
                label: const Text('Engine off'),
                selected: _engineOn == false,
                onSelected: (_) => setState(() => _engineOn = false)),
            ChoiceChip(
                label: const Text('Engine on'), selected: _engineOn == true, onSelected: (_) => setState(() => _engineOn = true)),
          ]),
          const SizedBox(height: 10),
          Text('Fuel card', style: Px.t(13, weight: FontWeight.w700, color: Px.sub)),
          const SizedBox(height: 4),
          Wrap(spacing: 8, runSpacing: 4, children: [
            ChoiceChip(label: const Text('No card / cash'), selected: _card == '', onSelected: (_) => setState(() => _card = '')),
            for (final c in {..._cards, if ((_card ?? '').isNotEmpty) _card!})
              ChoiceChip(label: Text(c), selected: _card == c, onSelected: (_) => setState(() => _card = c)),
          ]),
          const SizedBox(height: 12),
          TextField(controller: _remarks, style: Px.body, decoration: _box('Remarks (optional)', icon: Icons.notes_rounded)),
          const SizedBox(height: 12),
          _receipt(),
          if (_problem != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(_problem!, style: Px.t(14, weight: FontWeight.w700, color: Px.red)),
            ),
          const SizedBox(height: 16),
          SizedBox(
            height: 54,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Px.brand, elevation: 0, shape: const StadiumBorder()),
              onPressed: _busy ? null : _save,
              icon: _busy
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Icon(_savedId > 0 ? Icons.refresh : Icons.check, color: Colors.white),
              label: Text(_busy ? (_busyText ?? '') : (_savedId > 0 ? _t.tryAgain : 'SAVE'),
                  style: Px.t(17, weight: FontWeight.w800, color: Colors.white, spacing: 0.4)),
            ),
          ),
        ]),
      ),
    );
  }
}
