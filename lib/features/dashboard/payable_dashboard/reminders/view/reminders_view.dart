import 'package:flutter/material.dart';
import 'package:maleva/core/di/injection.dart';
import 'package:maleva/core/network/java_api_client.dart';
import 'package:maleva/core/theme/app_typography.dart';
import 'package:maleva/core/theme/palette.dart';
import 'package:maleva/core/theme/tokens.dart';

import '../../records/view/record_style.dart';
import '../data/reminder_models.dart';
import '../data/reminders_api.dart';
import 'reminder_form_page.dart';
import 'reminder_look.dart';

/// The payable team's reminders (scan items 5–6; change `payable-reminders`): a month calendar with a dot per reminder
/// (green done, amber due, red not done / missed, blue coming, grey paused), the chosen day's reminders with Done /
/// Undo, a reminder's sheet (Edit, Pause, Delete), Add, and the list of all reminders.
class RemindersView extends StatefulWidget {
  const RemindersView({super.key, this.api, this.initialDay, this.clock});

  final RemindersApi? api;

  /// The day to open on (a tapped notice's day); today when null.
  final DateTime? initialDay;
  final DateTime Function()? clock;

  @override
  State<RemindersView> createState() => _RemindersViewState();
}

class _RemindersViewState extends State<RemindersView> {
  late final RemindersApi _api = widget.api ?? RemindersApi(sl<JavaApiClient>().dio);
  late DateTime _selected;
  late DateTime _month;
  late Future<ReminderMonth> _data;
  bool _busy = false;

  DateTime get _now => (widget.clock ?? DateTime.now)();

  @override
  void initState() {
    super.initState();
    final d = widget.initialDay ?? _now;
    _selected = DateTime(d.year, d.month, d.day);
    _month = DateTime(d.year, d.month);
    _data = Future.sync(() => _api.calendar(ym(_month)));
  }

  void _reload() => setState(() => _data = Future.sync(() => _api.calendar(ym(_month))));

  void _shift(int months) => setState(() {
        _month = DateTime(_month.year, _month.month + months);
        final today = DateTime(_now.year, _now.month, _now.day);
        _selected = _month.year == today.year && _month.month == today.month ? today : _month;
        _data = Future.sync(() => _api.calendar(ym(_month)));
      });

  Future<void> _openForm({ReminderItem? edit, DateTime? day}) async {
    final saved = await Navigator.of(context).push<bool>(MaterialPageRoute(
      builder: (_) => ReminderFormPage(api: _api, edit: edit, startDay: day),
    ));
    if (saved == true) _reload();
  }

