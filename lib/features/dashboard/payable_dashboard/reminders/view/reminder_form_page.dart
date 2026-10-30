import 'dart:async';

import 'package:flutter/material.dart';
import 'package:maleva/core/theme/app_typography.dart';
import 'package:maleva/core/theme/palette.dart';
import 'package:maleva/core/theme/tokens.dart';

import '../../records/view/record_style.dart';
import '../data/reminder_models.dart';
import '../data/reminders_api.dart';
import 'reminder_look.dart';

/// The team's own list from the scan: quick picks for a new reminder.
const reminderQuickPicks = [('Print TNG invoice', 3), ('Port charges payment', 5), ('Print Konica invoice', 10)];

/// Add or change a reminder (change `payable-reminders`): what, every month on a day (or once), the time, what happens
/// on a weekend / holiday, who, from / to month, follow-up, note. The "Next:" line comes from the server's own rules.
class ReminderFormPage extends StatefulWidget {
  const ReminderFormPage({super.key, required this.api, this.edit, this.startDay});

  final RemindersApi api;
  final ReminderItem? edit;

  /// The calendar day the person was on (its day of month is offered for a new reminder).
  final DateTime? startDay;

  @override
  State<ReminderFormPage> createState() => _ReminderFormPageState();
}

class _ReminderFormPageState extends State<ReminderFormPage> {
  late final ReminderForm _f = widget.edit == null
      ? ReminderForm(dayOfMonth: widget.startDay?.day)
      : ReminderForm.of(widget.edit!);
  late final _title = TextEditingController(text: _f.title);
  late final _notes = TextEditingController(text: _f.notes);
  List<ReminderPerson> _people = const [];
  List<ReminderDay> _next = const [];
  String? _nextError;
  Timer? _debounce;
  bool _saving = false;

  bool get _isEdit => widget.edit != null;

