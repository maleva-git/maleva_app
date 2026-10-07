import 'package:flutter/material.dart';
import 'package:maleva/core/mailmonitor/mail_monitor_models.dart';
import 'package:maleva/core/widgets/ui/ui.dart';
import 'package:maleva/features/mail_monitor/view/level_look.dart';

/// One mailbox: address, department and people, the unread count and the oldest unread age,
/// with its status as a pill (colour, words and icon).
class MailboxCard extends StatelessWidget {
  const MailboxCard({super.key, required this.row, required this.onTap});

  final MailboxRow row;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final look = lookOf(row);
    final overdue = look.tone == StatusTone.danger;
    final stale = row.status != 'OK';
    final people = row.members.map((m) => m.isOwner ? '${m.name} (owner)' : m.name).join(', ');
    return Material(
      color: overdue ? context.mc.toneBg(StatusTone.danger).withValues(alpha: 0.45) : Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: overdue ? context.mc.toneFg(StatusTone.danger).withValues(alpha: 0.35) : context.mc.outline),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(row.address, style: const TextStyle(fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis),
                    Text(
                      [row.department ?? row.displayName, if (people.isNotEmpty) people].join(' · '),
                      style: TextStyle(fontSize: 12, color: context.mc.muted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Wrap(spacing: 8, runSpacing: 4, crossAxisAlignment: WrapCrossAlignment.center, children: [
                      StatusPill(look.label, tone: look.tone, icon: look.icon),
                      if ((row.unread ?? 0) > 0)
                        Text('Oldest ${ageText(row.oldestUnreadAt, DateTime.now())}',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: context.mc.toneFg(look.tone))),
                    ]),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(
                  row.unread == null ? '–' : countText(row.unread!),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: stale ? context.mc.muted : context.mc.toneFg(look.tone),
                  ),
                ),
                Text('unread', style: TextStyle(fontSize: 11, color: context.mc.muted)),
              ]),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