  Future<void> _run(Future<void> Function() action, String ok) async {
    setState(() => _busy = true);
    try {
      await action();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok)));
      _reload();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<ReminderItem?> _find(int id) async {
    try {
      return (await _api.list()).where((r) => r.id == id).firstOrNull;
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      return null;
    }
  }

  Future<void> _openItem(ReminderDay d) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      backgroundColor: AppTokens.surfaceCard,
      builder: (c) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(d.title, style: AppTypography.heading3(color: AppTokens.textPrimary)),
            const SizedBox(height: 4),
            Text('${dayName(d.dueOn)} · ${timeLabel(d.time)}${d.moved ? ' · moved from ${dayName(d.planned!)}' : ''}',
                style: AppTypography.bodySmall(color: AppTokens.textMuted)),
            if (d.notes.isNotEmpty) ...[const SizedBox(height: 8), Text(d.notes, style: AppTypography.bodyMedium(color: AppTokens.textPrimary))],
            const SizedBox(height: 8),
            Row(children: [
              _Pill(text: stateLabel(d.state), color: stateColor(d.state)),
              if (d.state == DayState.done && d.doneBy.isNotEmpty) ...[
                const SizedBox(width: 6),
                Flexible(child: Text('by ${d.doneBy}', style: AppTypography.bodySmall(color: AppTokens.textMuted))),
              ],
              if (d.followUps > 0) ...[
                const SizedBox(width: 6),
                Text('${d.followUps} follow-up${d.followUps == 1 ? '' : 's'}', style: AppTypography.bodySmall(color: AppTokens.textMuted)),
              ],
            ]),
            const SizedBox(height: 14),
            if (d.state == DayState.done)
              OutlinedButton.icon(
                  key: const ValueKey('rem-undo'),
                  onPressed: () => Navigator.pop(c, 'undo'),
                  icon: const Icon(Icons.undo),
                  label: const Text('Undo done (today only)'))
            else if (d.state != DayState.missed)
              FilledButton.icon(
                  key: const ValueKey('rem-done'),
                  onPressed: () => Navigator.pop(c, 'done'),
                  icon: const Icon(Icons.check),
                  label: const Text('Mark done')),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: [
              OutlinedButton.icon(
                  key: const ValueKey('rem-edit'),
                  onPressed: () => Navigator.pop(c, 'edit'),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Edit')),
              OutlinedButton.icon(
                  key: const ValueKey('rem-pause'),
                  onPressed: () => Navigator.pop(c, 'pause'),
                  icon: Icon(d.state == DayState.paused ? Icons.play_arrow : Icons.pause, size: 18),
                  label: Text(d.state == DayState.paused ? 'Resume' : 'Pause')),
              OutlinedButton.icon(
                  key: const ValueKey('rem-delete'),
                  style: OutlinedButton.styleFrom(foregroundColor: Palette.redDanger),
                  onPressed: () => Navigator.pop(c, 'delete'),
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Delete')),
            ]),
          ]),
        ),
      ),
    );
    if (!mounted || action == null) return;
    switch (action) {
      case 'done':
        await _run(() => _api.done(d.reminderId, d.dueOn), 'Marked done');
      case 'undo':
        await _run(() => _api.undo(d.reminderId, d.dueOn), 'Done undone');
      case 'edit':
        final r = await _find(d.reminderId);
        if (r != null && mounted) await _openForm(edit: r);
      case 'pause':
        final r = await _find(d.reminderId);
        if (r == null) return;
        final f = ReminderForm.of(r)..paused = !r.paused;
        await _run(() => _api.update(r.id, f), r.paused ? 'Resumed' : 'Paused: no notices until resumed');
      case 'delete':
        final ok = await showDialog<bool>(
          context: context,
          builder: (c) => AlertDialog(
            title: Text('Delete "${d.title}"?'),
            content: const Text('No more notices. Days already done stay in the history.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
              FilledButton(
                  key: const ValueKey('rem-delete-confirm'),
                  style: FilledButton.styleFrom(backgroundColor: Palette.redDanger),
                  onPressed: () => Navigator.pop(c, true),
                  child: const Text('Delete')),
            ],
          ),
        );
        if (ok == true) await _run(() => _api.delete(d.reminderId), 'Deleted');
    }
  }

  Future<void> _openAll() async {
    await Navigator.of(context).push<void>(MaterialPageRoute(builder: (_) => _AllReminders(api: _api, onEdit: (r) => _openForm(edit: r))));
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.sizeOf(context).width >= 600 ? 20.0 : 12.0;
    return Scaffold(
      backgroundColor: AppTokens.surfacePage,
      floatingActionButton: FloatingActionButton.extended(
        key: const ValueKey('rem-add'),
        onPressed: () => _openForm(day: _selected),
        icon: const Icon(Icons.add_alarm),
        label: const Text('Add reminder'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _reload();
          try {
            await _data;
          } catch (_) {}
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(pad, 8, pad, 96),
          children: [
            Row(children: [
              IconButton(key: const ValueKey('rem-prev'), onPressed: () => _shift(-1), icon: const Icon(Icons.chevron_left)),
              Expanded(
                  child: Text(monthName(_month),
                      textAlign: TextAlign.center, style: AppTypography.heading3(color: AppTokens.textPrimary))),
              IconButton(key: const ValueKey('rem-next'), onPressed: () => _shift(1), icon: const Icon(Icons.chevron_right)),
              IconButton(
                  key: const ValueKey('rem-all'), tooltip: 'All reminders', onPressed: _openAll, icon: const Icon(Icons.list_alt)),
            ]),
            if (_busy) const LinearProgressIndicator(minHeight: 2),
            FutureBuilder<ReminderMonth>(
              future: _data,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator()));
                }
                if (snap.hasError) {
                  return Panel(
                    child: Row(children: [
                      const Icon(Icons.error_outline, color: Palette.redDanger, size: 18),
                      const SizedBox(width: 8),
                      Expanded(child: Text('${snap.error}', style: AppTypography.bodySmall(color: Palette.redDanger))),
                      TextButton(onPressed: _reload, child: const Text('Retry')),
                    ]),
                  );
                }
                final m = snap.data!;
                return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Panel(
                    child: _MonthGrid(
                      month: _month,
                      data: m,
                      today: DateTime(_now.year, _now.month, _now.day),
                      selected: _selected,
                      onTap: (d) => setState(() => _selected = d),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const _Legend(),
                  const SizedBox(height: 12),
                  _dayList(m),
                ]);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _dayList(ReminderMonth m) {
    final items = m.on(_selected);
    return Panel(
      title: dayName(_selected),
      icon: Icons.event_note_outlined,
      trailing: SoftChip(text: '${items.length}'),
      child: items.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text('No reminder on this day.', style: AppTypography.bodySmall(color: AppTokens.textMuted)))
          : Material(
              type: MaterialType.transparency,
              child: Column(children: [
                for (final d in items)
                  ListTile(
                    key: ValueKey('rem-item-${d.reminderId}'),
                    contentPadding: EdgeInsets.zero,
                    onTap: () => _openItem(d),
                    leading: CircleAvatar(
                      backgroundColor: stateColor(d.state).withValues(alpha: 0.14),
                      child: Icon(d.state == DayState.done ? Icons.check : Icons.alarm, color: stateColor(d.state), size: 20),
                    ),
                    title: Text(d.title,
                        style: AppTypography.bodyMedium(
                            color: AppTokens.textPrimary,
                            fontWeight: FontWeight.w700).copyWith(decoration: d.state == DayState.done ? TextDecoration.lineThrough : null)),
                    subtitle: Text(
                        [
                          timeLabel(d.time),
                          d.audience == 'PEOPLE' ? 'Chosen people' : 'Team',
                          if (d.moved) 'moved from ${dayName(d.planned!)}',
                          if (d.state == DayState.done && d.doneBy.isNotEmpty) 'done by ${d.doneBy}',
                        ].join(' · '),
                        style: AppTypography.bodySmall(color: AppTokens.textMuted)),
                    trailing: d.state == DayState.done || d.state == DayState.missed
                        ? _Pill(text: stateLabel(d.state), color: stateColor(d.state))
                        : TextButton(
                            key: ValueKey('rem-quick-done-${d.reminderId}'),
                            onPressed: _busy ? null : () => _run(() => _api.done(d.reminderId, d.dueOn), 'Marked done'),
                            child: const Text('Done')),
                  ),
              ]),
            ),
    );
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({required this.month, required this.data, required this.today, required this.selected, required this.onTap});

  final DateTime month;
  final ReminderMonth data;
  final DateTime today;
  final DateTime selected;
  final ValueChanged<DateTime> onTap;

  @override
  Widget build(BuildContext context) {
    final first = DateTime(month.year, month.month, 1);
    final days = DateTime(month.year, month.month + 1, 0).day;
    final lead = first.weekday - 1; // Monday first
    final cells = <Widget>[
      for (final w in const ['M', 'T', 'W', 'T', 'F', 'S', 'S'])
        Center(child: Text(w, style: AppTypography.badgeText(color: AppTokens.textMuted, fontWeight: FontWeight.w700))),
      for (var i = 0; i < lead; i++) const SizedBox.shrink(),
      for (var d = 1; d <= days; d++) _cell(DateTime(month.year, month.month, d)),
    ];
    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1,
      children: cells,
    );
  }

  Widget _cell(DateTime d) {
    final items = data.on(d);
    final isToday = d == today;
    final isSel = d == selected;
    final weekend = d.weekday >= 6;
    return InkWell(
      key: ValueKey('rem-day-${d.day}'),
      borderRadius: BorderRadius.circular(10),
      onTap: () => onTap(d),
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isSel ? AppTokens.brandPrimary : null,
          borderRadius: BorderRadius.circular(10),
          border: isToday && !isSel ? Border.all(color: AppTokens.brandPrimary, width: 1.5) : null,
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('${d.day}',
              style: AppTypography.bodySmall(
                  color: isSel ? Colors.white : (weekend ? AppTokens.textMuted : AppTokens.textPrimary),
                  fontWeight: isToday || isSel ? FontWeight.w800 : FontWeight.w500)),
          const SizedBox(height: 2),
          SizedBox(
            height: 6,
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              for (final it in items.take(3))
                Container(
                  width: 5,
                  height: 5,
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  decoration: BoxDecoration(color: isSel ? Colors.white : stateColor(it.state), shape: BoxShape.circle),
                ),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) => Wrap(spacing: 12, runSpacing: 4, alignment: WrapAlignment.center, children: [
        for (final s in const [DayState.done, DayState.sent, DayState.overdue, DayState.upcoming, DayState.paused])
          Row(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: stateColor(s), shape: BoxShape.circle)),
            const SizedBox(width: 4),
            Text(s == DayState.sent ? 'Due' : stateLabel(s), style: AppTypography.badgeText(color: AppTokens.textMuted)),
          ]),
      ]);
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
        child: Text(text, style: AppTypography.badgeText(color: color, fontWeight: FontWeight.w700)),
      );
}

