import 'package:maleva/features/auth/presentation/dashboard_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/models/shared/menu_master_model.dart';
import 'package:maleva/core/theme/app_typography.dart';
import 'package:maleva/core/theme/palette.dart';
import 'package:maleva/core/theme/status_tone.dart';
import 'package:maleva/core/theme/tokens.dart';
import 'package:maleva/core/utils/app_globals.dart';
import 'package:maleva/core/widgets/ui/formats.dart';
import 'package:maleva/core/widgets/ui/status_pill.dart';
import 'package:maleva/features/dashboard/common_tabs/vesselplanningweb/view/vesselplanningweb_tab.dart';
import 'package:maleva/features/mail_monitor/view/level_look.dart';
import 'package:maleva/features/planning/plans/view/plans_page.dart';
import 'package:maleva/features/truck_location/presentation/truck_location_routes.dart';

import '../bloc/admin_overview_cubit.dart';
import '../data/admin_overview_models.dart';
import '../data/admin_overview_repository.dart';
import 'overview_widgets.dart';

final _count = NumberFormat('#,##0', 'en_US');
String _n(int v) => _count.format(v);

/// The admin dashboard tabs the Overview's buttons switch to, by their tab-bar label.
abstract final class OverviewTabLinks {
  static const salesOrders = 'SO';
  static const jobOrders = 'JobOrders';
  static const mailboxMonitor = 'Mailbox Monitor';
  static const irReport = 'IR Report';
  static const invoice = 'Invoice';
}

/// The Super Admin's first tab on the admin dashboard: the day's numbers of SO, JO, Mailbox Monitor,
/// IR, truck and vessel planning and truck location, with a button to open each
/// (change `super-admin-overview-tab`), laid out as the web Super Admin dashboard
/// (change `admin-overview-web-layout`).
class AdminOverviewTab extends StatefulWidget {
  const AdminOverviewTab({super.key, required this.onOpenTab, this.repository, this.menu, this.salesAllowed});

  /// Switches the dashboard to the tab with this label ([OverviewTabLinks]).
  final void Function(String tabLabel) onOpenTab;

  /// For tests; the app builds it from the service locator.
  final AdminOverviewRepository? repository;

  /// Whether the sale order numbers show (the CEO only, change ceo-only-sale-order-numbers);
  /// defaults to the signed-in user.
  final bool? salesAllowed;

  /// The user's menu entries; defaults to the signed-in menu. A screen button shows only when its
  /// entry is there.
  final List<MenuMasterModel>? menu;

  @override
  State<AdminOverviewTab> createState() => _AdminOverviewTabState();
}

class _AdminOverviewTabState extends State<AdminOverviewTab> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late final bool _salesAllowed = widget.salesAllowed ?? signedInIsCeo();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocProvider(
      create: (_) => AdminOverviewCubit(widget.repository ?? AdminOverviewRepository.fromServiceLocator(),
          salesAllowed: _salesAllowed)
        ..load(),
      child: _OverviewView(
        salesAllowed: _salesAllowed,
        onOpenTab: widget.onOpenTab,
        menu: widget.menu ?? [...AppGlobals.parentclass, ...AppGlobals.objMenuMaster],
      ),
    );
  }
}

class _OverviewView extends StatefulWidget {
  const _OverviewView({required this.onOpenTab, required this.menu, required this.salesAllowed});

  final void Function(String tabLabel) onOpenTab;
  final bool salesAllowed;
  final List<MenuMasterModel> menu;

  @override
  State<_OverviewView> createState() => _OverviewViewState();
}

/// The web Super Admin dashboard's centre on a phone or tablet: header with the four numbers, Quick Access,
/// the report card (Sale Order / Invoice), then the app's mailbox, incident and truck-location cards. The web's
/// pickup and vessel side panels are left out (owner, 2026-10-16); their screens open from Quick Access.
class _OverviewViewState extends State<_OverviewView> {
  /// The report card's view: 0 sale orders, 1 invoices. Without sale order numbers it is invoices.
  late int _report = widget.salesAllowed ? 0 : 1;

  void Function(String tabLabel) get onOpenTab => widget.onOpenTab;

