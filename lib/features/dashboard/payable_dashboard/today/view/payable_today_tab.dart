import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/dashboard/dashboard_api.dart';
import 'package:maleva/core/di/injection.dart';
import 'package:maleva/core/network/java_api_client.dart';
import 'package:maleva/core/theme/app_typography.dart';
import 'package:maleva/core/theme/palette.dart';
import 'package:maleva/core/theme/tokens.dart';
import 'package:maleva/core/utils/app_preferences.dart';
import 'package:maleva/core/widgets/ui/formats.dart';

import '../../view/payable_tabs.dart';
import '../bloc/payable_today_cubit.dart';
import '../data/payable_today_api.dart';
import '../data/payable_today_models.dart';
import '../../reminders/view/today_reminders_card.dart';

/// The Payable dashboard's first tab (change `payable-desk-today`): what must be paid, what was paid this
/// month, which payments still need their document, and what was spent. Read only; paying, bills and
/// uploads stay on their own tabs, which the Open buttons switch to.
class PayableTodayTab extends StatelessWidget {
  const PayableTodayTab({super.key, required this.onOpen});

  /// Switches the dashboard to another tab.
  final ValueChanged<PayableTab> onOpen;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PayableTodayCubit(
        PayableTodayApi(sl<JavaApiClient>().dio, sl<DashboardApi>()),
        companyId: AppPreferences.getComid,
      )..load(),
      child: PayableTodayView(
        onOpen: onOpen,
        remindersCard: TodayRemindersCard(onOpen: () => onOpen(PayableTab.reminders)),
      ),
    );
  }
}

/// The tab's content over a [PayableTodayCubit] given by the caller (tests give their own).
class PayableTodayView extends StatelessWidget {
  const PayableTodayView({super.key, required this.onOpen, this.remindersCard});

  final ValueChanged<PayableTab> onOpen;

  /// The "Reminders today" card (change `payable-reminders`); tests leave it out.
  final Widget? remindersCard;

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 600;
    return BlocBuilder<PayableTodayCubit, PayableTodayState>(
      builder: (context, s) {
        final cubit = context.read<PayableTodayCubit>();
        final pad = wide ? 20.0 : 12.0;
        final toPay = _ToPayCard(state: s, onRetry: () => cubit.retry(PayableSection.pending));
        final noDoc = _NoDocumentCard(state: s, cubit: cubit);
        final spent = _SpentCard(state: s, onRetry: () => cubit.retry(PayableSection.expenses));
        final open = _OpenCard(onOpen: onOpen);
        return Container(
          color: AppTokens.surfacePage,
          child: RefreshIndicator(
            onRefresh: cubit.load,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(pad, 4, pad, 24),
              children: [
                _Header(state: s, wide: wide, onRefresh: cubit.load),
                const SizedBox(height: 12),
                _NumberCards(state: s, wide: wide, cubit: cubit),
                const SizedBox(height: 12),
                if (remindersCard != null) ...[remindersCard!, const SizedBox(height: 12)],
                if (wide)
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(child: Column(children: [toPay])),
                    const SizedBox(width: 12),
                    Expanded(child: Column(children: [noDoc, const SizedBox(height: 12), spent, const SizedBox(height: 12), open])),
                  ])
                else ...[
                  toPay,
                  const SizedBox(height: 12),
                  noDoc,
                  const SizedBox(height: 12),
                  spent,
                  const SizedBox(height: 12),
                  open,
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.state, required this.wide, required this.onRefresh});

  final PayableTodayState state;
  final bool wide;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final at = state.updatedAt;
    final busy = state.sections.values.any((v) => v.loading);
    return Row(children: [
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Payable today', style: AppTypography.heading2(color: AppTokens.textPrimary)),
          const SizedBox(height: 2),
          Text(
            at == null
                ? Fmt.dMonY(Fmt.today())
                : '${Fmt.dMonY(at)} · updated ${at.hour.toString().padLeft(2, '0')}:${at.minute.toString().padLeft(2, '0')}',
            style: AppTypography.bodySmall(color: AppTokens.textMuted),
          ),
        ]),
      ),
      IconButton(
        tooltip: 'Refresh',
        onPressed: busy ? null : onRefresh,
        icon: busy
            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
            : const Icon(Icons.refresh, color: AppTokens.brandPrimary),
      ),
    ]);
  }
}

