import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/theme/app_typography.dart';
import 'package:maleva/core/theme/tokens.dart';
import 'package:maleva/core/widgets/ui/formats.dart';
import 'package:maleva/features/dashboard/admin_dashboard/overview/view/overview_widgets.dart';

import '../bloc/ceo_dashboard_cubit.dart';
import '../data/ceo_analytics_models.dart';
import '../data/ceo_period.dart';
import 'ceo_details_sheet.dart';
import 'ceo_tab_kit.dart';
import 'ceo_widgets.dart';

/// The lists one document type answers (web `model/docSources.ts`): sale orders or invoices.
class CeoDocSource {
  const CeoDocSource({
    required this.id,
    required this.title,
    required this.noun,
    required this.icon,
    required this.accent,
    required this.list,
    required this.employees,
    required this.customers,
    required this.months,
    required this.invoiceFilter,
  });

  final String id;
  final String title;

  /// `sale orders`, `invoices`.
  final String noun;
  final IconData icon;
  final PanelAccent accent;
  final String list;
  final String employees;
  final String customers;
  final String months;

  /// The With / Without invoice filter applies (sale orders only).
  final bool invoiceFilter;

  static const saleOrders = CeoDocSource(
    id: 'sale',
    title: 'Sale Orders',
    noun: 'sale orders',
    icon: Icons.receipt_long_rounded,
    accent: PanelAccent.emerald,
    list: CeoDetailKind.saleOrders,
    employees: CeoDetailKind.saleOrderEmployees,
    customers: CeoDetailKind.customers,
    months: CeoDetailKind.saleOrderMonths,
    invoiceFilter: true,
  );

  static const invoices = CeoDocSource(
    id: 'invoice',
    title: 'Invoices',
    noun: 'invoices',
    icon: Icons.request_quote_rounded,
    accent: PanelAccent.indigo,
    list: CeoDetailKind.invoices,
    employees: CeoDetailKind.invoiceEmployees,
    customers: CeoDetailKind.invoiceCustomers,
    months: CeoDetailKind.invoiceMonths,
    invoiceFilter: false,
  );
}

enum _DocView {
  employee('By employee', Icons.badge_rounded),
  customer('By customer', Icons.storefront_rounded),
  all('All', Icons.view_list_rounded),
  year('12 months', Icons.bar_chart_rounded);

  const _DocView(this.label, this.icon);

  final String label;
  final IconData icon;
}

const _periodIcons = {
  'TODAY': Icons.today_rounded,
  'YESTERDAY': Icons.history_rounded,
  'WEEK': Icons.date_range_rounded,
  'MONTH': Icons.calendar_month_rounded,
};

/// The CEO Sale Orders / Invoices tab (web `SaleOrdersPanel.tsx`): Today, Yesterday, This week and This
/// month as cards (count and amount; a tap chooses the days), the invoice filter (sale orders), and the
/// chosen days By employee, By customer, All, or the 12 months. A row opens its own list in a sheet.
class CeoDocTab extends StatefulWidget {
  const CeoDocTab({super.key, required this.source});

  final CeoDocSource source;

  @override
  State<CeoDocTab> createState() => _CeoDocTabState();
}

class _CeoDocTabState extends State<CeoDocTab> {
  String _period = 'TODAY';
  _DocView _view = _DocView.employee;
  CeoInvoiceFilter _filter = CeoInvoiceFilter.all;

  CeoDocSource get _src => widget.source;