  MenuMasterModel? _entry(String formText) {
    for (final m in widget.menu) {
      if (m.FormText == formText) return m;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppTokens.surfacePage,
      child: LayoutBuilder(builder: (context, constraints) {
        final isTablet = constraints.maxWidth >= 600;
        return BlocBuilder<AdminOverviewCubit, AdminOverviewState>(builder: (context, s) {
          final cubit = context.read<AdminOverviewCubit>();
          return RefreshIndicator(
            color: AppTokens.brandGradientStart,
            onRefresh: cubit.load,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(isTablet ? 20 : 12, 6, isTablet ? 20 : 12, 28),
              children: [
                _Header(
                    state: s,
                    isTablet: isTablet,
                    onRefresh: cubit.load,
                    onRetry: cubit.retry,
                    onOpenTab: onOpenTab,
                    salesAllowed: widget.salesAllowed),
                const SizedBox(height: 18),
                const _Heading(icon: Icons.auto_awesome, text: 'Quick access'),
                const SizedBox(height: 10),
                _Grid(
                  columns: isTablet ? 7 : 4,
                  spacing: 10,
                  children: _buttons(context),
                ),
                const SizedBox(height: 20),
                const _Heading(icon: Icons.insights_outlined, text: 'Sales report'),
                const SizedBox(height: 10),
                _reportCard(s, cubit, isTablet),
                const SizedBox(height: 20),
                const _Heading(icon: Icons.dashboard_outlined, text: 'Operations'),
                const SizedBox(height: 10),
                _Sections(isTablet: isTablet, children: _sections(context, s, cubit)),
              ],
            ),
          );
        });
      }),
    );
  }

  List<QuickButton> _buttons(BuildContext context) {
    final vessel = _entry('Vessel Planning');
    final planning = _entry('Planning');
    final trucks = _entry('Truck Location');
    return [
      if (widget.salesAllowed)
        QuickButton(
            label: 'SO',
            icon: Icons.receipt_long_rounded,
            color: Palette.blueMid,
            onTap: () => onOpenTab(OverviewTabLinks.salesOrders)),
      QuickButton(
          label: 'JO',
          icon: Icons.build_rounded,
          color: const Color(0xFF7C3AED),
          onTap: () => onOpenTab(OverviewTabLinks.jobOrders)),
      QuickButton(
          label: 'Mailbox',
          icon: Icons.mail_rounded,
          color: PanelAccent.teal.end,
          onTap: () => onOpenTab(OverviewTabLinks.mailboxMonitor)),
      QuickButton(
          label: 'IR Report',
          icon: Icons.report_rounded,
          color: PanelAccent.rose.end,
          onTap: () => onOpenTab(OverviewTabLinks.irReport)),
      if (vessel != null)
        QuickButton(
            label: 'Vessel Planning',
            icon: Icons.directions_boat_rounded,
            color: PanelAccent.indigo.end,
            onTap: () => _openVessel(context, vessel)),
      if (planning != null)
        QuickButton(
            label: 'Truck Planning',
            icon: Icons.local_shipping_rounded,
            color: Palette.amberGold,
            onTap: () => _openPlanning(context)),
      if (trucks != null)
        QuickButton(
            label: 'Truck Location',
            icon: Icons.location_on_rounded,
            color: PanelAccent.green.end,
            onTap: () => _openTrucks(context)),
    ];
  }

  // The screens open as the side menu opens them.
  void _openVessel(BuildContext context, MenuMasterModel e) => Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (_) => VesselPlanningWebTab(
            pageView: e.PageView == 1,
            pageAdd: e.PageAdd == 1,
            pageEdit: e.PageEdit == 1,
            pageDelete: e.PageDelete == 1,
          ),
        ),
      );

  void _openPlanning(BuildContext context) =>
      Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const PlansPage()));

  void _openTrucks(BuildContext context) => Navigator.push(context, TruckLocationRoutes.board());

  /// The web report centre's Sale Order / Invoice view: today, yesterday, this week, this month, then
  /// the months as a chart.
  Widget _reportCard(AdminOverviewState s, AdminOverviewCubit cubit, bool isTablet) {
    final invoice = _report == 1;
    final accent = invoice ? PanelAccent.indigo : PanelAccent.emerald;
    final area = invoice ? s.invoices : s.sales;
    return AccentPanel(
      title: invoice ? 'Invoice' : 'Sale order',
      subtitle: invoice ? 'Invoicing metrics' : 'Tracking of sales orders',
      icon: invoice ? Icons.request_quote_rounded : Icons.shopping_cart_rounded,
      accent: accent,
      onOpen: () => onOpenTab(invoice ? OverviewTabLinks.invoice : OverviewTabLinks.salesOrders),
      action: widget.salesAllowed
          ? SegmentSwitch(
              options: const ['Sale Order', 'Invoice'],
              selected: _report,
              color: accent.strong,
              onChanged: (i) => setState(() => _report = i),
            )
          : null,
      child: AreaBody(
        area: area,
        onRetry: () => cubit.retry(invoice ? OverviewArea.invoices : OverviewArea.sales),
        builder: (d) => _SalesReport(data: d, isTablet: isTablet, accent: accent),
      ),
    );
  }

  List<Widget> _sections(BuildContext context, AdminOverviewState s, AdminOverviewCubit cubit) {
    final trucks = _entry('Truck Location');
    final mail = s.mail.data?.summary;
    final ir = s.incidents.data;
    final t = s.truckLocation.data;
    final truckTotal = t == null ? 0 : t.filled + t.notFilled + t.workshop;
    return [
      AccentPanel(
        title: 'Mailbox monitor',
        subtitle: mail == null
            ? 'Unread mail by mailbox'
            : '${_n(mail.withUnread)} of ${_n(mail.mailboxes)} mailboxes with unread',
        icon: Icons.mark_email_unread_rounded,
        accent: PanelAccent.teal,
        onOpen: () => onOpenTab(OverviewTabLinks.mailboxMonitor),
        child: AreaBody(
          area: s.mail,
          onRetry: () => cubit.retry(OverviewArea.mail),
          builder: (m) {
            final rows =
                attentionFirst(m.mailboxes).where((r) => (r.unread ?? 0) > 0 || r.status != 'OK').take(3).toList();
            if (rows.isEmpty) return const _Quiet('No unread mail');
            return Column(children: [
              for (var i = 0; i < rows.length; i++)
                LeadRow(
                  lead: LetterAvatar(
                      text: rows[i].displayName.isEmpty ? rows[i].address : rows[i].displayName,
                      accent: PanelAccent.teal),
                  title: rows[i].displayName.isEmpty ? rows[i].address : rows[i].displayName,
                  subtitle: '${_n(rows[i].unread ?? 0)} unread',
                  trailing: StatusPill(lookOf(rows[i]).label, tone: lookOf(rows[i]).tone),
                  last: i == rows.length - 1,
                ),
            ]);
          },
        ),
      ),
      AccentPanel(
        title: 'Incident reports',
        subtitle:
            ir == null ? 'Open in the last 30 days' : '${_n(ir.open)} open · last 30 days · ${Fmt.rm(ir.totalAmount)}',
        icon: Icons.report_rounded,
        accent: PanelAccent.rose,
        onOpen: () => onOpenTab(OverviewTabLinks.irReport),
        child: AreaBody(
          area: s.incidents,
          onRetry: () => cubit.retry(OverviewArea.incidents),
          builder: (ir) {
            if (ir.latest.isEmpty) return const _Quiet('No open incident in the last 30 days');
            return Column(children: [
              for (var i = 0; i < ir.latest.length; i++)
                LeadRow(
                  lead: DateBlock(
                    day: DateFormat('dd').format(ir.latest[i].irDate),
                    month: DateFormat('MMM').format(ir.latest[i].irDate),
                    accent: PanelAccent.rose,
                  ),
                  title: _irSubject(ir.latest[i].truckNo, ir.latest[i].vesselName, ir.latest[i].description),
                  subtitle: ir.latest[i].description,
                  trailing: StatusPill(ir.latest[i].statusName ?? 'Open', tone: StatusTone.warning),
                  last: i == ir.latest.length - 1,
                ),
            ]);
          },
        ),
      ),
      AccentPanel(
        title: 'Truck location',
        subtitle: t == null || truckTotal == 0
            ? 'This week · today'
            : 'This week · ${(t.filled * 100 / truckTotal).round()}% filled today',
        icon: Icons.location_on_rounded,
        accent: PanelAccent.green,
        onOpen: trucks == null ? null : () => _openTrucks(context),
        child: AreaBody(
          area: s.truckLocation,
          onRetry: () => cubit.retry(OverviewArea.truckLocation),
          builder: (t) => StackedBar(parts: [
            BarPart(label: 'Filled today', count: t.filled, color: AppTokens.statusSuccess),
            BarPart(label: 'Not filled', count: t.notFilled, color: AppTokens.statusWarning),
            BarPart(label: 'In workshop', count: t.workshop, color: Palette.rose),
          ]),
        ),
      ),
    ];
  }

  static String _irSubject(String? truck, String? vessel, String description) {
    for (final v in [truck, vessel, description]) {
      if (v != null && v.trim().isNotEmpty) return v.trim();
    }
    return 'Incident';
  }
}