  @override
  void initState() {
    super.initState();
    _loadPeople();
    _changed();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _title.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _loadPeople() async {
    try {
      final p = await widget.api.people();
      if (mounted) setState(() => _people = p);
    } catch (_) {}
  }

  /// Something changed: ask the server for the next days a moment later.
  void _changed() {
    _f
      ..title = _title.text
      ..notes = _notes.text;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), _preview);
  }

  Future<void> _preview() async {
    final f = ReminderForm.of(_snapshot())..title = _f.title.trim().isEmpty ? 'x' : _f.title;
    if (f.problems().isNotEmpty) {
      if (mounted) setState(() => _next = const []);
      return;
    }
    try {
      final n = await widget.api.preview(f);
      if (mounted) {
        setState(() {
          _next = n;
          _nextError = null;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _nextError = '$e');
    }
  }

  ReminderItem _snapshot() => ReminderItem(
        id: widget.edit?.id ?? 0,
        title: _f.title,
        notes: _f.notes,
        repeat: _f.repeat,
        dayOfMonth: _f.dayOfMonth,
        onDate: _f.onDate,
        time: _f.time,
        whenOffDay: _f.whenOffDay,
        audience: _f.audience,
        people: _f.people,
        fromMonth: _f.fromMonth ?? '',
        toMonth: _f.toMonth ?? '',
        paused: _f.paused,
        followUp: _f.followUp,
        nextDue: null,
        nextPlanned: null,
      );

  Future<void> _save() async {
    _f
      ..title = _title.text
      ..notes = _notes.text;
    final problems = _f.problems();
    if (problems.isNotEmpty) {
      await showDialog<void>(
        context: context,
        builder: (c) => AlertDialog(
          title: const Text('Please check'),
          content: Text(problems.join('\n')),
          actions: [FilledButton(onPressed: () => Navigator.pop(c), child: const Text('OK'))],
        ),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      if (_isEdit) {
        await widget.api.update(widget.edit!.id, _f);
      } else {
        await widget.api.create(_f);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_isEdit ? 'Reminder changed' : 'Reminder added')));
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Not saved: $e')));
      }
    }
  }

  Future<void> _pickTime() async {
    final p = _f.time.split(':');
    final t = await showTimePicker(
        context: context, initialTime: TimeOfDay(hour: int.tryParse(p[0]) ?? 9, minute: int.tryParse(p.elementAtOrNull(1) ?? '0') ?? 0));
    if (t == null) return;
    setState(() => _f.time = '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}');
    _changed();
  }

  Future<String?> _pickMonth(String? current) async {
    final now = DateTime.now();
    final init = current == null ? now : DateTime.tryParse('$current-01') ?? now;
    final d = await showDatePicker(
        context: context, initialDate: init, firstDate: DateTime(now.year - 1), lastDate: DateTime(now.year + 5), helpText: 'Any day of the month');
    return d == null ? null : ym(d);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTokens.surfacePage,
      appBar: AppBar(
        backgroundColor: AppTokens.brandGradientStart,
        foregroundColor: AppTokens.textOnDark,
        title: Text(_isEdit ? 'Edit reminder' : 'Add reminder',
            style: AppTypography.bodyLarge(color: AppTokens.textOnDark, fontWeight: FontWeight.w700)),
      ),
      body: ListView(padding: const EdgeInsets.fromLTRB(12, 12, 12, 24), children: [
        Panel(
          title: 'What',
          icon: Icons.alarm,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            if (!_isEdit)
              Wrap(spacing: 6, runSpacing: 6, children: [
                for (final (t, d) in reminderQuickPicks)
                  ActionChip(
                    key: ValueKey('rem-pick-$d'),
                    avatar: const Icon(Icons.bolt, size: 16),
                    label: Text('$t (${ordinal(d)})'),
                    onPressed: () {
                      _title.text = t;
                      setState(() {
                        _f
                          ..repeat = 'MONTHLY'
                          ..dayOfMonth = d;
                      });
                      _changed();
                    },
                  ),
              ]),
            if (!_isEdit) const SizedBox(height: 10),
            TextField(
              key: const ValueKey('rem-title'),
              controller: _title,
              maxLength: 120,
              onChanged: (_) => _changed(),
              decoration: InputDecoration(
                  labelText: 'What to remember *', isDense: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
            ),
            TextField(
              controller: _notes,
              maxLength: 500,
              maxLines: 2,
              onChanged: (_) => _changed(),
              decoration: InputDecoration(
                  labelText: 'Note (shown in the notice)', isDense: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
            ),
          ]),
        ),
        const SizedBox(height: 12),
        Panel(
          title: 'When',
          icon: Icons.event_repeat,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'MONTHLY', label: Text('Every month'), icon: Icon(Icons.repeat)),
                ButtonSegment(value: 'ONCE', label: Text('Once'), icon: Icon(Icons.looks_one_outlined)),
              ],
              selected: {_f.repeat},
              onSelectionChanged: (s) {
                setState(() => _f.repeat = s.first);
                _changed();
              },
            ),
            const SizedBox(height: 12),
            if (_f.repeat == 'MONTHLY') ...[
              Text('Day of the month', style: AppTypography.bodySmall(color: AppTokens.textMuted)),
              const SizedBox(height: 6),
              GridView.count(
                crossAxisCount: 7,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
                childAspectRatio: 1.3,
                children: [
                  for (var d = 1; d <= 31; d++)
                    InkWell(
                      key: ValueKey('rem-dom-$d'),
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {
                        setState(() => _f.dayOfMonth = d);
                        _changed();
                      },
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _f.dayOfMonth == d ? AppTokens.brandPrimary : AppTokens.surfacePage,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(d == 31 ? 'Last' : '$d',
                            style: AppTypography.bodySmall(
                                color: _f.dayOfMonth == d ? Colors.white : AppTokens.textPrimary, fontWeight: FontWeight.w700)),
                      ),
                    ),
                ],
              ),
              Text('29, 30 and Last fall on the last day of a short month.', style: AppTypography.badgeText(color: AppTokens.textMuted)),
            ] else
              OutlinedButton.icon(
                key: const ValueKey('rem-once-date'),
                onPressed: () async {
                  final now = DateTime.now();
                  final d = await showDatePicker(
                      context: context, initialDate: _f.onDate ?? now, firstDate: DateTime(now.year, now.month, now.day), lastDate: DateTime(now.year + 3));
                  if (d != null) {
                    setState(() => _f.onDate = d);
                    _changed();
                  }
                },
                icon: const Icon(Icons.event),
                label: Text(_f.onDate == null ? 'Choose the date' : dayName(_f.onDate!)),
              ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
                key: const ValueKey('rem-time'),
                onPressed: _pickTime,
                icon: const Icon(Icons.schedule),
                label: Text('At ${timeLabel(_f.time)}')),
            const SizedBox(height: 12),
            Text('On a weekend or public holiday', style: AppTypography.bodySmall(color: AppTokens.textMuted)),
            const SizedBox(height: 6),
            Wrap(spacing: 6, runSpacing: 6, children: [
              for (final (v, l) in const [('BEFORE', 'Working day before'), ('SAME', 'Same day'), ('AFTER', 'Next working day')])
                ChoiceChip(
                  key: ValueKey('rem-off-$v'),
                  label: Text(l),
                  selected: _f.whenOffDay == v,
                  onSelected: (_) {
                    setState(() => _f.whenOffDay = v);
                    _changed();
                  },
                ),
            ]),
            if (_f.repeat == 'MONTHLY') ...[
              const SizedBox(height: 12),
              Wrap(spacing: 8, runSpacing: 8, children: [
                OutlinedButton.icon(
                    onPressed: () async {
                      final m = await _pickMonth(_f.fromMonth);
                      if (m != null) {
                        setState(() => _f.fromMonth = m);
                        _changed();
                      }
                    },
                    icon: const Icon(Icons.play_arrow, size: 18),
                    label: Text('From ${_f.fromMonth ?? 'this month'}')),
                OutlinedButton.icon(
                    onPressed: () async {
                      final m = await _pickMonth(_f.toMonth);
                      if (m != null) {
                        setState(() => _f.toMonth = m);
                        _changed();
                      }
                    },
                    icon: const Icon(Icons.stop, size: 18),
                    label: Text(_f.toMonth == null ? 'No end' : 'Until ${_f.toMonth}')),
                if (_f.toMonth != null)
                  TextButton(
                      onPressed: () {
                        setState(() => _f.toMonth = null);
                        _changed();
                      },
                      child: const Text('Remove end')),
              ]),
            ],
          ]),
        ),
        const SizedBox(height: 12),
        Panel(
          title: 'Who gets it',
          icon: Icons.groups_outlined,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'TEAM', label: Text('Payable + Accounts team')),
                ButtonSegment(value: 'PEOPLE', label: Text('Chosen people')),
              ],
              selected: {_f.audience},
              onSelectionChanged: (s) => setState(() => _f.audience = s.first),
            ),
            if (_f.audience == 'PEOPLE')
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: _people.isEmpty
                    ? Text('Loading people…', style: AppTypography.bodySmall(color: AppTokens.textMuted))
                    : Wrap(spacing: 6, runSpacing: 6, children: [
                        for (final p in _people)
                          FilterChip(
                            key: ValueKey('rem-person-${p.id}'),
                            label: Text(p.name),
                            selected: _f.people.contains(p.id),
                            onSelected: (on) => setState(() => on ? _f.people.add(p.id) : _f.people.remove(p.id)),
                          ),
                      ]),
              ),
            Material(
              type: MaterialType.transparency,
              child: Column(children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _f.followUp,
                  onChanged: (v) => setState(() => _f.followUp = v),
                  title: const Text('Remind every working morning until done'),
                ),
                if (_isEdit)
                  SwitchListTile(
                    key: const ValueKey('rem-paused'),
                    contentPadding: EdgeInsets.zero,
                    value: _f.paused,
                    onChanged: (v) => setState(() => _f.paused = v),
                    title: const Text('Paused (no notices)'),
                  ),
              ]),
            ),
          ]),
        ),
        const SizedBox(height: 12),
        Container(
          key: const ValueKey('rem-next-box'),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: AppTokens.brandLight, borderRadius: BorderRadius.circular(14)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Next', style: AppTypography.bodySmall(color: AppTokens.brandPrimary, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            if (_nextError != null)
              Text(_nextError!, style: AppTypography.bodySmall(color: Palette.redDanger))
            else if (_next.isEmpty)
              Text('Choose the day to see when it rings.', style: AppTypography.bodySmall(color: AppTokens.textMuted))
            else
              for (final n in _next)
                Text(
                    '• ${dayName(n.dueOn)}, ${timeLabel(n.time)}${n.moved ? '  (moved from ${dayName(n.planned!)})' : ''}',
                    style: AppTypography.bodyMedium(color: AppTokens.textPrimary, fontWeight: FontWeight.w600)),
          ]),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          key: const ValueKey('rem-save'),
          onPressed: _saving ? null : _save,
          icon: _saving
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.save_outlined),
          label: Text(_isEdit ? 'Save changes' : 'Add reminder'),
        ),
      ]),
    );
  }
}
