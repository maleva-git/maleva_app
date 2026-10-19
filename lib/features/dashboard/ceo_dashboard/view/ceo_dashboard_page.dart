import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:maleva/core/di/injection.dart';
import 'package:maleva/core/theme/app_typography.dart';
import 'package:maleva/core/theme/tokens.dart';
import 'package:maleva/core/utils/auth_helper.dart';
import 'package:maleva/core/widgets/custom_app_bar.dart';
import 'package:maleva/features/notifications/notification_bell.dart';

import 'package:maleva/core/bluetooth/view/Bluetooth_tab.dart';
import 'package:maleva/core/utils/printer_helper.dart';
import 'package:maleva/core/models/shared/barcode_print_model.dart';
import 'package:maleva/features/dashboard/common_tabs/saleorderview/view/saleorderview_tab.dart';
import 'package:maleva/menu/menulist.dart';

import '../bloc/ceo_dashboard_cubit.dart';
import 'package:maleva/core/session/app_session.dart';

import '../data/ceo_analytics_api.dart';
import '../data/ceo_super_reports_api.dart';
import 'ceo_doc_tab.dart';
import 'ceo_go_to.dart';
import 'ceo_received_tab.dart';
import 'ceo_report_tabs.dart';
import 'ceo_super_reports_tabs.dart';
import 'ceo_sections.dart';
import 'ceo_widgets.dart';

/// One tab of the CEO screen: CEO reports first, then the Super Admin reports.
typedef CeoTab = ({String label, IconData? icon, Widget page, bool ceo});

/// The CEO analytics dashboard (`/dashboard/ceo`, role 100 with permission 1; change
/// `ceo-analytics-dashboard`). Tabs as the web CEO page: Sale Orders, Invoices, Expenses, Cash and Money Received
/// (the list behind each number on a tap), then the Super Admin reports Forwarding, Performance and Driver Salary,
/// with the side menu. No today pickups or vessel planning (owner 2026-10-19). "All reports" finds any tab by name;
/// a row of quick access buttons (as the web) opens Truck Planning, Truck Location, Vessel Planning, Incident Report
/// and Mail Monitor.
/// The app bar keeps the bell, the ship button and logout; More opens the admin dashboard, Bluetooth and a test
/// print.
class CeoDashboardPage extends StatefulWidget {
  const CeoDashboardPage({
    super.key,
    this.api,
    this.reportsApi,
    this.companyId,
    this.clock,
    this.onOpenAdmin,
    this.showAdminTabs = true,
  });

  /// For tests; the app takes them from the service locator and the session.
  final CeoAnalyticsApi? api;
  final CeoSuperReportsApi? reportsApi;
  final int? companyId;
  final DateTime Function()? clock;

  /// Opens the admin dashboard; default pushes `/dashboard/admin` so Back returns here.
  final void Function(BuildContext context)? onOpenAdmin;

  /// The side menu and the ship button (tests leave them out).
  final bool showAdminTabs;

  static void _openAdmin(BuildContext context) => GoRouter.of(context).push('/dashboard/admin');

  @override
  State<CeoDashboardPage> createState() => _CeoDashboardPageState();
}

class _CeoDashboardPageState extends State<CeoDashboardPage> with SingleTickerProviderStateMixin {
  late final List<CeoTab> _tabs = _buildTabs();
  late final TabController _controller = TabController(length: _tabs.length, vsync: this);
  late final CeoDashboardCubit _cubit =
      CeoDashboardCubit(widget.api ?? sl<CeoAnalyticsApi>(), clock: widget.clock)..load();

  late final CeoSuperReportsApi _reports = widget.reportsApi ?? sl<CeoSuperReportsApi>();
  late final int _companyId = widget.companyId ?? const PreferencesAppSession().companyId;

  /// The web CEO page's tabs: the CEO reports, then the Super Admin reports it keeps (owner 2026-10-19: no
  /// Overview, no other admin tabs, no today pickups or vessel planning).
  List<CeoTab> _buildTabs() => [
        (label: 'Sale Orders', icon: Icons.receipt_long_rounded, page: const CeoDocTab(source: CeoDocSource.saleOrders), ceo: true),
        (label: 'Invoices', icon: Icons.request_quote_rounded, page: const CeoDocTab(source: CeoDocSource.invoices), ceo: true),
        (label: 'Expenses', icon: Icons.shopping_bag_rounded, page: const CeoExpensesTab(), ceo: true),
        (label: 'Cash', icon: Icons.account_balance_rounded, page: const CeoCashTab(), ceo: true),
        (label: 'Money Received', icon: Icons.savings_rounded, page: const CeoReceivedTab(), ceo: true),
        (
          label: 'Forwarding',
          icon: Icons.assignment_turned_in_rounded,
          page: CeoForwardingTab(api: _reports, companyId: _companyId),
          ceo: false,
        ),
        (
          label: 'Performance',
          icon: Icons.leaderboard_rounded,
          page: CeoPerformanceTab(api: _reports, companyId: _companyId),
          ceo: false,
        ),
        (
          label: 'Driver Salary',
          icon: Icons.badge_rounded,
          page: CeoDriverSalaryTab(api: _reports, companyId: _companyId),
          ceo: false,
        ),
      ];

