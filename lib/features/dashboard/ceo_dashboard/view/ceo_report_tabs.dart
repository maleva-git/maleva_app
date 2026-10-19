import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/theme/tokens.dart';
import 'package:maleva/core/widgets/ui/formats.dart';
import 'package:maleva/features/dashboard/admin_dashboard/overview/view/overview_widgets.dart';

import '../bloc/ceo_dashboard_cubit.dart';
import '../data/ceo_analytics_models.dart';
import 'ceo_details_sheet.dart';
import 'ceo_sections.dart';
import 'ceo_spend_flow.dart';
import 'ceo_tab_kit.dart';
import 'ceo_widgets.dart';

enum _ExpenseView {
  flow('Money flow', Icons.account_tree_rounded),
  fuel('Fuel', Icons.local_gas_station_rounded),
  category('By category', Icons.donut_large_rounded),
  supplier('By supplier', Icons.store_rounded),
  truck('By truck', Icons.local_shipping_rounded),
  year('12 months', Icons.bar_chart_rounded);

  const _ExpenseView(this.label, this.icon);

  final String label;
  final IconData icon;
}

/// The CEO Expenses tab (web `CeoExpensesTab.tsx`) for the CEO period: the money flow (Purchase Order →
/// Bill → Paid out → Still owed), purchase orders by category, supplier and truck, and the 12 months.
class CeoExpensesTab extends StatefulWidget {
  const CeoExpensesTab({super.key});

  @override
  State<CeoExpensesTab> createState() => _CeoExpensesTabState();
}

class _CeoExpensesTabState extends State<CeoExpensesTab> {
  _ExpenseView _view = _ExpenseView.flow;

  @override
  Widget build(BuildContext context) => BlocBuilder<CeoDashboardCubit, CeoDashboardState>(builder: (context, s) {
        final cubit = context.read<CeoDashboardCubit>();
        final e = s.overview?.expenses;
        final spend = cubit.spendOf().data;
        return CeoTabScroll(children: [
          const CeoPeriodBar(),
          CeoHero(
            key: const Key('ceo_expenses_hero'),
            title: 'Expenses',
            subtitle: 'Purchase orders and money paid out',
            icon: Icons.shopping_bag_rounded,
            accent: CeoAccent.expenses,
            value: e == null ? '…' : Fmt.rm(e.total),
            sub: e == null ? ' ' : '${ceoCount(e.count)} purchase orders',
            facts: [
              ('Paid out', spend == null ? '…' : ceoCompact(spend.paid.amount)),
              ('Still owed', spend == null ? '…' : ceoCompact(spend.stillOwed)),
              ('Checks', spend == null ? '…' : ceoCount(spend.checks.length)),
            ],
          ),
          const SizedBox(height: 12),
          CeoChips(
            key: const Key('ceo_expense_view'),
            options: [for (final v in _ExpenseView.values) v.label],
            icons: [for (final v in _ExpenseView.values) v.icon],
            selected: _view.index,
            color: CeoAccent.expenses.strong,
            onChanged: (i) => setState(() => _view = _ExpenseView.values[i]),
          ),
          const SizedBox(height: 12),
          switch (_view) {
            _ExpenseView.flow => const CeoSpendFlowView(),
            _ExpenseView.fuel => const CeoFuelView(),
            _ExpenseView.category => ExpensesSection(state: s, onRetry: cubit.retry),
            _ExpenseView.supplier =>
              _poBreakdown(cubit, CeoDetailKind.poSuppliers, 'By supplier', Icons.store_rounded),
            _ExpenseView.truck => _poBreakdown(cubit, CeoDetailKind.poTrucks, 'By truck', Icons.local_shipping_rounded),
            _ExpenseView.year => _poYear(cubit),
          },
        ]);
      });

