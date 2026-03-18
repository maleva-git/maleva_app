import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maleva/GoogleReview/ReviewEntryScreen.dart';
import 'package:maleva/Transport/Fuel/FuelEntry.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/models/model.dart';
import '../Boarding/BoardingStatusUpdate.dart';
import '../MailInbox/MailInboxView.dart';
import '../Operation/FWBreakSealUpdate.dart';
import '../Operation/FWSmkUpdate.dart';
import '../Operation/FWUpdate.dart';
import '../Operation/ForwardingSalary/ForwardingSalaryUpdate.dart';
import '../PreAlertReport/PreAlertReport.dart';
import '../Transaction/AirFrieght/AirFrieght.dart';
import '../Transaction/Enquiry/EnquiryView.dart';
import '../Transaction/EnquiryTR/EnquiryTRView.dart';
import '../Transaction/GetJobNoPage.dart';
import '../Transaction/JobStatus/JobStatusUpdate.dart';
import '../Transaction/Planning/PlanningView.dart';
import '../Transaction/SaleOrder/SalesOrderView.dart';
import '../Transaction/SpotSaleOrder/SpotSaleOrder.dart';
import '../Transaction/Stock/StockInEntry.dart';
import '../Transaction/Stock/StockTransferUpdate.dart';
import '../Transaction/Stock/StockUpdate.dart';
import '../Transaction/VesselPlanning/VesselPlanningView.dart';
import '../Transport/LicenseUpdate.dart';
import '../Transport/Maintenance.dart';
import '../Transport/RTI/UpdateRTIDetails.dart';
import 'package:maleva/core/colors/colors.dart' as colour;
import '../features/transaction/salesorder/view/view/salesorderview_tab.dart';


// ─────────────────────────────────────────────────────────────────────────────

class Menulist extends StatefulWidget {
  const Menulist({super.key});
  @override
  State<Menulist> createState() => _MenulistState();
}

class _MenulistState extends State<Menulist>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double>   _fade;
  late final Animation<Offset>   _slide;
  final TextEditingController    _search = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(-0.12, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
    _search.addListener(
            () => setState(() => _query = _search.text.toLowerCase()));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _search.dispose();
    super.dispose();
  }

  List<MenuMasterModel> get _rootItems => objfun.parentclass.where((e) {
    if (_query.isEmpty) return true;
    return e.FormText.toLowerCase().contains(_query) ||
        objfun.objMenuMaster
            .where((c) => c.ParentId == e.Id)
            .any((c) => c.FormText.toLowerCase().contains(_query));
  }).toList();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 0,
      backgroundColor: colour.cWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        child: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                _buildSearchBar(),
                Expanded(child: _buildMenuList()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Premium header card ────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 14),
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [colour.cBlueDark, colour.cBlue, colour.cBlueLight],
            stops: [0.0, 0.55, 1.0],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: colour.cBlue.withOpacity(0.30),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: colour.cBlue.withOpacity(0.12),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: -22, right: -22,
              child: Container(
                width: 90, height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.06),
                ),
              ),
            ),
            Positioned(
              bottom: -18, left: 10,
              child: Container(
                width: 60, height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.04),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.22), width: 1),
                        image: DecorationImage(
                            image: objfun.logo, fit: BoxFit.contain),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Maleva',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 19,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'LOGISTICS SUITE',
                            style: GoogleFonts.dmSans(
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withOpacity(0.55),
                              letterSpacing: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.20)),
                      ),
                      child: Text(
                        objfun.appversion,
                        style: GoogleFonts.dmSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.85),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Container(
                          width: 6, height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFF4ADE80),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Online',
                          style: GoogleFonts.dmSans(
                            fontSize: 10,
                            color: Colors.white.withOpacity(0.60),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Search bar ─────────────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          color: colour.cSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colour.cBorder, width: 1.5),
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            Icon(Icons.search_rounded, size: 18, color: colour.cSub),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _search,
                style: GoogleFonts.dmSans(
                    fontSize: 13,
                    color: colour.cText,
                    fontWeight: FontWeight.w400),
                decoration: InputDecoration(
                  hintText: 'Search menu…',
                  hintStyle: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: colour.cSub,
                      fontWeight: FontWeight.w400),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            if (_query.isNotEmpty)
              GestureDetector(
                onTap: () => _search.clear(),
                child: Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Icon(Icons.close_rounded, size: 16, color: colour.cSub),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Menu list ──────────────────────────────────────────────────────────────
  Widget _buildMenuList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 20),
      itemCount: _rootItems.length,
      itemBuilder: (ctx, i) => _MenuTile(
        entry: _rootItems[i],
        drawerContext: context,
        searchQuery: _query,
      ),
    );
  }
}

