import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/theme/app_typography.dart';
import 'package:maleva/core/theme/tokens.dart';
import 'package:maleva/core/widgets/ui/formats.dart';
import 'package:maleva/features/dashboard/admin_dashboard/overview/view/overview_widgets.dart';

import '../bloc/ceo_dashboard_cubit.dart';
import '../data/ceo_analytics_models.dart';
import 'ceo_details_sheet.dart';
import 'ceo_tab_kit.dart';
import 'ceo_widgets.dart';

/// The days the Money Received tab shows.
enum CeoReceivedPeriod {
  thisMonth('This month'),
  lastMonth('Last month'),
  chosen('Chosen period');

  const CeoReceivedPeriod(this.label);

  final String label;

  /// This month to [today], the whole last month, or the CEO period ([chosen]).
  (String, String) range(DateTime today, (String, String) chosen) {
    final d = DateTime(today.year, today.month, today.day);
    return switch (this) {
      CeoReceivedPeriod.thisMonth => (Fmt.ymd(DateTime(d.year, d.month, 1)), Fmt.ymd(d)),
      // day 0 of this month is the last day of the one before
      CeoReceivedPeriod.lastMonth => (Fmt.ymd(DateTime(d.year, d.month - 1, 1)), Fmt.ymd(DateTime(d.year, d.month, 0))),
      CeoReceivedPeriod.chosen => chosen,
    };
  }
}

const _green = Color(0xFF059669);
const _accent = PanelAccent(
    start: Color(0xFF34D399), end: Color(0xFF059669), strong: Color(0xFF047857), soft: Color(0xFFD1FAE5));

/// Money received from customers (web `ReceivedTab.tsx`): this month to today, last month or the chosen period;
/// the total against the same days of the month before, how it came in (Payment By), and who paid.
/// A Payment By narrows the "Who paid" list; a customer opens their receipts.
class CeoReceivedTab extends StatefulWidget {
  const CeoReceivedTab({super.key});

  @override
  State<CeoReceivedTab> createState() => _CeoReceivedTabState();
}

class _CeoReceivedTabState extends State<CeoReceivedTab> {
  CeoReceivedPeriod _period = CeoReceivedPeriod.thisMonth;
  CeoReceivedMethod? _method;