  Widget _poBreakdown(CeoDashboardCubit cubit, String kind, String title, IconData icon) {
    const accent = CeoAccent.expenses;
    final range = cubit.range;
    ceoEnsure(context, kind, null, range: range);
    final s = cubit.detailsOf(kind, null, range: range);
    final drill = ceoDrillOf(kind);
    return AccentPanel(
      title: title,
      subtitle: s.data == null
          ? 'Purchase orders'
          : '${ceoCount(s.data!.rows.length)} · ${Fmt.rm(s.data!.total)} · tap for the POs',
      icon: icon,
      accent: accent,
      child: CeoListState(
        state: s,
        empty: 'No purchase orders in this period',
        onRetry: () => cubit.loadDetails(kind, null, range: range, force: true),
        builder: (d) {
          final top = d.rows.first.amount;
          return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            for (final row in d.rows)
              RankRow(
                key: Key('ceo_po_${kind}_${row.id}'),
                lead: CeoRankBadge(text: row.reference, accent: accent),
                title: row.title.isEmpty ? '#${row.id}' : row.title,
                subtitle: '${row.subtitle} · ${ceoShare(row.amount, d.total)}',
                value: Fmt.rm(row.amount),
                fraction: top <= 0 ? 0 : row.amount / top,
                color: accent.end,
                onTap: drill != null && drill.allowsRow(row)
                    ? () => drill.open(context, row, accent: accent, range: range)
                    : null,
              ),
            CeoShowing(details: d),
          ]);
        },
      ),
    );
  }

  Widget _poYear(CeoDashboardCubit cubit) {
    const accent = CeoAccent.expenses;
    final today = Fmt.ymd(cubit.today);
    final range = (today, today);
    ceoEnsure(context, CeoDetailKind.poMonths, null, range: range);
    final s = cubit.detailsOf(CeoDetailKind.poMonths, null, range: range);
    return AccentPanel(
      title: '12 months',
      subtitle: s.data == null ? 'Purchase orders month by month' : '${ceoCount(s.data!.count)} POs · ${Fmt.rm(s.data!.total)}',
      icon: Icons.bar_chart_rounded,
      accent: accent,
      child: CeoListState(
        state: s,
        onRetry: () => cubit.loadDetails(CeoDetailKind.poMonths, null, range: range, force: true),
        builder: (d) {
          final oldestFirst = d.rows.reversed.toList();
          final best = d.rows.fold<double>(0, (a, r) => r.amount > a ? r.amount : a);
          return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Padding(
              padding: const EdgeInsets.only(top: 6, bottom: 8),
              child: MonthChart(
                names: [for (final r in oldestFirst) r.title],
                amounts: [for (final r in oldestFirst) r.amount],
                counts: [for (final r in oldestFirst) ceoJobsOf(r)],
                accent: accent,
              ),
            ),
            for (final row in d.rows)
              RankRow(
                title: row.title,
                subtitle: row.subtitle,
                value: Fmt.rm(row.amount),
                fraction: best <= 0 ? 0 : row.amount / best,
                color: accent.end,
              ),
          ]);
        },
      ),
    );
  }
}



/// Cash: receivable and payable with their ageing and money paid out, then who owes us and whom we owe,
/// party by party (as of today); a name opens the invoices or bills behind it.
class CeoCashTab extends StatelessWidget {
  const CeoCashTab({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<CeoDashboardCubit, CeoDashboardState>(
        builder: (context, s) => CeoTabScroll(children: [
          const CeoPeriodBar(),
          CashSection(state: s, onRetry: context.read<CeoDashboardCubit>().retry),
          const SizedBox(height: 12),
          const CeoOwedPanel(),
        ]),
      );
}

/// Customers who owe us / whom we owe, most owed first, with the age of the oldest money.
class CeoOwedPanel extends StatefulWidget {
  const CeoOwedPanel({super.key});

  @override
  State<CeoOwedPanel> createState() => _CeoOwedPanelState();
}

class _CeoOwedPanelState extends State<CeoOwedPanel> {
  bool _receivable = true;

  /// Green when current, amber to red as the money gets older.
  static Color ageColor(String status) {
    final s = status.toUpperCase();
    if (s.startsWith('OVER 90')) return const Color(0xFFE11D48);
    if (s.startsWith('61-90')) return const Color(0xFFF97316);
    if (s.startsWith('31-60')) return const Color(0xFFF59E0B);
    if (s.startsWith('1-30')) return const Color(0xFF65A30D);
    return const Color(0xFF10B981);
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<CeoDashboardCubit, CeoDashboardState>(builder: (context, _) {
        final cubit = context.read<CeoDashboardCubit>();
        final kind = _receivable ? CeoDetailKind.receivableCustomers : CeoDetailKind.payableParties;
        final accent = _receivable ? PanelAccent.emerald : PanelAccent.rose;
        // as of today: the days only key the list
        final today = Fmt.ymd(cubit.today);
        final range = (today, today);
        ceoEnsure(context, kind, null, range: range);
        final s = cubit.detailsOf(kind, null, range: range);
        final drill = ceoDrillOf(kind);
        return AccentPanel(
          key: const Key('ceo_owed_panel'),
          title: _receivable ? 'Who owes us' : 'Whom we owe',
          subtitle: s.data == null
              ? 'As of today'
              : '${ceoCount(s.data!.count)} ${_receivable ? 'customers' : 'suppliers and payees'} · ${Fmt.rm(s.data!.total)}'
                  '${_receivable ? ' in RM' : ''} · tap a name',
          icon: _receivable ? Icons.call_received_rounded : Icons.call_made_rounded,
          accent: accent,
          action: CeoChips(
            key: const Key('ceo_owed_side'),
            options: const ['Customers who owe us', 'Whom we owe'],
            selected: _receivable ? 0 : 1,
            color: accent.strong,
            onChanged: (i) => setState(() => _receivable = i == 0),
          ),
          child: CeoListState(
            state: s,
            empty: _receivable ? 'No customer owes us anything' : 'We owe nothing today',
            onRetry: () => cubit.loadDetails(kind, null, range: range, force: true),
            builder: (d) {
              final top = d.rows.first.amount;
              return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                for (final row in d.rows)
                  RankRow(
                    key: Key('ceo_owed_${_receivable ? 'cus' : 'sup'}_${row.id}'),
                    lead: CeoRankBadge(text: row.reference, accent: accent),
                    title: row.title.isEmpty ? '#${row.id}' : row.title,
                    subtitle: row.subtitle,
                    value: Fmt.rm(row.amount),
                    trailingSub: row.status.isEmpty && row.foreignAmount.isEmpty
                        ? null
                        : Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                            CeoForeignAmount(row.foreignAmount),
                            if (row.status.isNotEmpty)
                              Text(row.status,
                                  maxLines: 1,
                                  style:
                                      TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: ageColor(row.status))),
                          ]),
                    fraction: top <= 0 ? 0 : (row.amount / top).clamp(0.0, 1.0),
                    color: ageColor(row.status),
                    onTap: drill != null && drill.allowsRow(row)
                        ? () => drill.open(context, row, accent: accent, range: range)
                        : null,
                  ),
                CeoShowing(details: d),
              ]);
            },
          ),
        );
      });
}



