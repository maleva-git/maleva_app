import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maleva/GoogleReview/ReviewEntryScreen.dart';
import 'package:maleva/Transport/Fuel/FuelEntry.dart';
import 'package:maleva/core/colors/colors.dart' as colour;
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/models/model.dart';
import 'package:maleva/Transaction/SaleOrder/SalesOrderView.dart';
import '../Boarding/BoardingStatusUpdate.dart';
import '../MailInbox/MailInboxView.dart';
import '../Operation/FWBreakSealUpdate.dart';
import '../Operation/FWSmkUpdate.dart';
import '../Operation/FWUpdate.dart';
import '../Operation/ForwardingSalary/ForwardingSalaryUpdate.dart';
import '../PreAlertReport/PreAlertReport.dart';
import '../SaleOrderView/SaleOrderView.dart';
import '../Transaction/AirFrieght/AirFrieght.dart';
import '../Transaction/Enquiry/EnquiryView.dart';
import '../Transaction/EnquiryTR/EnquiryTRView.dart';
import '../Transaction/GetJobNoPage.dart';
import '../Transaction/JobStatus/JobStatusUpdate.dart';
import '../Transaction/Planning/PlanningView.dart';
import '../Transaction/SpotSaleOrder/SpotSaleOrder.dart';
import '../Transaction/Stock/StockInEntry.dart';
import '../Transaction/Stock/StockTransferUpdate.dart';
import '../Transaction/Stock/StockUpdate.dart';
import '../Transaction/VesselPlanning/VesselPlanningView.dart';
import '../Transport/LicenseUpdate.dart';
import '../Transport/Maintenance.dart';
import '../Transport/RTI/UpdateRTIDetails.dart';
import '../DashBoard/User/UserDashboard.dart';
import '../DashBoard/OperationAdmin/OperationAdminDashboard.dart';

class Menulist extends StatefulWidget {
  const Menulist({super.key});

  @override
  _MenulistState createState() => _MenulistState();
}

