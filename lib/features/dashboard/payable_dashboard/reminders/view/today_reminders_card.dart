import 'package:flutter/material.dart';
import 'package:maleva/core/di/injection.dart';
import 'package:maleva/core/network/java_api_client.dart';
import 'package:maleva/core/theme/app_typography.dart';
import 'package:maleva/core/theme/tokens.dart';

import '../../records/view/record_style.dart';
import '../data/reminder_models.dart';
import '../data/reminders_api.dart';
import 'reminder_look.dart';

/// The Today tab's "Reminders today" card (change `payable-reminders`): due today and still open from earlier days,
/// Done in one tap, and a button to the Reminders tab. Says so quietly when reminders are not set up yet.
class TodayRemindersCard extends StatefulWidget {
  const TodayRemindersCard({super.key, this.api, this.onOpen});

  final RemindersApi? api;

  /// Opens the Reminders tab.
  final VoidCallback? onOpen;

  @override
  State<TodayRemindersCard> createState() => _TodayRemindersCardState();
}

class _TodayRemindersCardState extends State<TodayRemindersCard> {
  late final RemindersApi _api = widget.api ?? RemindersApi(sl<JavaApiClient>().dio);
  late Future<ReminderToday> _data = Future.sync(_api.today);
  final Set<String> _busy = {};

  Future<void> _done(ReminderDay d) async {
    final key = '${d.reminderId}-${d.dueOn}';
    setState(() => _busy.add(key));
    try {
      await _api.done(d.reminderId, d.dueOn);
      if (mounted) setState(() => _data = Future.sync(_api.today));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _busy.remove(key));
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<ReminderToday>(
        future: _data,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) return const SizedBox.shrink();
          if (snap.hasError) {
            return Panel(
              title: 'Reminders today',
              icon: Icons.alarm,
              child: Text('Reminders not available: ${snap.error}', style: AppTypography.bodySmall(color: AppTokens.textMuted)),
            );
          }
          final t = snap.data!;
          final rows = [for (final d in t.open) (d, true), for (final d in t.due) (d, false)];
          return Panel(
            key: const ValueKey('today-reminders'),
            title: 'Reminders today',
            icon: Icons.alarm,
            trailing: SoftChip(text: '${t.toDo} to do'),
            child: Material(
              type: MaterialType.transparency,
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                if (rows.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Text('Nothing due today.', style: AppTypography.bodySmall(color: AppTokens.textMuted)),
                  ),
                for (final (d, earlier) in rows)
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(d.state == DayState.done ? Icons.check_circle : Icons.alarm, color: stateColor(d.state)),
                    title: Text(d.title,
                        style: AppTypography.bodyMedium(color: AppTokens.textPrimary, fontWeight: FontWeight.w600)
                            .copyWith(decoration: d.state == DayState.done ? TextDecoration.lineThrough : null)),
                    subtitle: Text(
                        earlier
                            ? 'Due ${dayName(d.dueOn)} · not done yet'
                            : '${timeLabel(d.time)} · ${stateLabel(d.state)}',
                        style: AppTypography.bodySmall(color: stateColor(d.state))),
                    trailing: d.state == DayState.done
                        ? null
                        : TextButton(
                            key: ValueKey('today-rem-done-${d.reminderId}'),
                            onPressed: _busy.contains('${d.reminderId}-${d.dueOn}') ? null : () => _done(d),
                            child: const Text('Done')),
                  ),
                if (widget.onOpen != null)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                        onPressed: widget.onOpen, icon: const Icon(Icons.calendar_month, size: 18), label: const Text('Calendar')),
                  ),
              ]),
            ),
          );
        },
      );
}
