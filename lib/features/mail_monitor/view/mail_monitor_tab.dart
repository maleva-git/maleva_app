import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/di/injection.dart';
import 'package:maleva/core/mailmonitor/mail_monitor_api.dart';
import 'package:maleva/core/mailmonitor/mail_monitor_models.dart';
import 'package:maleva/core/widgets/ui/ui.dart';
import 'package:maleva/features/mail_monitor/bloc/mailbox_list_cubit.dart';
import 'package:maleva/features/mail_monitor/view/level_look.dart';
import 'package:maleva/features/mail_monitor/view/mailbox_card.dart';
import 'package:maleva/features/mail_monitor/view/mailbox_detail_page.dart';

/// Only the Super Admin (role 100) gets the Mailbox Monitor; Admin (200) shares the admin
/// dashboard without it. The server enforces the same rule.
bool mailMonitorAllowed(int roleId) => roleId == 100;

/// The Super Admin's Mailbox Monitor tab on the admin dashboard (shown only for role 100;
/// the server refuses everyone else too). Same numbers and colours as the web.
class MailMonitorTab extends StatelessWidget {
  const MailMonitorTab({super.key, this.api});

  /// For tests; the app uses the registered [MailMonitorApi].
  final MailMonitorApi? api;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MailboxListCubit(api ?? sl<MailMonitorApi>())
        ..load()
        ..startAutoRefresh(),
      child: const _MailMonitorView(),
    );
  }
}

class _MailMonitorView extends StatelessWidget {
  const _MailMonitorView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MailboxListCubit, MailboxListState>(
      listenWhen: (_, s) => s.notice != null,
      listener: (context, s) => showSnack(context, s.notice!, kind: SnackKind.info),
      builder: (context, s) {
        final cubit = context.read<MailboxListCubit>();
        if (s.list == null && s.loading) return const SkeletonList();
        if (s.list == null) {
          return ErrorState(title: 'Mailbox Monitor is not available', message: s.error, onRetry: cubit.load);
        }
        final list = s.list!;
        final rows = attentionFirst(list.mailboxes);
        return RefreshIndicator(
          onRefresh: cubit.load,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
            children: [
              _Header(summary: list.summary, onCheckNow: cubit.checkNow),
              const SizedBox(height: 12),
              _SummaryGrid(summary: list.summary),
              const SizedBox(height: 12),
              if (rows.isEmpty)
                const EmptyState(
                  title: 'No mailboxes yet',
                  message: 'Add the company mailboxes in Mailbox Monitor settings on the web.',
                  icon: Icons.mark_email_unread_outlined,
                ),
              for (final row in rows)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: MailboxCard(
                    row: row,
                    onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                      builder: (_) => MailboxDetailPage(row: row, api: context.read<MailboxListCubit>().api),
                    )),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.summary, required this.onCheckNow});

  final MailMonitorSummary summary;
  final VoidCallback onCheckNow;

  @override
  Widget build(BuildContext context) {
    final checked = summary.lastFullCheckAt;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Mailbox Monitor', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
              Text(
                checked == null ? 'Refreshes every minute' : 'Last full check ${dateTimeText(checked)} · refreshes every minute',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.mc.muted),
              ),
            ],
          ),
        ),
        OutlinedButton.icon(onPressed: onCheckNow, icon: const Icon(Icons.refresh, size: 18), label: const Text('Check now')),
      ],
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({required this.summary});

  final MailMonitorSummary summary;

  @override
  Widget build(BuildContext context) {
    final tiles = [
      ('Total unread', countText(summary.totalUnread), StatusTone.info, Icons.mail_outline),
      ('With unread', '${summary.withUnread} / ${summary.mailboxes}', StatusTone.neutral, Icons.inbox_outlined),
      ('Overdue', '${summary.overdue}', summary.overdue > 0 ? StatusTone.danger : StatusTone.success, Icons.warning_amber_rounded),
      ('Check errors', '${summary.errors}', summary.errors > 0 ? StatusTone.warning : StatusTone.success, Icons.shield_outlined),
    ];
    return LayoutBuilder(builder: (context, c) {
      final perRow = c.maxWidth >= 600 ? 4 : 2;
      final width = (c.maxWidth - (perRow - 1) * 8) / perRow;
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final t in tiles)
            SizedBox(
              width: width,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.mc.toneBg(t.$3),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(t.$1, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: context.mc.toneFg(t.$3))),
                      const SizedBox(height: 2),
                      Text(t.$2, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: context.mc.toneFg(t.$3))),
                    ]),
                  ),
                  Icon(t.$4, color: context.mc.toneFg(t.$3)),
                ]),
              ),
            ),
        ],
      );
    });
  }
}
