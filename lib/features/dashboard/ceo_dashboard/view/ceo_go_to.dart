import 'package:flutter/material.dart';
import 'package:maleva/core/models/shared/menu_master_model.dart';
import 'package:maleva/core/theme/app_typography.dart';
import 'package:maleva/core/theme/palette.dart';
import 'package:maleva/core/theme/tokens.dart';
import 'package:maleva/core/utils/app_globals.dart';
import 'package:maleva/core/widgets/custom_app_bar.dart';
import 'package:maleva/features/dashboard/common_tabs/vesselplanningweb/view/vesselplanningweb_tab.dart';
import 'package:maleva/features/ir_report/presentation/pages/ir_report_tab.dart';
import 'package:maleva/features/mail_monitor/report/mail_response_tab.dart';
import 'package:maleva/features/mail_monitor/view/mail_monitor_tab.dart';
import 'package:maleva/features/planning/plans/view/plans_page.dart';
import 'package:maleva/features/truck_location/presentation/truck_location_routes.dart';

/// One button of the CEO screen's quick access row (owner 2026-10-19: Truck Planning, Truck Location, Vessel Planning,
/// Incident Report and Mail Monitor, as the web Super Admin quick access).
class CeoGoTo {
  const CeoGoTo({required this.id, required this.label, required this.caption, required this.icon, required this.color,
      required this.open, this.live = false});

  final String id;
  final String label;
  final String caption;
  final IconData icon;
  final Color color;
  final bool live;
  final void Function(BuildContext context) open;
}

/// The side menu's entry for [formText] (its page rights), as the Super Admin Overview opens Vessel Planning.
MenuMasterModel? _menuEntry(String formText) {
  for (final m in [...AppGlobals.parentclass, ...AppGlobals.objMenuMaster]) {
    if (m.FormText == formText) return m;
  }
  return null;
}

/// The places, in the order the web shows them. The screens are the app's own, opened as the side menu and
/// the Super Admin Overview open them.
List<CeoGoTo> ceoGoToPlaces() => [
      CeoGoTo(
        id: 'truck_planning',
        label: 'Truck Planning',
        caption: 'Plans by day and truck',
        icon: Icons.local_shipping_rounded,
        color: Palette.amberGold,
        open: (c) => Navigator.push(c, MaterialPageRoute<void>(builder: (_) => const PlansPage())),
      ),
      CeoGoTo(
        id: 'truck_location',
        label: 'Truck Location',
        caption: 'Where every truck is now',
        icon: Icons.location_on_rounded,
        color: const Color(0xFF16A34A),
        live: true,
        open: (c) => Navigator.push(c, TruckLocationRoutes.board()),
      ),
      CeoGoTo(
        id: 'vessel_planning',
        label: 'Vessel Planning',
        caption: 'Vessels, ETA and boarding',
        icon: Icons.directions_boat_rounded,
        color: const Color(0xFF0891B2),
        open: (c) {
          final e = _menuEntry('Vessel Planning');
          Navigator.push(
            c,
            MaterialPageRoute<void>(
              builder: (_) => VesselPlanningWebTab(
                pageView: e == null || e.PageView == 1,
                pageAdd: e?.PageAdd == 1,
                pageEdit: e?.PageEdit == 1,
                pageDelete: e?.PageDelete == 1,
              ),
            ),
          );
        },
      ),
      CeoGoTo(
        id: 'incident_report',
        label: 'Incident Report',
        caption: 'IRs, damage and claims',
        icon: Icons.report_rounded,
        color: const Color(0xFFE11D48),
        open: (c) => Navigator.push(
            c, MaterialPageRoute<void>(builder: (_) => const CeoPlainPage(title: 'Incident Report', child: IrReportTab()))),
      ),
      CeoGoTo(
        id: 'mail_monitor',
        label: 'Mail Monitor',
        caption: 'Mailboxes, response report, AI summary',
        icon: Icons.mark_email_read_rounded,
        color: const Color(0xFF7C3AED),
        live: true,
        open: (c) => Navigator.push(c, MaterialPageRoute<void>(builder: (_) => const CeoMailScreen())),
      ),
    ];

