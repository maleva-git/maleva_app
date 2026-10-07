import 'package:flutter/material.dart';
import 'package:maleva/core/mailmonitor/mail_monitor_api.dart';
import 'package:maleva/core/mailmonitor/mail_monitor_models.dart';
import 'package:maleva/core/widgets/ui/ui.dart';
import 'package:maleva/features/mail_monitor/view/level_look.dart';
import 'package:maleva/features/mail_monitor/view/mail_message_page.dart';
import 'package:maleva/features/mail_monitor/view/unread_mail_page.dart';

/// One mailbox: counts, the latest five unread (tap to open), people, limits, and the reminder.
class MailboxDetailPage extends StatefulWidget {
  const MailboxDetailPage({super.key, required this.row, required this.api});

  final MailboxRow row;
  final MailMonitorApi api;

  @override
  State<MailboxDetailPage> createState() => _MailboxDetailPageState();
}

class _MailboxDetailPageState extends State<MailboxDetailPage> {
  late Future<List<PreviewItem>> _preview = widget.api.preview(widget.row.id);
  bool _sending = false;

  MailboxRow get row => widget.row;

  Future<void> _remind() async {
    if (_sending) return;
    setState(() => _sending = true);
    try {
      final r = await widget.api.remind(row.id);
      if (mounted) showSnack(context, 'Reminder sent to ${r.sentTo.join(', ')}');
    } catch (e) {
      if (mounted) showSnack(context, '$e', kind: SnackKind.error);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _open(int uid) => Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => MailMessagePage(api: widget.api, mailboxId: row.id, uid: uid),
      ));

  @override
  Widget build(BuildContext context) {
    final look = lookOf(row);
    final owners = row.activeOwners;
    final unread = row.unread ?? 0;
    return Scaffold(
      appBar: AppBar(title: Text(row.address, overflow: TextOverflow.ellipsis)),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() => _preview = widget.api.preview(row.id));
          await _preview.catchError((_) => <PreviewItem>[]);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(children: [
              StatusPill(look.label, tone: look.tone, icon: look.icon),
              const SizedBox(width: 8),
              Expanded(child: Text(row.department ?? row.displayName, style: TextStyle(color: context.mc.muted))),
            ]),
            if (look.hint != null) ...[
              const SizedBox(height: 8),
              Text('${look.hint}${row.errorMessage == null ? '' : ' (${row.errorMessage})'}',
                  style: TextStyle(color: context.mc.muted, fontSize: 13)),
            ],
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: LabeledValue('Unread', row.unread == null ? '–' : countText(unread))),
              Expanded(child: LabeledValue('Oldest', unread > 0 ? ageText(row.oldestUnreadAt, DateTime.now()) : '—')),
              Expanded(child: LabeledValue('Checked', dateTimeText(row.lastCheckedAt))),
            ]),
            const SizedBox(height: 16),
            DetailSection(
              title: 'Latest unread · tap to open',
              icon: Icons.mark_email_unread_outlined,
              child: FutureBuilder<List<PreviewItem>>(
                future: _preview,
                builder: (context, snap) {
                  if (snap.connectionState != ConnectionState.done) return const LinearProgressIndicator();
                  if (snap.hasError) return Text('${snap.error}', style: TextStyle(color: context.mc.muted));
                  final items = snap.data ?? const [];
                  if (items.isEmpty) {
                    return Text(unread > 0 ? 'Shown after the next check.' : 'No unread mail.',
                        style: TextStyle(color: context.mc.muted));
                  }
                  return Column(children: [for (final i in items) MailRowTile(item: i, onTap: i.uid > 0 ? () => _open(i.uid) : null)]);
                },
              ),
            ),
            if (row.credentialSet && unread > 0)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.list_alt),
                  label: Text('View all unread (${countText(unread)})'),
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(
                    builder: (_) => UnreadMailPage(api: widget.api, row: row),
                  )),
                ),
              ),
            const SizedBox(height: 16),
            DetailSection(
              title: 'People',
              icon: Icons.people_outline,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if (row.members.isEmpty) Text('Nobody is linked yet.', style: TextStyle(color: context.mc.muted)),
                for (final m in row.members)
                  KeyValueRow(m.active ? m.name : '${m.name} (inactive)', m.isOwner ? 'Owner' : 'Member'),
                const SizedBox(height: 6),
                Text('Amber after ${row.warnMinutes} min · red after ${row.overdueMinutes} min',
                    style: TextStyle(fontSize: 12, color: context.mc.muted)),
              ]),
            ),
            const SizedBox(height: 16),
            if (owners.isEmpty)
              Text('Add an owner in Mailbox Monitor settings on the web to send reminders.',
                  style: TextStyle(color: context.mc.muted))
            else if (unread > 0)
              FilledButton.icon(
                onPressed: _sending ? null : _remind,
                icon: _sending
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.send_outlined),
                label: Text(owners.length == 1 ? 'Email ${owners.first.name}' : 'Email ${owners.length} owners'),
              ),
          ],
        ),
      ),
    );
  }
}

/// Sender, subject and the full date and time of one unread mail.
class MailRowTile extends StatelessWidget {
  const MailRowTile({super.key, required this.item, this.onTap});

  final PreviewItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => ListTile(
        contentPadding: EdgeInsets.zero,
        dense: true,
        onTap: onTap,
        title: Text(item.sender.isEmpty ? 'Unknown sender' : item.sender,
            maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(item.subject.isEmpty ? '(no subject)' : item.subject, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: Text(dateTimeText(item.receivedAt), style: TextStyle(fontSize: 11, color: context.mc.muted)),
      );
}