// ── number cards ──────────────────────────────────────────────────────────────

class _NumberCards extends StatelessWidget {
  const _NumberCards({required this.state, required this.wide, required this.cubit});

  final PayableTodayState state;
  final bool wide;
  final PayableTodayCubit cubit;

  @override
  Widget build(BuildContext context) {
    final pending = state.pending;
    final completed = state.completed;
    final docs = state.documents;
    final rows = pending.data ?? const <PendingPayment>[];
    final overdue = PayableRules.total(rows, DueState.overdue);
    final soon = PayableRules.total(rows, DueState.dueSoon);
    final paid = PayableRules.paid(completed.data ?? const []);
    final missing = PayableRules.withoutDocument(completed.data ?? const [], docs.data);

    final cards = [
      _NumberCard(
        key: const ValueKey('card-overdue'),
        label: 'Overdue',
        icon: Icons.error_outline,
        count: overdue.count,
        amount: overdue.amount,
        color: overdue.count > 0 ? Palette.redDanger : AppTokens.textPrimary,
        section: pending,
        onRetry: () => cubit.retry(PayableSection.pending),
      ),
      _NumberCard(
        key: const ValueKey('card-due-soon'),
        label: 'Due in ${PayableTodayApi.dueDays} days',
        icon: Icons.schedule,
        count: soon.count,
        amount: soon.amount,
        color: soon.count > 0 ? Palette.amberGold : AppTokens.textPrimary,
        section: pending,
        onRetry: () => cubit.retry(PayableSection.pending),
      ),
      _NumberCard(
        key: const ValueKey('card-paid'),
        label: 'Paid this month',
        icon: Icons.check_circle_outline,
        count: paid.count,
        amount: paid.amount,
        color: Palette.greenEco,
        section: completed,
        onRetry: () => cubit.retry(PayableSection.completed),
      ),
      _NumberCard(
        key: const ValueKey('card-no-doc'),
        label: 'Paid, no document',
        icon: Icons.receipt_long_outlined,
        count: missing.length,
        amount: missing.fold(0.0, (s, p) => s + p.amount),
        color: missing.isNotEmpty ? Palette.redDanger : AppTokens.textPrimary,
        section: docs.error != null ? docs : completed,
        onRetry: () {
          cubit.retry(PayableSection.completed);
          cubit.retry(PayableSection.documents);
        },
      ),
    ];
    if (wide) {
      return Row(children: [
        for (var i = 0; i < cards.length; i++) ...[
          if (i > 0) const SizedBox(width: 12),
          Expanded(child: cards[i]),
        ],
      ]);
    }
    return Column(children: [
      Row(children: [Expanded(child: cards[0]), const SizedBox(width: 10), Expanded(child: cards[1])]),
      const SizedBox(height: 10),
      Row(children: [Expanded(child: cards[2]), const SizedBox(width: 10), Expanded(child: cards[3])]),
    ]);
  }
}

class _NumberCard extends StatelessWidget {
  const _NumberCard({
    super.key,
    required this.label,
    required this.icon,
    required this.count,
    required this.amount,
    required this.color,
    required this.section,
    required this.onRetry,
  });

  final String label;
  final IconData icon;
  final int count;
  final double amount;
  final Color color;
  final SectionState<Object> section;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Text(label,
                maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTypography.bodySmall(color: AppTokens.textMuted)),
          ),
        ]),
        const SizedBox(height: 6),
        if (section.data == null || section.error != null)
          _SectionStatus(section: section, onRetry: onRetry, compact: true)
        else ...[
          Text('$count', style: AppTypography.heading1(color: color, fontWeight: FontWeight.w800)),
          Text(Fmt.rm(amount),
              maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTypography.bodySmall(color: AppTokens.textPrimary)),
        ],
      ]),
    );
  }
}

// ── to pay ────────────────────────────────────────────────────────────────────

class _ToPayCard extends StatefulWidget {
  const _ToPayCard({required this.state, required this.onRetry});

  final PayableTodayState state;
  final VoidCallback onRetry;

  @override
  State<_ToPayCard> createState() => _ToPayCardState();
}