/// A small heading between the blocks: an icon and the name in capitals.
class _Heading extends StatelessWidget {
  const _Heading({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Row(children: [
        Icon(icon, size: 15, color: AppTokens.brandPrimary),
        const SizedBox(width: 6),
        Text(text.toUpperCase(),
            style: AppTypography.badgeText(color: AppTokens.textMuted, fontWeight: FontWeight.w800)
                .copyWith(letterSpacing: 1.2)),
        const SizedBox(width: 10),
        const Expanded(child: Divider(height: 1, color: AppTokens.surfaceBorder)),
      ]);
}

/// The report card body: four period tiles, the months as a chart, and the year's best, average and total.
class _SalesReport extends StatelessWidget {
  const _SalesReport({required this.data, required this.isTablet, required this.accent});

  final SalesSummary data;
  final bool isTablet;
  final PanelAccent accent;

  @override
  Widget build(BuildContext context) {
    final d = data;
    final tiles = [
      PeriodTile(
          label: 'Today',
          icon: Icons.today_rounded,
          color: Palette.blueMid,
          count: _n(d.today),
          amount: Fmt.rm(d.todayAmount)),
      PeriodTile(
          label: 'Yesterday',
          icon: Icons.history_rounded,
          color: Palette.grey700,
          count: _n(d.yesterday),
          amount: Fmt.rm(d.yesterdayAmount)),
      PeriodTile(
          label: 'This week',
          icon: Icons.trending_up_rounded,
          color: Palette.amberGold,
          count: _n(d.week),
          amount: Fmt.rm(d.weekAmount)),
      PeriodTile(
          label: 'This month',
          icon: Icons.calendar_month_rounded,
          color: Palette.greenEco,
          count: _n(d.month),
          amount: Fmt.rm(d.monthAmount)),
    ];
    // The server sends the months newest first; the chart reads left to right, oldest first.
    final months = d.months.reversed.toList();
    MonthSales? best;
    for (final m in d.months) {
      if (best == null || m.amount > best.amount) best = m;
    }
    final total = d.months.fold<double>(0, (a, m) => a + m.amount);
    final jobs = d.months.fold<int>(0, (a, m) => a + m.count);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _Grid(columns: isTablet ? 4 : 2, spacing: 8, minCellHeight: 96, children: tiles),
      if (months.isNotEmpty) ...[
        const SizedBox(height: 16),
        Row(children: [
          Expanded(
            child: Text('LAST ${months.length} MONTHS',
                style: AppTypography.badgeText(color: AppTokens.textMuted, fontWeight: FontWeight.w800)
                    .copyWith(letterSpacing: 1)),
          ),
          Text('Tap a bar for details', style: AppTypography.badgeText(color: Palette.textDim)),
        ]),
        const SizedBox(height: 10),
        MonthChart(
          names: [for (final m in months) m.name],
          amounts: [for (final m in months) m.amount],
          counts: [for (final m in months) m.count],
          accent: accent,
        ),
        const SizedBox(height: 12),
        _Grid(columns: 3, spacing: 8, children: [
          MiniStat(label: 'Best month', value: best!.name, sub: Fmt.rm(best.amount), color: accent.strong),
          MiniStat(
              label: 'Avg / month',
              value: Fmt.rm(total / months.length),
              sub: '${_n((jobs / months.length).round())} jobs',
              color: AppTokens.textPrimary),
          MiniStat(label: 'Total', value: Fmt.rm(total), sub: '${_n(jobs)} jobs', color: Palette.greenEco),
        ]),
      ],
    ]);
  }
}