/// Fuel from the fuel entries only (owner 2026-10-17): the saved PAmount as it is, fills, trucks and the period
/// before; per truck (tap for its entries) and every entry.
class CeoFuelView extends StatelessWidget {
  const CeoFuelView({super.key});

  static const accent = PanelAccent(
      start: Color(0xFFF59E0B), end: Color(0xFFEA580C), strong: Color(0xFFC2410C), soft: Color(0xFFFFEDD5));

  @override
  Widget build(BuildContext context) => BlocBuilder<CeoDashboardCubit, CeoDashboardState>(builder: (context, _) {
        final cubit = context.read<CeoDashboardCubit>();
        final range = cubit.range;
        if (!cubit.hasFuel(range: range)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!cubit.isClosed) cubit.loadFuel(range: range);
          });
        }
        final s = cubit.fuelOf(range: range);
        final f = s.data;
        if (f == null) {
          return s.error != null
              ? CeoErrorBox(message: s.error!, onRetry: () => cubit.loadFuel(range: range, force: true))
              : const CeoSpinner();
        }
        final change = f.change;
        ceoEnsure(context, CeoDetailKind.fuelTrucks, null, range: range);
        final trucks = cubit.detailsOf(CeoDetailKind.fuelTrucks, null, range: range);
        final drill = ceoDrillOf(CeoDetailKind.fuelTrucks);
        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          CeoHero(
            key: const Key('ceo_fuel_hero'),
            title: 'Fuel (fuel entries)',
            subtitle: 'Amount = PAmount of each Fuel Entry',
            icon: Icons.local_gas_station_rounded,
            accent: accent,
            value: Fmt.rm(f.amount),
            sub: 'Before: ${Fmt.rm(f.previousAmount)} · ${ceoCount(f.previousEntries)} fills',
            facts: [
              ('Fills', ceoCount(f.entries)),
              ('Trucks', ceoCount(f.trucks)),
              ('Change', change == null ? '—' : '${change >= 0 ? '+' : ''}${change.toStringAsFixed(1)}%'),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTokens.surfaceCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: accent.soft),
            ),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(Icons.speed_rounded, size: 20, color: accent.strong),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Amount = the PAmount saved on each Fuel Entry, shown as it is (nothing is recalculated). '
                  'Purchase orders are not counted here.',
                  style: TextStyle(fontSize: 12, color: AppTokens.textMuted),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 12),
          AccentPanel(
            title: 'By truck',
            subtitle: trucks.data == null
                ? 'Fuel per truck'
                : '${ceoCount(trucks.data!.count)} trucks · tap for its fuel entries',
            icon: Icons.local_shipping_rounded,
            accent: accent,
            action: ActionChip(
              key: const Key('ceo_fuel_all'),
              avatar: Icon(Icons.receipt_long_rounded, size: 16, color: accent.strong),
              label: const Text('All fuel entries'),
              backgroundColor: AppTokens.surfaceCard,
              side: BorderSide(color: accent.soft),
              visualDensity: VisualDensity.compact,
              onPressed: () => showCeoDetails(context,
                  kind: CeoDetailKind.fuelEntries, label: 'Fuel entries', accent: accent, range: range),
            ),
            child: CeoListState(
              state: trucks,
              empty: 'No fuel entries in this period',
              onRetry: () => cubit.loadDetails(CeoDetailKind.fuelTrucks, null, range: range, force: true),
              builder: (d) {
                final top = d.rows.first.amount;
                return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  for (final row in d.rows)
                    RankRow(
                      key: Key('ceo_fuel_truck_${row.id}'),
                      lead: CeoRankBadge(text: row.reference, accent: accent),
                      title: row.title,
                      subtitle: row.subtitle,
                      value: Fmt.rm(row.amount),
                      fraction: top <= 0 ? 0 : (row.amount / top).clamp(0.0, 1.0),
                      color: accent.end,
                      onTap: drill != null && drill.allowsRow(row)
                          ? () => drill.open(context, row, accent: accent, range: range)
                          : null,
                    ),
                  CeoShowing(details: d),
                ]);
              },
            ),
          ),
        ]);
      });
}