class _ToPayCardState extends State<_ToPayCard> {
  static const _firstRows = 10;
  bool _all = false;

  @override
  Widget build(BuildContext context) {
    final section = widget.state.pending;
    final rows = PayableRules.sortToPay(section.data ?? const []);
    final shown = _all ? rows : rows.take(_firstRows).toList();
    return _Panel(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _Title(icon: Icons.payments_outlined, text: 'To pay', trailing: section.data == null ? null : '${rows.length}'),
        if (section.data == null || section.error != null)
          _SectionStatus(section: section, onRetry: widget.onRetry)
        else if (rows.isEmpty)
          const _Empty('Nothing to pay. Well done.')
        else ...[
          for (final p in shown) _ToPayRow(payment: p),
          if (rows.length > _firstRows)
            Align(
              alignment: Alignment.center,
              child: TextButton(
                onPressed: () => setState(() => _all = !_all),
                child: Text(_all ? 'Show less' : 'Show all ${rows.length}'),
              ),
            ),
        ],
      ]),
    );
  }
}

class _ToPayRow extends StatelessWidget {
  const _ToPayRow({required this.payment});

  final PendingPayment payment;

  @override
  Widget build(BuildContext context) {
    final p = payment;
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => _showPaymentSheet(context, p),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
        child: Row(children: [
          Container(width: 4, height: 36, decoration: BoxDecoration(color: _dueColor(p.due), borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(p.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodyMedium(color: AppTokens.textPrimary, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Row(children: [
                _Chip(text: _dueLabel(p.due), color: _dueColor(p.due)),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(_dueText(p),
                      maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTypography.bodySmall(color: AppTokens.textMuted)),
                ),
              ]),
            ]),
          ),
          const SizedBox(width: 8),
          Text(Fmt.rm(p.amount), style: AppTypography.bodyMedium(color: AppTokens.textPrimary, fontWeight: FontWeight.w700)),
          const Icon(Icons.chevron_right, size: 18, color: AppTokens.textSecondary),
        ]),
      ),
    );
  }
}

String _dueLabel(DueState d) => switch (d) {
      DueState.overdue => 'Overdue',
      DueState.dueSoon => 'Due soon',
      DueState.scheduled => 'Scheduled',
    };

Color _dueColor(DueState d) => switch (d) {
      DueState.overdue => Palette.redDanger,
      DueState.dueSoon => Palette.amberGold,
      DueState.scheduled => AppTokens.brandPrimary,
    };

String _dueText(PendingPayment p) {
  final d = p.dueDate;
  if (d != null) return 'Due ${Fmt.ddMMyyyy(d)}';
  final t = p.dueDateText?.trim() ?? '';
  return t.isEmpty ? 'No due date' : 'Due $t';
}

/// The row's details with the bank and account number, and Copy for paying in online banking.
Future<void> _showPaymentSheet(BuildContext context, PendingPayment p) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    backgroundColor: AppTokens.surfaceCard,
    builder: (sheet) {
      final account = p.accountNo?.trim() ?? '';
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(p.name, style: AppTypography.heading3(color: AppTokens.textPrimary)),
            if ((p.expenseName ?? '').trim().isNotEmpty && p.expenseName!.trim() != p.name)
              Text(p.expenseName!.trim(), style: AppTypography.bodySmall(color: AppTokens.textMuted)),
            const SizedBox(height: 12),
            Row(children: [
              _Chip(text: _dueLabel(p.due), color: _dueColor(p.due)),
              const SizedBox(width: 8),
              Text(_dueText(p), style: AppTypography.bodySmall(color: AppTokens.textMuted)),
            ]),
            const SizedBox(height: 12),
            _SheetLine(label: 'Amount', value: Fmt.rm(p.amount)),
            _SheetLine(label: 'Type', value: p.isVendor ? 'Supplier bill' : 'Scheduled expense'),
            _SheetLine(label: 'Bank', value: (p.bankName ?? '').trim().isEmpty ? '-' : p.bankName!.trim()),
            Row(children: [
              Expanded(child: _SheetLine(label: 'Account no.', value: account.isEmpty ? '-' : account)),
              if (account.isNotEmpty)
                TextButton.icon(
                  key: const ValueKey('copy-account'),
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: account));
                    if (sheet.mounted) {
                      ScaffoldMessenger.of(sheet).showSnackBar(const SnackBar(content: Text('Copied')));
                    }
                  },
                  icon: const Icon(Icons.copy, size: 16),
                  label: const Text('Copy'),
                ),
            ]),
          ]),
        ),
      );
    },
  );
}