/// The blue header: greeting, title, date, Refresh, and the four numbers (each opens its tab).
class _Header extends StatelessWidget {
  const _Header({
    required this.state,
    required this.isTablet,
    required this.onRefresh,
    required this.onRetry,
    required this.onOpenTab,
    required this.salesAllowed,
  });

  final AdminOverviewState state;
  final bool salesAllowed;
  final bool isTablet;
  final Future<void> Function() onRefresh;
  final Future<void> Function(OverviewArea) onRetry;
  final void Function(String tabLabel) onOpenTab;

  static String _greeting(DateTime now) => now.hour < 12
      ? 'Good morning'
      : now.hour < 17
          ? 'Good afternoon'
          : 'Good evening';

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final updated = state.updatedAt == null ? 'loading…' : 'updated ${DateFormat('HH:mm').format(state.updatedAt!)}';
    final tiles = [
      if (salesAllowed)
        KpiTile(
          label: 'Sale orders today',
          icon: Icons.shopping_cart_rounded,
          onTap: () => onOpenTab(OverviewTabLinks.salesOrders),
          body: AreaBody(
            area: state.sales,
            onDark: true,
            onRetry: () => onRetry(OverviewArea.sales),
            builder: (s) => KpiValue(value: _n(s.today), sub: 'Month ${_n(s.month)} · ${Fmt.rm(s.monthAmount)}'),
          ),
        ),
      KpiTile(
        label: 'Open job orders',
        icon: Icons.build_rounded,
        onTap: () => onOpenTab(OverviewTabLinks.jobOrders),
        body: AreaBody(
          area: state.jobOrders,
          onDark: true,
          onRetry: () => onRetry(OverviewArea.jobOrders),
          builder: (j) => KpiValue(
            value: _n(j.open),
            sub: j.byStatus.entries.map((e) => '${e.key} ${e.value}').join(' · '),
          ),
        ),
      ),
      KpiTile(
        label: 'Unread mail',
        icon: Icons.mail_rounded,
        onTap: () => onOpenTab(OverviewTabLinks.mailboxMonitor),
        body: AreaBody(
          area: state.mail,
          onDark: true,
          onRetry: () => onRetry(OverviewArea.mail),
          builder: (m) => KpiValue(
            value: _n(m.summary.totalUnread),
            alert: m.summary.overdue > 0 ? '${_n(m.summary.overdue)} overdue' : null,
            sub: '${m.summary.withUnread} of ${m.summary.mailboxes} mailboxes',
          ),
        ),
      ),
      KpiTile(
        label: 'Open incidents · 30 days',
        icon: Icons.report_rounded,
        onTap: () => onOpenTab(OverviewTabLinks.irReport),
        body: AreaBody(
          area: state.incidents,
          onDark: true,
          onRetry: () => onRetry(OverviewArea.incidents),
          builder: (ir) => KpiValue(value: _n(ir.open), sub: Fmt.rm(ir.totalAmount)),
        ),
      ),
    ];

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTokens.brandGradientStart, AppTokens.brandGradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: AppTokens.brandGradientEnd.withValues(alpha: 0.3), blurRadius: 18, offset: const Offset(0, 8)),
        ],
      ),
      child: Stack(children: [
        // Soft circles for depth.
        const Positioned(right: -40, top: -50, child: _Bubble(size: 170)),
        const Positioned(left: -30, bottom: -60, child: _Bubble(size: 140)),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(_greeting(now),
                      style: AppTypography.bodySmall(
                          color: AppTokens.textOnDark.withValues(alpha: 0.8), fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Row(children: [
                    Flexible(
                      child: Text('Overview',
                          style: AppTypography.heading1(color: AppTokens.textOnDark, fontWeight: FontWeight.w800)),
                    ),
                    const SizedBox(width: 8),
                    const _LivePill(),
                  ]),
                  const SizedBox(height: 4),
                  Row(children: [
                    Icon(Icons.calendar_today_rounded, size: 12, color: AppTokens.textOnDark.withValues(alpha: 0.75)),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text('${DateFormat('EEE, d MMM yyyy').format(now)} · $updated',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodySmall(color: AppTokens.textOnDark.withValues(alpha: 0.8))),
                    ),
                  ]),
                ]),
              ),
              Material(
                color: AppTokens.textOnDark,
                borderRadius: BorderRadius.circular(999),
                child: InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: onRefresh,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.refresh_rounded, size: 16, color: AppTokens.brandGradientStart),
                      const SizedBox(width: 5),
                      Text('Refresh',
                          style: AppTypography.bodySmall(
                              color: AppTokens.brandGradientStart, fontWeight: FontWeight.w700)),
                    ]),
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 16),
            _Grid(columns: isTablet ? 4 : 2, spacing: 10, minCellHeight: isTablet ? 124 : 118, children: tiles),
          ]),
        ),
      ]),
    );
  }
}