/// Every reminder of the company with its rule and next day; tap → Edit.
class _AllReminders extends StatefulWidget {
  const _AllReminders({required this.api, required this.onEdit});

  final RemindersApi api;
  final Future<void> Function(ReminderItem) onEdit;

  @override
  State<_AllReminders> createState() => _AllRemindersState();
}

class _AllRemindersState extends State<_AllReminders> {
  late Future<List<ReminderItem>> _list = Future.sync(widget.api.list);

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppTokens.surfacePage,
        appBar: AppBar(
          backgroundColor: AppTokens.brandGradientStart,
          foregroundColor: AppTokens.textOnDark,
          title: Text('All reminders', style: AppTypography.bodyLarge(color: AppTokens.textOnDark, fontWeight: FontWeight.w700)),
        ),
        body: FutureBuilder<List<ReminderItem>>(
          future: _list,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
            if (snap.hasError) return Center(child: Text('${snap.error}', style: AppTypography.bodySmall(color: Palette.redDanger)));
            final list = snap.data!;
            if (list.isEmpty) {
              return Center(child: Text('No reminder yet.', style: AppTypography.bodyMedium(color: AppTokens.textMuted)));
            }
            return ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final r = list[i];
                return Material(
                  color: AppTokens.surfaceCard,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppTokens.surfaceBorder)),
                  clipBehavior: Clip.antiAlias,
                  child: ListTile(
                    key: ValueKey('rem-all-${r.id}'),
                    onTap: () async {
                      await widget.onEdit(r);
                      if (mounted) setState(() => _list = Future.sync(widget.api.list));
                    },
                    leading: Icon(r.paused ? Icons.pause_circle_outline : Icons.alarm, color: r.paused ? AppTokens.textMuted : AppTokens.brandPrimary),
                    title: Text(r.title, style: AppTypography.bodyMedium(color: AppTokens.textPrimary, fontWeight: FontWeight.w700)),
                    subtitle: Text(
                        [ruleText(r), if (r.paused) 'Paused' else if (r.nextDue != null) 'Next ${dayName(r.nextDue!)}'].join('\n'),
                        style: AppTypography.bodySmall(color: AppTokens.textMuted)),
                    isThreeLine: true,
                  ),
                );
              },
            );
          },
        ),
      );
}

/// The Reminders page a tapped notice opens (`/payable/reminders?day=yyyy-MM-dd`).
class PayableRemindersPage extends StatelessWidget {
  const PayableRemindersPage({super.key, this.day, this.api});

  final DateTime? day;
  final RemindersApi? api;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          backgroundColor: AppTokens.brandGradientStart,
          foregroundColor: AppTokens.textOnDark,
          title: Text('Reminders', style: AppTypography.bodyLarge(color: AppTokens.textOnDark, fontWeight: FontWeight.w700)),
        ),
        body: RemindersView(initialDay: day, api: api),
      );
}