class _SheetLine extends StatelessWidget {
  const _SheetLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 96, child: Text(label, style: AppTypography.bodySmall(color: AppTokens.textMuted))),
        Expanded(
          child: SelectableText(value,
              style: AppTypography.bodyMedium(color: AppTokens.textPrimary, fontWeight: FontWeight.w600)),
        ),
      ]),
    );
  }
}

// ── paid without a document ───────────────────────────────────────────────────

class _NoDocumentCard extends StatelessWidget {
  const _NoDocumentCard({required this.state, required this.cubit});

  final PayableTodayState state;
  final PayableTodayCubit cubit;

  @override
  Widget build(BuildContext context) {
    final completed = state.completed;
    final docs = state.documents;
    Widget body;
    if (completed.data == null || completed.error != null) {
      body = _SectionStatus(section: completed, onRetry: () => cubit.retry(PayableSection.completed));
    } else if (docs.error != null && docs.data == null) {
      body = Row(children: [
        Expanded(
          child: Text('The document check is not available now.',
              style: AppTypography.bodySmall(color: AppTokens.textMuted)),
        ),
        TextButton(onPressed: () => cubit.retry(PayableSection.documents), child: const Text('Retry')),
      ]);
    } else if (docs.data == null) {
      body = _SectionStatus(section: docs, onRetry: () => cubit.retry(PayableSection.documents));
    } else {
      final missing = PayableRules.withoutDocument(completed.data!, docs.data);
      body = missing.isEmpty
          ? const _Empty('Every payment this month has its document.')
          : Column(children: [for (final p in missing) _NoDocRow(payment: p)]);
    }
    final count = docs.data == null || completed.data == null
        ? null
        : '${PayableRules.withoutDocument(completed.data!, docs.data).length}';
    return _Panel(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _Title(icon: Icons.receipt_long_outlined, text: 'Paid without a document', trailing: count),
        body,
      ]),
    );
  }
}

class _NoDocRow extends StatelessWidget {
  const _NoDocRow({required this.payment});

  final CompletedPayment payment;

  @override
  Widget build(BuildContext context) {
    final p = payment;
    final sub = [p.date, p.number, p.isSupplier ? 'Supplier payment' : 'Voucher']
        .where((t) => (t ?? '').trim().isNotEmpty)
        .join(' · ');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 2),
      child: Row(children: [
        const Icon(Icons.description_outlined, size: 18, color: Palette.redDanger),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text((p.paidTo ?? '').trim().isEmpty ? 'Payment' : p.paidTo!.trim(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodyMedium(color: AppTokens.textPrimary, fontWeight: FontWeight.w600)),
            Text(sub, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTypography.bodySmall(color: AppTokens.textMuted)),
          ]),
        ),
        const SizedBox(width: 8),
        Text(Fmt.rm(p.amount), style: AppTypography.bodyMedium(color: AppTokens.textPrimary, fontWeight: FontWeight.w700)),
      ]),
    );
  }
}

// ── spent ─────────────────────────────────────────────────────────────────────

class _SpentCard extends StatelessWidget {
  const _SpentCard({required this.state, required this.onRetry});

  final PayableTodayState state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final section = state.expenses;
    final e = section.data;
    return _Panel(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const _Title(icon: Icons.pie_chart_outline, text: 'Spent'),
        if (e == null || section.error != null)
          _SectionStatus(section: section, onRetry: onRetry)
        else ...[
          Row(children: [
            Expanded(child: _Period(label: 'Today', value: e.today)),
            Expanded(child: _Period(label: 'Yesterday', value: e.yesterday)),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: _Period(label: 'This week', value: e.week)),
            Expanded(child: _Period(label: 'This month', value: e.month)),
          ]),
          if (e.heads.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('Top expense heads this month', style: AppTypography.bodySmall(color: AppTokens.textMuted)),
            const SizedBox(height: 4),
            for (final h in e.top(5)) _HeadRow(head: h, max: e.top(1).first.amount),
          ],
        ],
      ]),
    );
  }
}

