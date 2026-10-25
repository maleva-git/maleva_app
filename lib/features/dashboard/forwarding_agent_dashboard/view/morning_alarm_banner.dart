import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

import '../../../../core/network/api_failure.dart';
import '../../../../core/rti/rti_api.dart';
import '../../../../core/utils/json_read.dart';

/// Top of RTI Activities (backend change `rti-morning-briefing`, "Got it and follow-up"): when today's 06:00 alarm
/// was sent to this agent and not answered, an orange card asks them to tap "Got it". Not tapped by 06:15, the
/// alarm rings once more; by 07:30 Forwarding is told. After the tap a small green line shows the time.
/// Shows nothing when no alarm was sent today (or the follow-up switch is off), or when it cannot be read.
class MorningAlarmBanner extends StatefulWidget {
  const MorningAlarmBanner({super.key, this.api});

  final RtiApi? api;

  @override
  State<MorningAlarmBanner> createState() => _MorningAlarmBannerState();
}

class _MorningAlarmBannerState extends State<MorningAlarmBanner> {
  late final RtiApi _api = widget.api ?? GetIt.instance<RtiApi>();
  Map<String, dynamic>? _today;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final today = await _api.morningAlarmToday();
      if (mounted) setState(() => _today = today);
    } catch (_) {
      // the banner is a helper: a failed read leaves the screen as it was
    }
  }

  Future<void> _gotIt() async {
    setState(() => _saving = true);
    try {
      final today = await _api.morningAlarmGotIt();
      if (mounted) setState(() => _today = today);
    } catch (e) {
      if (!mounted) return;
      final reason = e is ApiFailure ? e.message : 'Something went wrong.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Got it not saved. $reason Please try again.'),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = _today;
    if (today == null || !JsonRead.boolean(today['sent'])) return const SizedBox.shrink();
    final stops = JsonRead.integer(today['stopCount']);
    final ackAt = JsonRead.date(today['ackAt']);

    if (ackAt != null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
        child: Row(children: [
          Icon(Icons.check_circle, color: Colors.green.shade700, size: 18),
          const SizedBox(width: 6),
          Expanded(
            child: Text("Today's trucks seen at ${DateFormat('HH:mm').format(ackAt)}",
                style: TextStyle(color: Colors.green.shade800, fontWeight: FontWeight.w600)),
          ),
        ]),
      );
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade300),
      ),
      child: Row(children: [
        Icon(Icons.alarm, color: Colors.orange.shade800),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            "Today: $stops ${stops == 1 ? 'stop' : 'stops'}. Tap Got it so Forwarding knows you saw them.",
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(width: 8),
        FilledButton(
          key: const Key('morning-alarm-got-it'),
          onPressed: _saving ? null : _gotIt,
          style: FilledButton.styleFrom(backgroundColor: Colors.green.shade700),
          child: _saving
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Got it'),
        ),
      ]),
    );
  }
}
