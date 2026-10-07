import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/mailmonitor/mail_monitor_api.dart';
import 'package:maleva/core/widgets/ui/ui.dart';
import 'package:maleva/features/mail_monitor/bloc/mail_message_cubit.dart';
import 'package:maleva/features/mail_monitor/view/level_look.dart';

/// One unread mail as text (owner's decision 2026-10-07). It stays unread in the mailbox;
/// nothing inside the mail is loaded or run; attachments are listed by name and size only.
class MailMessagePage extends StatelessWidget {
  const MailMessagePage({super.key, required this.api, required this.mailboxId, required this.uid});

  final MailMonitorApi api;
  final int mailboxId;
  final int uid;

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => MailMessageCubit(api)..open(mailboxId, uid),
        child: Scaffold(
          appBar: AppBar(title: const Text('Mail')),
          body: BlocBuilder<MailMessageCubit, MailMessageState>(
            builder: (context, s) {
              if (s.loading) return const SkeletonList(count: 4);
              if (s.message == null) {
                return ErrorState(
                  title: 'The mail could not be opened',
                  message: s.error,
                  onRetry: () => context.read<MailMessageCubit>().open(mailboxId, uid),
                );
              }
              final m = s.message!;
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Row(children: [
                    Icon(Icons.verified_user_outlined, size: 16, color: context.mc.toneFg(StatusTone.success)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text('Stays unread · opening is recorded',
                          style: TextStyle(fontSize: 12, color: context.mc.muted)),
                    ),
                  ]),
                  const SizedBox(height: 10),
                  SelectableText(m.subject.isEmpty ? '(no subject)' : m.subject,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  if (m.from.isNotEmpty) KeyValueRow('From', m.from),
                  if (m.to.isNotEmpty) KeyValueRow('To', m.to),
                  if (m.cc.isNotEmpty) KeyValueRow('Cc', m.cc),
                  KeyValueRow('Sent', dateTimeText(m.sentAt)),
                  KeyValueRow('Received', dateTimeText(m.receivedAt)),
                  if (m.attachments.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(spacing: 6, runSpacing: 6, children: [
                      for (final a in m.attachments)
                        Chip(
                          avatar: const Icon(Icons.attach_file, size: 16),
                          label: Text(a.size > 0 ? '${a.name} · ${sizeText(a.size)}' : a.name),
                          visualDensity: VisualDensity.compact,
                        ),
                    ]),
                  ],
                  const Divider(height: 24),
                  if (m.truncated)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text('This mail is very long; only the first part is shown.',
                          style: TextStyle(fontSize: 12, color: context.mc.toneFg(StatusTone.warning))),
                    ),
                  SelectableText(s.body.isEmpty ? '(empty mail)' : s.body, style: const TextStyle(fontSize: 14, height: 1.45)),
                ],
              );
            },
          ),
        ),
      );
}