// ─── Menu tile (recursive) ────────────────────────────────────────────────────

class _MenuTile extends StatefulWidget {
  final MenuMasterModel entry;
  final BuildContext    drawerContext;
  final int            depth;
  final String         searchQuery;

  const _MenuTile({
    required this.entry,
    required this.drawerContext,
    this.depth = 0,
    this.searchQuery = '',
    Key? key,
  }) : super(key: key);

  @override
  State<_MenuTile> createState() => _MenuTileState();
}

class _MenuTileState extends State<_MenuTile>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  bool _pressed  = false;
  late final AnimationController _expandCtrl;
  late final Animation<double>   _expandAnim;

  List<MenuMasterModel> get _children => objfun.objMenuMaster
      .where((e) => e.ParentId == widget.entry.Id)
      .toList();

  bool get _hasChildren => _children.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _expandCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 220));
    _expandAnim = CurvedAnimation(
        parent: _expandCtrl, curve: Curves.easeOutCubic);

    if (widget.searchQuery.isNotEmpty && _hasChildren) {
      final hit = _children
          .any((c) => c.FormText.toLowerCase().contains(widget.searchQuery));
      if (hit) {
        _expanded = true;
        _expandCtrl.value = 1.0;
      }
    }
  }

  @override
  void dispose() {
    _expandCtrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    _expanded ? _expandCtrl.forward() : _expandCtrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasChildren) return _buildParent();
    if (widget.entry.FormText == "Logout") return _buildLogout();
    return _buildLeaf();
  }

  // ── Leaf ──────────────────────────────────────────────────────────────────
  Widget _buildLeaf() {
    final meta = _metaFor(widget.entry.FormText);
    return GestureDetector(
      onTapDown:   (_) => setState(() => _pressed = true),
      onTapUp:     (_) => setState(() => _pressed = false),
      onTapCancel: ()  => setState(() => _pressed = false),
      onTap:       ()  => _navigate(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 130),
        transform: Matrix4.translationValues(_pressed ? 2 : 0, 0, 0),
        margin: const EdgeInsets.only(bottom: 1),
        padding: EdgeInsets.symmetric(
          horizontal: widget.depth > 0 ? 8 : 10,
          vertical:   widget.depth > 0 ? 8 : 10,
        ),
        decoration: BoxDecoration(
          color: _pressed ? const Color(0xFFF0F4FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            if (widget.depth == 0) ...[
              _buildIconBox(widget.entry.FormText),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.entry.FormText,
                      style: GoogleFonts.dmSans(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                        color: colour.cText,
                      ),
                    ),
                    if (meta.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        meta,
                        style: GoogleFonts.dmSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          color: colour.cSub,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded,
                  size: 12, color: colour.cSub.withOpacity(0.6)),
            ] else ...[
              Container(
                width: 5, height: 5,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: colour.cBlue.withOpacity(0.25),
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Text(
                  widget.entry.FormText,
                  style: GoogleFonts.dmSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF505578),
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded,
                  size: 10, color: colour.cSub.withOpacity(0.4)),
            ],
          ],
        ),
      ),
    );
  }

  // ── Parent ─────────────────────────────────────────────────────────────────
  Widget _buildParent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _toggle,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: const EdgeInsets.only(bottom: 1),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: _expanded
                  ? const Color(0xFFF0F4FF)
                  : const Color(0xFFFAFBFF),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _expanded
                    ? colour.cBlue.withOpacity(0.20)
                    : const Color(0xFFEEF0F8),
              ),
            ),
            child: Row(
              children: [
                _buildIconBox(widget.entry.FormText),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.entry.FormText,
                    style: GoogleFonts.dmSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: colour.cBlue,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: _expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 220),
                  child: const Icon(Icons.keyboard_arrow_down_rounded,
                      size: 20, color: colour.cBlue),
                ),
              ],
            ),
          ),
        ),
        SizeTransition(
          sizeFactor: _expandAnim,
          child: Container(
            margin: const EdgeInsets.only(left: 18, bottom: 4),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                    color: colour.cBlue.withOpacity(0.15), width: 2),
              ),
            ),
            child: Column(
              children: _children
                  .map((c) => _MenuTile(
                entry: c,
                drawerContext: widget.drawerContext,
                depth: widget.depth + 1,
                searchQuery: widget.searchQuery,
              ))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  // ── Logout ─────────────────────────────────────────────────────────────────
  Widget _buildLogout() {
    return GestureDetector(
      onTap: _navigate,
      child: Container(
        margin: const EdgeInsets.only(top: 10, bottom: 1),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF5F6),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFFFE4E7)),
        ),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1F2),
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Icon(Icons.logout_rounded, size: 18, color: colour.cRose),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Logout',
                style: GoogleFonts.dmSans(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: colour.cRose,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 12, color: colour.cRose.withOpacity(0.35)),
          ],
        ),
      ),
    );
  }

  // ── Icon box ───────────────────────────────────────────────────────────────
  Widget _buildIconBox(String name) {
    final accent  = _accentFor(name);
    final bgColor = colour.accentBg[accent]!;
    final fgColor = colour.accentFg[accent]!;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(_iconFor(name), size: 18, color: fgColor),
        ),
        Positioned(
          top: 4, right: 4,
          child: Container(
            width: 6, height: 6,
            decoration: BoxDecoration(
              color: fgColor,
              shape: BoxShape.circle,
              border: Border.all(color: colour.cWhite, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  // ── Navigation ─────────────────────────────────────────────────────────────
  void _navigate() {
    Navigator.pop(widget.drawerContext);
    Future.delayed(const Duration(milliseconds: 80), () {
      final ctx = widget.drawerContext;
      switch (widget.entry.FormText) {
        case "Sales Order":
          Navigator.push(ctx, _r(const SaleOrderView()));       break;
        case "Planning":
          Navigator.push(ctx, _r(const PlanningView()));        break;
        case "SpotSaleOrder":
          Navigator.push(ctx, _r(const Spotsaleorder()));       break;
        case "PreAlertReport":
          Navigator.push(ctx, _r(const PreAlertreport()));      break;
        case "Email InBox":
          Navigator.push(ctx, _r(const EmailScreen()));         break;
        case "Google Review":
          Navigator.push(ctx, _r(const ReviewEntryScreen()));   break;
        case "Update Air Frieght":
          Navigator.push(ctx, _r(const AirFrieghtUpdate()));    break;
        case "JobStatus Update":
          Navigator.push(ctx, _r(const JobStatusUpdate()));     break;
        case "Forwarding Update":
          Navigator.push(ctx, _r(const FWUpdate()));            break;
        case "Forwarding Exit Update":
          Navigator.push(ctx, _r(const FWUpdateBreakSeal()));   break;
        case "View Sale Order":
          Navigator.push(ctx, _r(const GetJobNoPage()));        break;
        case "Forwarding Salary":
          Navigator.push(ctx, _r(const ForwardingSalaryUpdate())); break;
        case "Stock In Entry":
          Navigator.push(ctx, _r(const Stockinentry()));        break;
        case "Stock Update":
          Navigator.push(ctx, _r(const StockUpdate()));         break;
        case "Stock Transfer":
          Navigator.push(ctx, _r(const StockTransferUpdate())); break;
        case "Enquiry Master":
          Navigator.push(ctx, _r(const EnquiryView()));         break;
        case "EnquiryTR Master":
          Navigator.push(ctx, _r(const EnquiryTRView()));       break;
        case "Update Boarding Details":
          Navigator.push(ctx, _r(const BoardingStatusUpdate())); break;
        case "Maintenance":
          Navigator.push(ctx, _r(const Maintenance()));         break;
        // case "View":
        //   Navigator.push(ctx, _r(const SaleOrderView()));       break;
        case "License Update":
          Navigator.push(ctx, _r(const LicenseUpdate()));       break;
        case "Update RTI Details":
          Navigator.push(ctx, _r(const UpdateRTI()));           break;
        case "Forwarding SMK Update":
          Navigator.push(ctx, _r(const FWSmkUpdate()));         break;
        case "Fuel Entry":
          Navigator.push(ctx, _r(const FuelEntry()));           break;
        case "Vessel Planning":
          Navigator.push(ctx, _r(const VesselPlanningView()));  break;
        case "Logout":
          objfun.logout(ctx);                                   break;
      }
    });
  }

  PageRouteBuilder _r(Widget page) => PageRouteBuilder(
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, anim, __, child) => FadeTransition(
      opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
      child: child,
    ),
    transitionDuration: const Duration(milliseconds: 220),
  );

  // ── Helpers ────────────────────────────────────────────────────────────────
  IconData _iconFor(String name) {
    switch (name) {
      case "Sales Order":
      case "View Sale Order":
      case "SpotSaleOrder":
      case "View":              return Icons.receipt_long_rounded;
      case "Planning":
      case "Vessel Planning":   return Icons.calendar_month_rounded;
      case "Email InBox":       return Icons.mail_outline_rounded;
      case "Google Review":     return Icons.star_outline_rounded;
      case "Update Air Frieght": return Icons.flight_rounded;
      case "JobStatus Update":  return Icons.track_changes_rounded;
      case "Forwarding Update":
      case "Forwarding Exit Update":
      case "Forwarding SMK Update":
      case "Forwarding Salary": return Icons.local_shipping_outlined;
      case "Stock In Entry":
      case "Stock Update":
      case "Stock Transfer":    return Icons.inventory_2_outlined;
      case "Enquiry Master":
      case "EnquiryTR Master":  return Icons.manage_search_rounded;
      case "Update Boarding Details": return Icons.airline_seat_recline_normal_rounded;
      case "Maintenance":       return Icons.build_outlined;
      case "License Update":    return Icons.badge_outlined;
      case "Update RTI Details": return Icons.description_outlined;
      case "Fuel Entry":        return Icons.local_gas_station_outlined;
      case "PreAlertReport":    return Icons.notifications_outlined;
      case "Logout":            return Icons.logout_rounded;
      default:                  return Icons.folder_outlined;
    }
  }

  colour.Accent _accentFor(String name) {
    switch (name) {
      case "Sales Order":
      case "View Sale Order":
      case "SpotSaleOrder":
      case "View":
      case "Email InBox":
      case "JobStatus Update":
      case "Enquiry Master":
      case "EnquiryTR Master": return colour.Accent.blue;
      case "Planning":
      case "Vessel Planning":
      case "PreAlertReport":
      case "Google Review":
      case "Update Boarding Details": return colour.Accent.green;
      case "Update Air Frieght":
      case "Fuel Entry":
      case "Maintenance":
      case "License Update":   return colour.Accent.amber;
      case "Forwarding Update":
      case "Forwarding Exit Update":
      case "Forwarding SMK Update":
      case "Forwarding Salary": return colour.Accent.purple;
      case "Stock In Entry":
      case "Stock Update":
      case "Stock Transfer":   return colour.Accent.teal;
      case "Logout":           return colour.Accent.rose;
      default:                 return colour.Accent.blue;
    }
  }

  String _metaFor(String name) {
    switch (name) {
      case "Sales Order":         return "View & manage orders";
      case "Planning":            return "Schedule & track";
      case "SpotSaleOrder":       return "Quick spot orders";
      case "Vessel Planning":     return "Sea freight planning";
      case "Update Air Frieght":  return "Update shipments";
      case "JobStatus Update":    return "Live job tracking";
      case "Email InBox":         return "Messages & alerts";
      case "Google Review":       return "Manage ratings";
      case "Forwarding Update":   return "Update FW records";
      case "PreAlertReport":      return "Pre-alert status";
      case "Enquiry Master":      return "Customer enquiries";
      case "Update Boarding Details": return "Boarding status";
      case "Fuel Entry":          return "Log fuel usage";
      case "Maintenance":         return "Vehicle upkeep";
      case "License Update":      return "Driver licenses";
      default:                    return '';
    }
  }
}