import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/theme/app_typography.dart';
import 'package:maleva/core/theme/palette.dart';
import 'package:maleva/core/theme/tokens.dart';
import 'package:maleva/core/widgets/ui/formats.dart';
import 'package:maleva/features/dashboard/admin_dashboard/overview/bloc/admin_overview_cubit.dart' show AreaState;
import 'package:maleva/features/dashboard/admin_dashboard/overview/view/overview_widgets.dart';

import '../bloc/ceo_dashboard_cubit.dart';
import '../data/ceo_analytics_models.dart';
import 'ceo_charts.dart';
import 'ceo_details_sheet.dart';
import 'ceo_widgets.dart';

/// One part of the overview as an [AreaState] for [AreaBody]: loading or the load's error while there is
/// no overview yet; "did not load" when the answer came without that part.
AreaState<T> ceoArea<T extends Object>(CeoDashboardState s, T? Function(CeoOverview o) pick) {
  final o = s.overview;
  if (o == null) {
    return s.error != null && !s.loading ? AreaState<T>(error: s.error) : AreaState<T>(loading: true);
  }
  final part = pick(o);
  return part == null ? AreaState<T>(error: 'This part did not load') : AreaState<T>(data: part);
}

/// The server's note that some of [section]'s numbers could not be loaded (they came as zeros).
List<Widget> _unavailable(CeoDashboardState s, String section) {
  final parts = s.overview?.unavailableIn(section) ?? const [];
  return parts.isEmpty ? const [] : [CeoUnavailableNote(parts: parts)];
}

/// The fraction of [part] in [whole].
double _fraction(double part, double whole) => whole <= 0 ? 0 : part / whole;

class ExpensesSection extends StatelessWidget {
  const ExpensesSection({super.key, required this.state, required this.onRetry});

  final CeoDashboardState state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    const accent = CeoAccent.expenses;
    final e = state.overview?.expenses;
    return AccentPanel(
      title: 'Expenses',
      subtitle: e == null ? 'Purchase orders by category' : '${ceoCount(e.count)} purchase orders · ${Fmt.rm(e.total)}',
      icon: Icons.receipt_long_rounded,
      accent: accent,
      child: AreaBody<CeoExpenses>(
        area: ceoArea(state, (o) => o.expenses),
        onRetry: onRetry,
        builder: (e) {
          void open(CeoGroup c) => showCeoDetails(context,
              kind: CeoDetailKind.expenseCategory,
              keyValue: c.key,
              label: '${c.name} · ${ceoCount(c.count)} POs',
              accent: accent);
          return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            ..._unavailable(state, 'expenses'),
            if (e.categories.isEmpty)
              const CeoQuiet('No purchase orders in this period')
            else ...[
              const SizedBox(height: 6),
              ExpenseDonut(categories: e.categories, total: e.total, onTap: (i) => open(e.categories[i])),
              const SizedBox(height: 6),
              Center(child: ChangeChip(change: e.change, upIsGood: false, suffix: ' vs previous period')),
              const CeoSubheading('By category', hint: 'Tap for the POs'),
              for (var i = 0; i < e.categories.length; i++)
                RankRow(
                  lead: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(color: ExpenseDonut.colorOf(i), shape: BoxShape.circle),
                  ),
                  title: e.categories[i].name,
                  subtitle: '${ceoCount(e.categories[i].count)} POs · ${ceoShare(e.categories[i].amount, e.total)}',
                  value: Fmt.rm(e.categories[i].amount),
                  trailingSub: ChangeChip(change: e.categories[i].change, upIsGood: false),
                  fraction: _fraction(e.categories[i].amount, e.total),
                  color: ExpenseDonut.colorOf(i),
                  onTap: () => open(e.categories[i]),
                ),
            ],
            const CeoSubheading('Running costs'),
            if (e.running.isEmpty)
              const CeoQuiet('No running costs in this period')
            else
              CeoGrid(columns: 2, children: [
                for (final g in e.running)
                  MiniStat(
                      label: g.name,
                      value: Fmt.rm(g.amount),
                      sub: '${ceoCount(g.count)} entries',
                      color: accent.strong),
              ]),
          ]);
        },
      ),
    );
  }
}

class CashSection extends StatelessWidget {
  const CashSection({super.key, required this.state, required this.onRetry});