  void _openTab(int index) {
    if (index >= 0 && index < _tabs.length) _controller.animateTo(index);
  }

  @override
  void dispose() {
    _controller.dispose();
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.sizeOf(context).width >= 600;
    final openAdmin = widget.onOpenAdmin ?? CeoDashboardPage._openAdmin;
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
          backgroundColor: AppTokens.surfacePage,
          drawer: widget.showAdminTabs ? const Menulist() : null,
          appBar: CustomGradientAppBar(
            title: 'CEO',
            isTablet: isTablet,
            actions: [
              IconButton(
                key: const Key('ceo_all_reports'),
                tooltip: 'All reports',
                icon: Icon(Icons.apps_rounded, size: isTablet ? 28 : 25),
                onPressed: () => _showAllReports(context),
              ),
              NotificationBellButton(isTablet: isTablet),
              if (widget.showAdminTabs)
                IconButton(
                  tooltip: 'Sale order view',
                  icon: Icon(Icons.directions_boat_filled, size: isTablet ? 28 : 25),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const Saleorderview())),
                ),
              Builder(
                builder: (context) => PopupMenuButton<String>(
                  key: const Key('ceo_more'),
                  tooltip: 'More',
                  icon: Icon(Icons.more_vert_rounded, size: isTablet ? 28 : 25),
                  onSelected: (v) async {
                    switch (v) {
                      case 'admin':
                        openAdmin(context);
                      case 'bluetooth':
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const BluetoothPage()));
                      case 'print':
                        await printdata([
                          BarcodePrintModel(
                              'MALEVA', 'SHIPNAME', 'SHIPNAME', 'B0005000', '2025-05-04', 'WESTPORT', 'WESTPORT', '(1/3)')
                        ]);
                      case 'logout':
                        if (context.mounted) AuthHelper.logout(context);
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      key: Key('ceo_open_admin'),
                      value: 'admin',
                      child: ListTile(
                          dense: true, leading: Icon(Icons.space_dashboard_rounded), title: Text('Admin dashboard')),
                    ),
                    PopupMenuItem(
                      value: 'bluetooth',
                      child: ListTile(dense: true, leading: Icon(Icons.bluetooth_audio), title: Text('Bluetooth printer')),
                    ),
                    PopupMenuItem(
                      value: 'print',
                      child: ListTile(dense: true, leading: Icon(Icons.print), title: Text('Test print')),
                    ),
                    PopupMenuDivider(),
                    PopupMenuItem(
                      value: 'logout',
                      child: ListTile(dense: true, leading: Icon(Icons.exit_to_app), title: Text('Log out')),
                    ),
                  ],
                ),
              ),
              if (isTablet) const SizedBox(width: 8),
            ],
          ),
          body: BlocBuilder<CeoDashboardCubit, CeoDashboardState>(
            buildWhen: (a, b) => a.forbidden != b.forbidden,
            builder: (context, st) => st.forbidden
                ? CeoOnlyNotice(onOpenAdmin: () => openAdmin(context))
                : Column(children: [
                    if (widget.showAdminTabs) const CeoQuickAccess(),
                    _CeoTabBar(controller: _controller, tabs: _tabs, isTablet: isTablet),
                    Expanded(
                      child: TabBarView(
                        controller: _controller,
                        children: [for (final t in _tabs) t.page],
                      ),
                    ),
                  ]),
          ),
        ),
    );
  }

  void _showAllReports(BuildContext context) => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Colors.transparent,
        builder: (_) => CeoAllReportsSheet(
          tabs: _tabs,
          current: _controller.index,
          onOpen: (i) {
            Navigator.of(context).pop();
            _openTab(i);
          },
        ),
      );
}

/// The tab strip: CEO reports, a small divider, then the Super Admin reports.
class _CeoTabBar extends StatelessWidget {
  const _CeoTabBar({required this.controller, required this.tabs, required this.isTablet});

  final TabController controller;
  final List<CeoTab> tabs;
  final bool isTablet;

