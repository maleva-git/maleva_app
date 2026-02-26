import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/colors/colors.dart' as colour;
import 'package:maleva/menu/menulist.dart';
part 'package:maleva/Transaction/Planning/mobilePlanningDetails.dart';
part 'package:maleva/Transaction/Planning/tabletPlanningDetails.dart';

class PlanningDetailsView extends StatefulWidget {
  const PlanningDetailsView({super.key});

  @override
  PlanningDetailsState createState() => PlanningDetailsState();
}

class PlanningDetailsState extends State<PlanningDetailsView> {
  bool progress = false;

  String UserName = objfun.storagenew.getString('Username') ?? "";
  TextEditingController searchController = TextEditingController();

  List originalPlanningList = [];
  List filteredPlanningList = [];
  @override
  void initState() {
    progress = true;
    super.initState();
    originalPlanningList = List.from(objfun.PlanningEditList);
    filteredPlanningList = List.from(objfun.PlanningEditList);
  }

  @override
  void dispose() {
    super.dispose();
  }


  Future<bool> _onBackPressed() async {
    Navigator.pop(context);
    return true;
  }

  void searchPlanning(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredPlanningList = List.from(originalPlanningList);
      });
      return;
    }

    final q = query.toLowerCase();

    setState(() {
      filteredPlanningList = originalPlanningList.where((item) {
        return
          (item["JobNo"] ?? "").toString().toLowerCase().contains(q) ||     // Planning No
              (item["EmployeeName"] ?? "").toString().toLowerCase().contains(q) || // PIC
              (item["SPickupDate"] ?? "").toString().toLowerCase().contains(q) ||
              (item["SDeliveryDate"] ?? "").toString().toLowerCase().contains(q) ||
              (item["Origin"] ?? "").toString().toLowerCase().contains(q) ||
              (item["Destination"] ?? "").toString().toLowerCase().contains(q) ||
              (item["Port"] ?? "").toString().toLowerCase().contains(q);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return objfun.MalevaScreen == 1
        ? mobiledesign(this, context)
        : tabletdesign(this, context);
  }


}