/// The quick access row (web `SuperAdminQuickAccess`): one rounded button per place, always visible, a coloured
/// icon and the name, a red LIVE badge on the live ones; scrolls sideways on a narrow phone.
class CeoQuickAccess extends StatelessWidget {
  const CeoQuickAccess({super.key, this.places});

  /// For tests; the app shows [ceoGoToPlaces].
  final List<CeoGoTo>? places;

  @override
  Widget build(BuildContext context) {
    final list = places ?? ceoGoToPlaces();
    final isTablet = MediaQuery.sizeOf(context).width >= 600;
    return SizedBox(
      key: const Key('ceo_quick_access'),
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.fromLTRB(isTablet ? 20 : 12, 8, isTablet ? 20 : 12, 0),
        itemCount: list.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, i) => _QuickButton(place: list[i]),
      ),
    );
  }
}

class _QuickButton extends StatelessWidget {
  const _QuickButton({required this.place});

  final CeoGoTo place;

  @override
  Widget build(BuildContext context) => Stack(clipBehavior: Clip.none, children: [
        Material(
          color: AppTokens.surfaceCard,
          shape: const StadiumBorder(side: BorderSide(color: Palette.grey300)),
          elevation: 0.5,
          shadowColor: Colors.black26,
          child: InkWell(
            key: Key('ceo_go_${place.id}'),
            customBorder: const StadiumBorder(),
            onTap: () => place.open(context),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(place.icon, size: 15, color: place.color),
                const SizedBox(width: 6),
                Text(place.label,
                    style: AppTypography.bodySmall(color: const Color(0xFF334155), fontWeight: FontWeight.w700)),
              ]),
            ),
          ),
        ),
        if (place.live)
          Positioned(
            top: -5,
            right: -3,
            child: IgnorePointer(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: const Color(0xFFF43F5E),
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: [BoxShadow(color: const Color(0xFFF43F5E).withValues(alpha: 0.4), blurRadius: 4)],
                ),
                child: const Text('LIVE',
                    style: TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
              ),
            ),
          ),
      ]);
}

/// A screen around a tab widget: the app bar with Back, then [child].
class CeoPlainPage extends StatelessWidget {
  const CeoPlainPage({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppTokens.surfacePage,
        appBar: CustomGradientAppBar(
          title: title,
          isTablet: MediaQuery.sizeOf(context).width >= 600,
          showBackButton: true,
        ),
        body: child,
      );
}

/// Mail Monitor in one screen (owner 2026-10-19): the mailboxes (`/mail-monitor`) and the response report with its
/// AI auto summary (`/mail-monitor/response-report`), as two tabs of the same screen.
class CeoMailScreen extends StatelessWidget {
  const CeoMailScreen({super.key, this.mailboxes, this.responseReport});

  /// For tests; the app shows [MailMonitorTab] and [MailResponseTab].
  final Widget? mailboxes;
  final Widget? responseReport;

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.sizeOf(context).width >= 600;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppTokens.surfacePage,
        appBar: CustomGradientAppBar(title: 'Mail Monitor', isTablet: isTablet, showBackButton: true),
        body: Column(children: [
          Container(
            margin: EdgeInsets.fromLTRB(isTablet ? 20 : 12, 10, isTablet ? 20 : 12, 4),
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: AppTokens.surfaceCard,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: TabBar(
              key: const Key('ceo_mail_tabs'),
              dividerColor: Colors.transparent,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)]),
                borderRadius: BorderRadius.circular(25),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: const Color(0xFF1A2E5A),
              labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              tabs: const [
                Tab(height: 36, child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.inbox_rounded, size: 16), SizedBox(width: 6), Text('Mailboxes'),
                ])),
                Tab(height: 36, child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.auto_awesome_rounded, size: 16), SizedBox(width: 6), Text('Response report'),
                ])),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(children: [
              mailboxes ?? const MailMonitorTab(),
              responseReport ?? const MailResponseTab(),
            ]),
          ),
        ]),
      ),
    );
  }
}