  @override
  Widget build(BuildContext context) => Container(
        margin: EdgeInsets.fromLTRB(isTablet ? 20 : 12, isTablet ? 12 : 10, isTablet ? 20 : 12, 2),
        padding: EdgeInsets.all(isTablet ? 7 : 5),
        decoration: BoxDecoration(
          color: AppTokens.surfaceCard,
          borderRadius: BorderRadius.circular(isTablet ? 36 : 30),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: TabBar(
          key: const Key('ceo_tab_bar'),
          controller: controller,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          dividerColor: Colors.transparent,
          indicator: BoxDecoration(
            gradient: const LinearGradient(colors: [AppTokens.brandGradientStart, AppTokens.brandGradientEnd]),
            borderRadius: BorderRadius.circular(isTablet ? 28 : 25),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: Colors.white,
          unselectedLabelColor: const Color(0xFF1A2E5A),
          labelPadding: const EdgeInsets.symmetric(horizontal: 12),
          labelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: isTablet ? 14 : 13),
          unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: isTablet ? 14 : 13),
          tabs: [
            for (var i = 0; i < tabs.length; i++)
              Tab(
                height: isTablet ? 42 : 36,
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  // the first Super Admin tab starts the second group
                  if (!tabs[i].ceo && i > 0 && tabs[i - 1].ceo) ...[
                    Container(width: 1, height: 18, color: AppTokens.surfaceBorder),
                    const SizedBox(width: 10),
                  ],
                  if (tabs[i].icon != null) ...[Icon(tabs[i].icon, size: 16), const SizedBox(width: 6)],
                  Text(tabs[i].label),
                ]),
              ),
          ],
        ),
      );
}

/// Every tab of the CEO screen in a sheet: CEO reports as tiles, the Super Admin tabs as chips, and a search.
class CeoAllReportsSheet extends StatefulWidget {
  const CeoAllReportsSheet({super.key, required this.tabs, required this.current, required this.onOpen});

  final List<CeoTab> tabs;
  final int current;
  final ValueChanged<int> onOpen;

  @override
  State<CeoAllReportsSheet> createState() => _CeoAllReportsSheetState();
}

class _CeoAllReportsSheetState extends State<CeoAllReportsSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final q = _query.trim().toLowerCase();
    final shown = [
      for (var i = 0; i < widget.tabs.length; i++)
        if (q.isEmpty || widget.tabs[i].label.toLowerCase().contains(q)) i,
    ];
    final ceo = shown.where((i) => widget.tabs[i].ceo).toList();
    final admin = shown.where((i) => !widget.tabs[i].ceo).toList();
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.8,
      maxChildSize: 0.95,
      builder: (context, controller) => Container(
        decoration: const BoxDecoration(
          color: AppTokens.surfaceCard,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: ListView(controller: controller, padding: const EdgeInsets.fromLTRB(16, 10, 16, 24), children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(color: AppTokens.surfaceBorder, borderRadius: BorderRadius.circular(999)),
            ),
          ),
          Text('All reports', style: AppTypography.heading2(color: AppTokens.textPrimary, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          TextField(
            key: const Key('ceo_reports_search'),
            onChanged: (v) => setState(() => _query = v),
            decoration: InputDecoration(
              isDense: true,
              hintText: 'Find a report',
              prefixIcon: const Icon(Icons.search_rounded),
              filled: true,
              fillColor: AppTokens.surfacePage,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            ),
          ),
          if (ceo.isNotEmpty) ...[
            const SizedBox(height: 14),
            const CeoSubheading('CEO reports'),
            const SizedBox(height: 6),
            CeoGrid(columns: 3, spacing: 8, children: [
              for (final i in ceo) _tile(i),
            ]),
          ],
          if (admin.isNotEmpty) ...[
            const SizedBox(height: 14),
            CeoSubheading('Super Admin', hint: '${admin.length} tabs'),
            const SizedBox(height: 6),
            Wrap(spacing: 6, runSpacing: 6, children: [
              for (final i in admin)
                ActionChip(
                  key: Key('ceo_report_${widget.tabs[i].label}'),
                  label: Text(widget.tabs[i].label),
                  backgroundColor: i == widget.current ? AppTokens.brandGradientStart : AppTokens.surfacePage,
                  labelStyle: AppTypography.bodySmall(
                      color: i == widget.current ? Colors.white : AppTokens.textPrimary, fontWeight: FontWeight.w600),
                  side: BorderSide.none,
                  shape: const StadiumBorder(),
                  onPressed: () => widget.onOpen(i),
                ),
            ]),
          ],
          if (shown.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Text('No report called "$_query"',
                  textAlign: TextAlign.center, style: AppTypography.bodySmall(color: AppTokens.textMuted)),
            ),
        ]),
      ),
    );
  }

  Widget _tile(int i) {
    final t = widget.tabs[i];
    final on = i == widget.current;
    return Material(
      color: on ? AppTokens.brandGradientStart : AppTokens.surfacePage,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        key: Key('ceo_report_${t.label}'),
        borderRadius: BorderRadius.circular(14),
        onTap: () => widget.onOpen(i),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
          child: Column(children: [
            Icon(t.icon ?? Icons.dashboard_rounded, color: on ? Colors.white : AppTokens.brandGradientStart),
            const SizedBox(height: 6),
            Text(t.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.badgeText(color: on ? Colors.white : AppTokens.textPrimary, fontWeight: FontWeight.w700)),
          ]),
        ),
      ),
    );
  }
}