/// A faint white circle on the header.
class _Bubble extends StatelessWidget {
  const _Bubble({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: AppTokens.textOnDark.withValues(alpha: 0.07)),
      );
}

/// Phone: one column. Tablet: two columns, the last card full width when the count is odd.
class _Sections extends StatelessWidget {
  const _Sections({required this.isTablet, required this.children});

  final bool isTablet;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (!isTablet) {
      return Column(children: [
        for (final c in children) Padding(padding: const EdgeInsets.only(bottom: 10), child: c),
      ]);
    }
    return _Grid(columns: 2, spacing: 10, stretchLastOdd: true, children: children);
  }
}

/// Rows of [columns] equal cells; a short last row keeps the cell width.
class _Grid extends StatelessWidget {
  const _Grid({
    required this.columns,
    required this.spacing,
    required this.children,
    this.stretchLastOdd = false,
    this.minCellHeight,
  });

  final int columns;
  final double spacing;
  final List<Widget> children;
  final bool stretchLastOdd;

  /// When set, cells are at least this tall and grow with their content, without measuring the row first.
  /// For cells whose measured height can come out a pixel short (big numbers with a pill under them).
  final double? minCellHeight;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i += columns) {
      final cells = children.sublist(i, (i + columns).clamp(0, children.length));
      final fill = stretchLastOdd && cells.length == 1;
      final minHeight = minCellHeight;
      final row = Row(
        crossAxisAlignment: minHeight == null ? CrossAxisAlignment.stretch : CrossAxisAlignment.start,
        children: [
          for (var c = 0; c < (fill ? 1 : columns); c++) ...[
            if (c > 0) SizedBox(width: spacing),
            Expanded(
              child: c >= cells.length
                  ? const SizedBox.shrink()
                  : minHeight == null
                      ? cells[c]
                      : ConstrainedBox(constraints: BoxConstraints(minHeight: minHeight), child: cells[c]),
            ),
          ],
        ],
      );
      rows.add(Padding(
        padding: EdgeInsets.only(bottom: i + columns < children.length ? spacing : 0),
        child: minHeight == null ? IntrinsicHeight(child: row) : row,
      ));
    }
    return Column(children: rows);
  }
}

class _Quiet extends StatelessWidget {
  const _Quiet(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(children: [
          const Icon(Icons.check_circle_outline, size: 16, color: AppTokens.statusSuccess),
          const SizedBox(width: 6),
          Text(text, style: AppTypography.bodySmall(color: AppTokens.textMuted)),
        ]),
      );
}

/// The web command bar's green "Live" pill.
class _LivePill extends StatelessWidget {
  const _LivePill();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppTokens.textOnDark.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(
              width: 7, height: 7, decoration: const BoxDecoration(color: Color(0xFF34D399), shape: BoxShape.circle)),
          const SizedBox(width: 5),
          Text('Live', style: AppTypography.badgeText(color: AppTokens.textOnDark, fontWeight: FontWeight.w700)),
        ]),
      );
}