class _Period extends StatelessWidget {
  const _Period({required this.label, required this.value});

  final String label;
  final CountAmount value;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: AppTypography.bodySmall(color: AppTokens.textMuted)),
      Text(Fmt.rm(value.amount),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.bodyMedium(color: AppTokens.textPrimary, fontWeight: FontWeight.w700)),
      Text('${value.count} entries', style: AppTypography.bodySmall(color: AppTokens.textMuted)),
    ]);
  }
}

class _HeadRow extends StatelessWidget {
  const _HeadRow({required this.head, required this.max});

  final ExpenseHead head;
  final double max;

  @override
  Widget build(BuildContext context) {
    final share = max <= 0 ? 0.0 : (head.amount / max).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: Text(head.name,
                maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTypography.bodySmall(color: AppTokens.textPrimary)),
          ),
          Text(Fmt.rm(head.amount), style: AppTypography.bodySmall(color: AppTokens.textPrimary, fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 3),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: share,
            minHeight: 5,
            backgroundColor: AppTokens.surfaceBorder,
            color: AppTokens.brandPrimary,
          ),
        ),
      ]),
    );
  }
}

// ── open buttons ──────────────────────────────────────────────────────────────

class _OpenCard extends StatelessWidget {
  const _OpenCard({required this.onOpen});

  final ValueChanged<PayableTab> onOpen;

  static const _buttons = [
    (PayableTab.reminders, Icons.alarm),
    (PayableTab.spend, Icons.shopping_bag_outlined),
    (PayableTab.payments, Icons.event_note_outlined),
    (PayableTab.records, Icons.folder_open_outlined),
    (PayableTab.completed, Icons.task_alt_outlined),
    (PayableTab.pettyCash, Icons.account_balance_wallet_outlined),
    (PayableTab.expenses, Icons.bar_chart),
    (PayableTab.driverSalary, Icons.badge_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const _Title(icon: Icons.open_in_new, text: 'Open'),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final (tab, icon) in _buttons)
            OutlinedButton.icon(
              key: ValueKey('open-${tab.name}'),
              onPressed: () => onOpen(tab),
              icon: Icon(icon, size: 16),
              label: Text(tab.label),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTokens.brandPrimary,
                side: const BorderSide(color: AppTokens.surfaceBorder),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
        ]),
      ]),
    );
  }
}

// ── small parts ───────────────────────────────────────────────────────────────

class _Panel extends StatelessWidget {
  const _Panel({required this.child, this.padding = const EdgeInsets.fromLTRB(14, 12, 14, 12)});

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppTokens.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTokens.surfaceBorder),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: child,
    );
  }
}

class _Title extends StatelessWidget {
  const _Title({required this.icon, required this.text, this.trailing});

  final IconData icon;
  final String text;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(children: [
        Icon(icon, size: 18, color: AppTokens.brandPrimary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: AppTypography.bodyLarge(color: AppTokens.textPrimary, fontWeight: FontWeight.w700)),
        ),
        if (trailing != null) _Chip(text: trailing!, color: AppTokens.brandPrimary),
      ]),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
      child: Text(text, style: AppTypography.badgeText(color: color, fontWeight: FontWeight.w700)),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(text, style: AppTypography.bodySmall(color: AppTokens.textMuted)),
    );
  }
}

/// Loading, or the error with Retry, for a section with no data to show.
class _SectionStatus extends StatelessWidget {
  const _SectionStatus({required this.section, required this.onRetry, this.compact = false});

  final SectionState<Object> section;
  final VoidCallback onRetry;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (section.error == null) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: compact ? 6 : 12),
        child: const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    return Row(children: [
      const Icon(Icons.error_outline, size: 16, color: Palette.redDanger),
      const SizedBox(width: 6),
      Expanded(
        child: Text(section.error!,
            maxLines: compact ? 1 : 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodySmall(color: Palette.redDanger)),
      ),
      TextButton(
        onPressed: onRetry,
        style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 6), minimumSize: const Size(0, 30)),
        child: const Text('Retry'),
      ),
    ]);
  }
}