class _MenulistState extends State<Menulist> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final Color primaryBlue = const Color(0xFF1555F3);
  final Color lightBlue = const Color(0xFFE8F0FE);
  final Color darkBlue = const Color(0xFF0D3BB0);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(-0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenheight = MediaQuery.of(context).size.height;

    return Drawer(
      elevation: 10,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              lightBlue.withOpacity(0.3),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation, // Fixed: changed from offset to position
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 7),
                  _buildVersionBadge(),
                  const Divider(
                    thickness: 1,
                    height: 20,
                    indent: 20,
                    endIndent: 20,
                    color: Color(0xFF1555F3),
                  ),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.white.withOpacity(0.7),
                      ),
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: objfun.parentclass.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Menulistnew(objfun.parentclass[index], context);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      width: objfun.MalevaScreen == 1 ? 225 : 200,
      height: objfun.MalevaScreen == 1 ? 175 : 190,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        color: Colors.white,
        image: DecorationImage(
          image: objfun.logo,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildVersionBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryBlue,
            darkBlue,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withOpacity(0.3),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        objfun.appversion,
        style: GoogleFonts.karla(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class Menulistnew extends StatelessWidget {
  const Menulistnew(this.entry, this.context, {super.key});
  final MenuMasterModel entry;
  final BuildContext context;

  final Color primaryBlue = const Color(0xFF1555F3);
  final Color lightBlue = const Color(0xFFE8F0FE);

  List<Widget> _childlsit(List<MenuMasterModel> parent) {
    List<Widget> child = [];

    for (int i = 0; i < parent.length; i++) {
      List<MenuMasterModel> subchild = [];
      subchild.addAll(objfun.objMenuMaster
          .where((element) => element.ParentId == parent[i].Id)
          .toList());

      if (subchild.isEmpty) {
        String menu = parent[i].FormText;
        child.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => _handleNavigation(parent[i]),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: primaryBlue.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: primaryBlue,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          menu,
                          style: GoogleFonts.lato(
                            fontSize: objfun.FontCardText + 2,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: primaryBlue.withOpacity(0.5),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      } else {
        String menu = parent[i].FormText;
        child.add(
          Container(
            margin: const EdgeInsets.symmetric(vertical: 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: lightBlue.withOpacity(0.3),
            ),
            child: Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.transparent,
                splashColor: primaryBlue.withOpacity(0.1),
                highlightColor: primaryBlue.withOpacity(0.05),
              ),
              child: ExpansionTile(
                key: PageStorageKey<MenuMasterModel>(parent[i]), // Fixed: removed value parameter, using parent[i] as key value
                leading: Icon(
                  Icons.folder,
                  color: primaryBlue,
                  size: 20,
                ),
                title: Text(
                  menu,
                  style: GoogleFonts.lato(
                    fontSize: objfun.FontLow,
                    fontWeight: FontWeight.w600,
                    color: primaryBlue,
                  ),
                ),
                iconColor: primaryBlue,
                collapsedIconColor: primaryBlue,
                children: _childlsit(subchild),
                tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                childrenPadding: const EdgeInsets.only(left: 16),
              ),
            ),
          ),
        );
      }
    }
    return child;
  }

  Widget _buildTiles(MenuMasterModel parent) {
    List<MenuMasterModel> subchild = [];
    subchild.addAll(objfun.objMenuMaster
        .where((element) => element.ParentId == parent.Id)
        .toList());

    if (subchild.isEmpty) {
      String menu = parent.FormText;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => _handleNavigation(parent),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: primaryBlue.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: primaryBlue,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      menu,
                      style: GoogleFonts.lato(
                        fontSize: objfun.FontLow,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: primaryBlue.withOpacity(0.5),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      String menu = parent.FormText;
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: lightBlue.withOpacity(0.3),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(
            dividerColor: Colors.transparent,
            splashColor: primaryBlue.withOpacity(0.1),
            highlightColor: primaryBlue.withOpacity(0.05),
          ),
          child: ExpansionTile(
            key: PageStorageKey<MenuMasterModel>(parent), // Fixed: removed value parameter
            leading: Icon(
              Icons.folder,
              color: primaryBlue,
              size: 20,
            ),
            title: Text(
              menu,
              style: GoogleFonts.lato(
                fontSize: objfun.FontLow,
                fontWeight: FontWeight.w600,
                color: primaryBlue,
              ),
            ),
            iconColor: primaryBlue,
            collapsedIconColor: primaryBlue,
            children: _childlsit(subchild),
            tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            childrenPadding: const EdgeInsets.only(left: 16),
          ),
        ),
      );
    }
  }

  void _handleNavigation(MenuMasterModel menuItem) {
    Navigator.pop(context); // Close drawer

    // Add a slight delay for better UX
    Future.delayed(const Duration(milliseconds: 100), () {
      switch (menuItem.FormText) {
        case "Sales Order":
          Navigator.push(context, MaterialPageRoute(builder: (context) => const SaleOrderView()));
          break;
        case "Planning":
          Navigator.push(context, MaterialPageRoute(builder: (context) => const PlanningView()));
          break;
        case "SpotSaleOrder":
          Navigator.push(context, MaterialPageRoute(builder: (context) => const Spotsaleorder()));
          break;
        case "PreAlertReport":
          Navigator.push(context, MaterialPageRoute(builder: (context) => const PreAlertreport()));
          break;
        case "Email InBox":
          Navigator.push(context, MaterialPageRoute(builder: (context) => const EmailScreen()));
          break;
        case "Google Review":
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ReviewEntryScreen()));
          break;
        case "Update Air Frieght":
          Navigator.push(context, MaterialPageRoute(builder: (context) => const AirFrieghtUpdate()));
          break;
        case "JobStatus Update":
          Navigator.push(context, MaterialPageRoute(builder: (context) => const JobStatusUpdate()));
          break;
        case "Forwarding Update":
          Navigator.push(context, MaterialPageRoute(builder: (context) => const FWUpdate()));
          break;
        case "Forwarding Exit Update":
          Navigator.push(context, MaterialPageRoute(builder: (context) => const FWUpdateBreakSeal()));
          break;
        case "View Sale Order":
          Navigator.push(context, MaterialPageRoute(builder: (context) => const GetJobNoPage()));
          break;
        case "Forwarding Salary":
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ForwardingSalaryUpdate()));
          break;
        case "Stock In Entry":
          Navigator.push(context, MaterialPageRoute(builder: (context) => const Stockinentry()));
          break;
        case "Stock Update":
          Navigator.push(context, MaterialPageRoute(builder: (context) => const StockUpdate()));
          break;
        case "Stock Transfer":
          Navigator.push(context, MaterialPageRoute(builder: (context) => const StockTransferUpdate()));
          break;
        case "Enquiry Master":
          Navigator.push(context, MaterialPageRoute(builder: (context) => const EnquiryView()));
          break;
        case "EnquiryTR Master":
          Navigator.push(context, MaterialPageRoute(builder: (context) => const EnquiryTRView()));
          break;
        case "Update Boarding Details":
          Navigator.push(context, MaterialPageRoute(builder: (context) => const BoardingStatusUpdate()));
          break;
        case "Maintenance":
          Navigator.push(context, MaterialPageRoute(builder: (context) => const Maintenance()));
          break;
        case "View":
          Navigator.push(context, MaterialPageRoute(builder: (context) => const SaleOrderView()));
          break;
        case "License Update":
          Navigator.push(context, MaterialPageRoute(builder: (context) => const LicenseUpdate()));
          break;
        case "Update RTI Details":
          Navigator.push(context, MaterialPageRoute(builder: (context) => const UpdateRTI()));
          break;
        case "Forwarding SMK Update":
          Navigator.push(context, MaterialPageRoute(builder: (context) => const FWSmkUpdate()));
          break;
        case "Fuel Entry":
          Navigator.push(context, MaterialPageRoute(builder: (context) => const FuelEntry()));
          break;
        case "Vessel Planning":
          Navigator.push(context, MaterialPageRoute(builder: (context) => const VesselPlanningView()));
          break;
        case "Logout":
          objfun.logout(context);
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _buildTiles(entry);
  }
}