  /// The invoice parameter, only for sale orders and not for All.
  String? get _invoice => _src.invoiceFilter && _filter != CeoInvoiceFilter.all ? _filter.param : null;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CeoDashboardCubit, CeoDashboardState>(builder: (context, _) {
      final cubit = context.read<CeoDashboardCubit>();
      final periods = CeoSalePeriod.of(cubit.today);
      final chosen = periods.firstWhere((p) => p.key == _period, orElse: () => periods.first);
      final accent = _src.accent;
      for (final p in periods) {
        ceoEnsure(context, _src.list, null, range: p.range, invoice: _invoice);
      }
      final now = cubit.detailsOf(_src.list, null, range: chosen.range, invoice: _invoice).data;

      return CeoTabScroll(children: [
        CeoHero(
          key: Key('ceo_${_src.id}_hero'),
          title: _src.title,
          subtitle: '${chosen.label} · ${ceoSpan(chosen.range)}${_invoice == null ? '' : ' · ${_filter.label}'}',
          icon: _src.icon,
          accent: accent,
          value: now == null ? '…' : Fmt.rm(now.total),
          sub: now == null ? ' ' : '${ceoCount(now.count)} ${_src.noun}',
        ),
        const SizedBox(height: 12),
        CeoGrid(columns: 2, spacing: 10, children: [
          for (final p in periods) _periodCard(cubit, p, accent),
        ]),
        if (_src.invoiceFilter) ...[
          const SizedBox(height: 12),
          CeoChips(
            key: const Key('ceo_invoice_filter'),
            options: [for (final f in CeoInvoiceFilter.values) f.label],
            selected: _filter.index,
            color: accent.strong,
            onChanged: (i) => setState(() => _filter = CeoInvoiceFilter.values[i]),
          ),
        ],
        const SizedBox(height: 10),
        CeoChips(
          key: Key('ceo_${_src.id}_view'),
          options: [for (final v in _DocView.values) v.label],
          icons: [for (final v in _DocView.values) v.icon],
          selected: _view.index,
          color: AppTokens.brandGradientStart,
          onChanged: (i) => setState(() => _view = _DocView.values[i]),
        ),
        const SizedBox(height: 12),
        switch (_view) {
          _DocView.employee => _breakdown(cubit, chosen, _src.employees, 'Employees', Icons.badge_rounded),
          _DocView.customer => _breakdown(cubit, chosen, _src.customers, 'Customers', Icons.storefront_rounded),
          _DocView.all => _all(cubit, chosen),
          _DocView.year => _year(cubit),
        },
      ]);
    });
  }

  Widget _periodCard(CeoDashboardCubit cubit, CeoSalePeriod p, PanelAccent accent) {
    final s = cubit.detailsOf(_src.list, null, range: p.range, invoice: _invoice);
    final d = s.data;
    return CeoSelectCard(
      key: Key('ceo_${_src.id}_period_${p.key}'),
      label: p.label,
      value: d != null ? ceoCount(d.count) : (s.error != null ? '—' : '…'),
      sub: d != null ? Fmt.rm(d.total) : (s.error != null ? 'Could not load' : ' '),
      icon: _periodIcons[p.key] ?? Icons.event_rounded,
      color: accent.strong,
      selected: p.key == _period,
      onTap: () => setState(() => _period = p.key),
    );
  }

  /// Employees (most documents first) or customers (most money first) of the chosen days.
  Widget _breakdown(CeoDashboardCubit cubit, CeoSalePeriod p, String kind, String title, IconData icon) {
    final accent = _src.accent;
    final invoice = _invoice;
    ceoEnsure(context, kind, null, range: p.range, invoice: invoice);
    final s = cubit.detailsOf(kind, null, range: p.range, invoice: invoice);
    final drill = ceoDrillOf(kind, invoice: invoice);
    final byCount = kind == _src.employees;
    return AccentPanel(
      title: title,
      subtitle: s.data == null
          ? p.label
          : '${ceoCount(s.data!.rows.length)} ${title.toLowerCase()} · ${p.label} · tap for their ${_src.noun}',
      icon: icon,
      accent: accent,
      child: CeoListState(
        state: s,
        empty: 'No ${_src.noun} in these days',
        onRetry: () => cubit.loadDetails(kind, null, range: p.range, invoice: invoice, force: true),
        builder: (d) {
          final top = d.rows.isEmpty
              ? 0.0
              : (byCount ? ceoJobsOf(d.rows.first).toDouble() : d.rows.first.amount);
          return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            for (final row in d.rows)
              RankRow(
                key: Key('ceo_${_src.id}_${byCount ? 'emp' : 'cus'}_${row.id}'),
                lead: CeoRankBadge(text: row.reference, accent: accent),
                title: row.title.isEmpty ? '#${row.id}' : row.title,
                subtitle: byCount ? null : '${row.subtitle} · ${ceoShare(row.amount, d.total)}',
                value: byCount ? '${ceoCount(ceoJobsOf(row))} ${_src.noun}' : Fmt.rm(row.amount),
                trailingSub: byCount
                    ? Text(Fmt.rm(row.amount),
                        maxLines: 1,
                        style: AppTypography.badgeText(color: accent.strong, fontWeight: FontWeight.w700))
                    : null,
                fraction: top <= 0
                    ? 0
                    : (byCount ? ceoJobsOf(row) / top : row.amount / top).clamp(0.0, 1.0),
                color: accent.end,
                onTap: drill != null && drill.allowsRow(row)
                    ? () => drill.open(context, row, accent: accent, range: p.range)
                    : null,
              ),
            CeoShowing(details: d),
          ]);
        },
      ),
    );
  }

  /// Every document of the chosen days, newest first.
  Widget _all(CeoDashboardCubit cubit, CeoSalePeriod p) {
    final accent = _src.accent;
    final s = cubit.detailsOf(_src.list, null, range: p.range, invoice: _invoice);
    return AccentPanel(
      title: 'All ${_src.noun}',
      subtitle: '${p.label} · newest first',
      icon: Icons.view_list_rounded,
      accent: accent,
      child: CeoListState(
        state: s,
        empty: 'No ${_src.noun} in these days',
        onRetry: () => cubit.loadDetails(_src.list, null, range: p.range, invoice: _invoice, force: true),
        builder: (d) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          for (var i = 0; i < d.rows.length; i++)
            CeoDetailRowTile(row: d.rows[i], accent: accent, last: i == d.rows.length - 1),
          CeoShowing(details: d, noun: _src.noun),
        ]),
      ),
    );
  }

  /// The 12 months to this one: a bar chart and a line per month; a month opens its customers.
  Widget _year(CeoDashboardCubit cubit) {
    final accent = _src.accent;
    final today = Fmt.ymd(cubit.today);
    final range = (today, today);
    final invoice = _invoice;
    ceoEnsure(context, _src.months, null, range: range, invoice: invoice);
    final s = cubit.detailsOf(_src.months, null, range: range, invoice: invoice);
    return AccentPanel(
      title: '12 months',
      subtitle: s.data == null
          ? 'Month by month'
          : '${ceoCount(s.data!.count)} ${_src.noun} · ${Fmt.rm(s.data!.total)} · tap a month for its customers',
      icon: Icons.bar_chart_rounded,
      accent: accent,
      child: CeoListState(
        state: s,
        onRetry: () => cubit.loadDetails(_src.months, null, range: range, invoice: invoice, force: true),
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
                key: Key('ceo_${_src.id}_month_${row.reference}'),
                lead: const Icon(Icons.calendar_month_rounded, size: 18, color: AppTokens.textMuted),
                title: row.title,
                subtitle: row.subtitle,
                value: Fmt.rm(row.amount),
                fraction: best <= 0 ? 0 : row.amount / best,
                color: accent.end,
                onTap: ceoMonthRange(row.reference) == null
                    ? null
                    : () => showCeoDetails(context,
                        kind: _src.customers,
                        label: '${row.title} · customers',
                        accent: accent,
                        range: ceoMonthRange(row.reference),
                        invoice: _src.invoiceFilter ? invoice : null),
              ),
          ]);
        },
      ),
    );
  }
}