  final CeoDashboardState state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    const accent = CeoAccent.cash;
    return AccentPanel(
      title: 'Cash',
      subtitle: 'Receivable vs payable, by age',
      icon: Icons.account_balance_wallet_rounded,
      accent: accent,
      child: AreaBody<CeoCash>(
        area: ceoArea(state, (o) => o.cash),
        onRetry: onRetry,
        builder: (c) {
          final net = c.receivableOutstanding - c.payableOutstanding;
          return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            ..._unavailable(state, 'cash'),
            const SizedBox(height: 6),
            CeoGrid(columns: 3, children: [
              MiniStat(label: 'Receivable', value: Fmt.rm(c.receivableOutstanding), color: PanelAccent.emerald.strong),
              MiniStat(label: 'Payable', value: Fmt.rm(c.payableOutstanding), color: PanelAccent.rose.strong),
              MiniStat(
                  label: 'Net',
                  value: Fmt.rm(net),
                  sub: net >= 0 ? 'owed to us' : 'we owe more',
                  color: net >= 0 ? Palette.greenEco : Palette.rose),
            ]),
            const CeoSubheading('Receivable · days since invoice'),
            MoneySplitBar(
              labels: [for (final b in c.receivableAgeing) b.label],
              amounts: [for (final b in c.receivableAgeing) b.amount],
              colors: CeoAccent.ageing,
            ),
            if (c.hasForeignReceivable) ...[
              const CeoSubheading('Receivable by currency', hint: 'in RM at today\'s rate'),
              for (final cur in c.receivableCurrencies) _CurrencyLine(key: Key('ceo_cash_currency_${cur.currency}'), currency: cur),
            ],
            const CeoSubheading('Payable · days past due'),
            MoneySplitBar(
              labels: [for (final b in c.payableAgeing) b.label],
              amounts: [for (final b in c.payableAgeing) b.amount],
              colors: CeoAccent.ageing,
            ),
            const SizedBox(height: 12),
            StatTile(
              label: 'Paid out',
              value: Fmt.rm(c.paidOutAmount),
              sub: '${ceoCount(c.paidOutCount)} payments in this period',
              icon: Icons.payments_rounded,
              color: accent.strong,
            ),
          ]);
        },
      ),
    );
  }
}

/// The 403 answer: a calm page instead of an error.
class CeoOnlyNotice extends StatelessWidget {
  const CeoOnlyNotice({super.key, required this.onOpenAdmin});

  final VoidCallback onOpenAdmin;

  @override
  Widget build(BuildContext context) => Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [AppTokens.brandGradientStart, AppTokens.brandGradientEnd]),
              ),
              child: const Icon(Icons.lock_rounded, color: Colors.white, size: 34),
            ),
            const SizedBox(height: 18),
            Text('This dashboard is for the CEO only',
                textAlign: TextAlign.center,
                style: AppTypography.heading2(color: AppTokens.textPrimary, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text('Your account can use the admin dashboard.',
                textAlign: TextAlign.center, style: AppTypography.bodyMedium(color: AppTokens.textMuted)),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onOpenAdmin,
              icon: const Icon(Icons.space_dashboard_rounded, size: 18),
              label: const Text('Open admin dashboard'),
            ),
          ]),
        ),
      );
}

/// One currency of the receivable: its own amount (as on the customer statement), customers and invoices, and
/// for a foreign currency the rate and the RM value.
class _CurrencyLine extends StatelessWidget {
  const _CurrencyLine({super.key, required this.currency});

  final CeoReceivableCurrency currency;

  @override
  Widget build(BuildContext context) {
    final c = currency;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(children: [
        Container(
          width: 44,
          height: 26,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: CeoAccent.cash.soft, borderRadius: BorderRadius.circular(8)),
          child: Text(c.currency,
              style: AppTypography.badgeText(color: CeoAccent.cash.strong, fontWeight: FontWeight.w800)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text('${c.currency} ${NumberFormat('#,##0.00', 'en_US').format(c.amount)}',
                  style: AppTypography.bodySmall(color: AppTokens.textPrimary, fontWeight: FontWeight.w800)),
            ),
            Text(
                '${ceoCount(c.customers)} ${c.customers == 1 ? 'customer' : 'customers'} · '
                '${ceoCount(c.invoices)} ${c.invoices == 1 ? 'invoice' : 'invoices'}'
                '${c.isForeign ? ' · @ ${c.rate.toStringAsFixed(4)}' : ''}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.badgeText(color: AppTokens.textMuted, fontWeight: FontWeight.w500)),
          ]),
        ),
        if (c.isForeign)
          Text(Fmt.rm(c.amountRm),
              style: AppTypography.bodySmall(color: PanelAccent.emerald.strong, fontWeight: FontWeight.w800)),
      ]),
    );
  }
}
