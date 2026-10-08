import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/di/injection.dart';
import 'package:maleva/core/mailmonitor/mail_monitor_api.dart';
import 'package:maleva/core/mailmonitor/my_unread_models.dart';
import 'package:maleva/core/widgets/ui/ui.dart';
import 'package:maleva/features/mail_monitor/mine/my_unread_mail_cubit.dart';
import 'package:maleva/features/mail_monitor/view/level_look.dart';

/// "My unread mail": each linked mailbox with its count and oldest age. Opened from a tapped notice.
/// Counts only - the mail is read in the mail program.
class MyUnreadMailPage extends StatelessWidget {
  const MyUnreadMailPage({super.key, this.api});

  final MailMonitorApi? api;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MyUnreadMailCubit(api ?? sl<MailMonitorApi>())
        ..load()
        ..startAutoRefresh(),
      child: Scaffold(
        appBar: AppBar(title: const Text('My unread mail')),
        body: BlocBuilder<MyUnreadMailCubit, MyUnreadMailState>(
          builder: (context, state) {
            final mail = state.mail;
            if (mail == null) {
              if (state.error != null) return Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(state.error!)));
              return const Center(child: CircularProgressIndicator());
            }
            return RefreshIndicator(
              onRefresh: () => context.read<MyUnreadMailCubit>().load(),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (!mail.linked)
                    const Text('You are not linked to a company mailbox.')
                  else ...[
                    Text(
                      mail.total > 0 ? '${countText(mail.total)} unread' : 'All read',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800,
                          color: context.mc.toneFg(mail.total > 0 ? StatusTone.danger : StatusTone.success)),
                    ),
                    if (mail.total > 0)
                      Text('Oldest ${ageText(mail.oldest, DateTime.now())}', style: TextStyle(color: context.mc.muted)),
                    const SizedBox(height: 12),
                    for (final m in mail.byUnread) _MailboxTile(m),
                    const SizedBox(height: 12),
                    Text('Read and reply in your mail program. A reminder comes after 10 minutes, Mon–Sat 8 am–7 pm.',
                        style: TextStyle(fontSize: 12, color: context.mc.muted)),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _MailboxTile extends StatelessWidget {
  const _MailboxTile(this.m);

  final MyMailbox m;

  @override
  Widget build(BuildContext context) {
    final unread = m.checked ? (m.unread ?? 0) : null;
    final line = !m.checked
        ? (m.status == 'PENDING' ? 'Not checked yet' : 'Could not be checked')
        : unread == 0
            ? 'All read'
            : 'Oldest ${ageText(m.oldestUnreadAt, DateTime.now())}';
    return Card(
      child: ListTile(
        title: Text(m.address, style: const TextStyle(fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis),
        subtitle: Text('${m.role == 'OWNER' ? 'Owner' : 'Member'} · $line${m.remindersOn ? '' : ' · reminders off'}'),
        trailing: Text(unread == null ? '—' : countText(unread),
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800,
                color: (unread ?? 0) > 0 ? context.mc.toneFg(StatusTone.danger) : context.mc.muted)),
      ),
    );
  }
}