  @override
  Widget build(BuildContext context) => BlocBuilder<CeoDashboardCubit, CeoDashboardState>(builder: (context, _) {
        final cubit = context.read<CeoDashboardCubit>();
        final range = _period.range(cubit.today, cubit.range);
        if (!cubit.hasReceived(range)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!cubit.isClosed) cubit.loadReceived(range);
          });
        }
        final s = cubit.receivedOf(range);
        final d = s.data;
        return CeoTabScroll(children: [
          CeoChips(
            key: const Key('ceo_received_period'),
            options: [for (final p in CeoReceivedPeriod.values) p.label],
            selected: _period.index,
            color: _accent.strong,
            onChanged: (i) => setState(() {
              _period = CeoReceivedPeriod.values[i];
              _method = null;
            }),
          ),
          const SizedBox(height: 4),
          Text(ceoSpan(range), style: AppTypography.badgeText(color: AppTokens.textMuted, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          if (d == null)
            s.error != null
                ? CeoErrorBox(message: s.error!, onRetry: () => cubit.loadReceived(range, force: true))
                : const CeoSpinner()
          else ...[
            _hero(d),
            const SizedBox(height: 12),
            if (d.hasForeign) ...[_currencies(d), const SizedBox(height: 12)],
            _methods(d),
            const SizedBox(height: 12),
            _whoPaid(context, cubit, range),
          ],
        ]);
      });

  Widget _hero(CeoReceived d) {
    final change = d.change;
    return CeoHero(
      key: const Key('ceo_received_hero'),
      title: 'Money received',
      subtitle: 'From customers · ${ceoSpan((d.period.fromDate, d.period.toDate))}',
      icon: Icons.savings_rounded,
      accent: _accent,
      value: Fmt.rm(d.total.amount),
      sub: '${ceoCount(d.total.count)} receipts · ${ceoCount(d.customers)} customers'
          '${d.hasForeign ? ' · in RM' : ''}',
      facts: [
        ('Change', change == null ? '—' : '${change >= 0 ? '+' : ''}${change.toStringAsFixed(1)}%'),
        ('Same days before', '${Fmt.rm(d.compare.amount)} · ${ceoCount(d.compare.count)}'),
      ],
    );
  }

  /// `SGD 10,000.00`.
  static String inCurrency(String currency, double amount) =>
      '$currency ${NumberFormat('#,##0.00', 'en_US').format(amount)}';

  /// The money per currency, as the receipts and the customer statement show it: RM as it is, a foreign
  /// currency in its own money with its RM value.
  Widget _currencies(CeoReceived d) => AccentPanel(
        key: const Key('ceo_received_currencies'),
        title: 'By currency',
        subtitle: 'As on the receipts · totals above are in RM',
        icon: Icons.currency_exchange_rounded,
        accent: CeoAccent.cash,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          for (final c in d.currencies)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Row(children: [
                Container(
                  width: 46,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: CeoAccent.cash.soft, borderRadius: BorderRadius.circular(9)),
                  child: Text(c.currency,
                      style: AppTypography.badgeText(color: CeoAccent.cash.strong, fontWeight: FontWeight.w800)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(inCurrency(c.currency, c.amount),
                          style: AppTypography.bodyMedium(color: AppTokens.textPrimary, fontWeight: FontWeight.w800)),
                    ),
                    Text('${ceoCount(c.count)} ${c.count == 1 ? 'receipt' : 'receipts'} · ${ceoShare(c.amountRm, d.total.amount)}',
                        style: AppTypography.badgeText(color: AppTokens.textMuted, fontWeight: FontWeight.w500)),
                  ]),
                ),
                if (c.isForeign)
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text('IN RM', style: AppTypography.badgeText(color: AppTokens.textMuted, fontWeight: FontWeight.w700)),
                    Text(Fmt.rm(c.amountRm),
                        style: AppTypography.bodySmall(color: _accent.strong, fontWeight: FontWeight.w800)),
                  ]),
              ]),
            ),
        ]),
      );

  /// How it came in: per Payment By, most first; a tap narrows "Who paid" to it.
  Widget _methods(CeoReceived d) => AccentPanel(
        title: 'How it came in',
        subtitle: 'Payment By · tap to see who paid that way',
        icon: Icons.account_balance_rounded,
        accent: _accent,
        child: d.methods.isEmpty
            ? const CeoEmpty(text: 'No money received in these days')
            : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                for (final m in d.methods)
                  _Selectable(
                    selected: _method?.bankId == m.bankId,
                    child: RankRow(
                      key: Key('ceo_received_method_${m.bankId}'),
                      lead: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(color: _accent.soft, borderRadius: BorderRadius.circular(9)),
                        child: Icon(m.isCash ? Icons.payments_rounded : Icons.account_balance_rounded,
                            size: 17, color: _accent.strong),
                      ),
                      title: m.name,
                      subtitle: '${ceoCount(m.count)} receipts · ${ceoShare(m.amount, d.total.amount)}',
                      value: Fmt.rm(m.amount),
                      fraction: d.total.amount <= 0 ? 0 : (m.amount / d.total.amount).clamp(0.0, 1.0),
                      color: _green,
                      onTap: () => setState(() => _method = _method?.bankId == m.bankId ? null : m),
                    ),
                  ),
              ]),
      );

  /// Who paid in the days (or the chosen day), most first, narrowed to the chosen Payment By.
  Widget _whoPaid(BuildContext context, CeoDashboardCubit cubit, (String, String) range) {
    final days = range;
    final key = _method == null ? null : '${_method!.bankId}';
    ceoEnsure(context, CeoDetailKind.receiptCustomers, key, range: days);
    final s = cubit.detailsOf(CeoDetailKind.receiptCustomers, key, range: days);
    final filters = [if (_method != null) _method!.name];
    return AccentPanel(
      title: 'Who paid',
      subtitle: s.data == null
          ? 'Customers'
          : '${ceoCount(s.data!.count)} customers · ${Fmt.rm(s.data!.total)} · tap for their receipts',
      icon: Icons.groups_rounded,
      accent: _accent,
      action: Wrap(spacing: 6, runSpacing: 6, crossAxisAlignment: WrapCrossAlignment.center, children: [
        if (filters.isNotEmpty)
          InputChip(
            key: const Key('ceo_received_clear'),
            label: Text(filters.join(' · ')),
            onDeleted: () => setState(() => _method = null),
            backgroundColor: _accent.soft,
            labelStyle: AppTypography.badgeText(color: _accent.strong, fontWeight: FontWeight.w700),
            side: BorderSide.none,
            visualDensity: VisualDensity.compact,
          ),
        ActionChip(
          key: const Key('ceo_received_all'),
          avatar: Icon(Icons.receipt_long_rounded, size: 16, color: _accent.strong),
          label: const Text('All receipts'),
          labelStyle: AppTypography.badgeText(color: _accent.strong, fontWeight: FontWeight.w700),
          backgroundColor: AppTokens.surfaceCard,
          side: BorderSide(color: _accent.soft),
          visualDensity: VisualDensity.compact,
          onPressed: () => showCeoDetails(context,
              kind: CeoDetailKind.receipts, keyValue: key, label: 'Money received', accent: _accent, range: days),
        ),
      ]),
      child: CeoListState(
        state: s,
        empty: 'No customer paid in these days',
        onRetry: () => cubit.loadDetails(CeoDetailKind.receiptCustomers, key, range: days, force: true),
        builder: (data) {
          final top = data.rows.first.amount;
          return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            for (final row in data.rows)
              RankRow(
                key: Key('ceo_received_customer_${row.id}'),
                lead: CeoRankBadge(text: row.reference, accent: _accent),
                title: row.title.isEmpty ? '#${row.id}' : row.title,
                subtitle: '${row.subtitle} · ${ceoShare(row.amount, data.total)}',
                value: Fmt.rm(row.amount),
                trailingSub: row.foreignAmount.isEmpty ? null : CeoForeignAmount(row.foreignAmount),
                fraction: top <= 0 ? 0 : (row.amount / top).clamp(0.0, 1.0),
                color: _green,
                onTap: () => showCeoDetails(context,
                    kind: CeoDetailKind.receipts,
                    keyValue: key,
                    customer: row.id,
                    label: '${row.title} · receipts',
                    accent: _accent,
                    range: days),
              ),
            CeoShowing(details: data),
          ]);
        },
      ),
    );
  }
}

/// A soft green ring around the chosen row.
class _Selectable extends StatelessWidget {
  const _Selectable({required this.selected, required this.child});

  final bool selected;
  final Widget child;

  @override
  Widget build(BuildContext context) => AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.symmetric(vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: selected ? _accent.soft.withValues(alpha: 0.6) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? _accent.start : Colors.transparent),
        ),
        child: child,
      );
}
