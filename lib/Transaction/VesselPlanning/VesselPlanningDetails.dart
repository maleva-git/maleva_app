import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/colors/colors.dart' as colour;
import 'package:maleva/menu/menulist.dart';
part 'package:maleva/Transaction/VesselPlanning/mobileVesselPlanningDetails.dart';
part 'package:maleva/Transaction/VesselPlanning/tabletVesselPlanningDetails.dart';

class VesselPlanningDetailsView extends StatefulWidget {
  const VesselPlanningDetailsView({super.key});

  @override
  VesselPlanningDetailsState createState() => VesselPlanningDetailsState();
}

class VesselPlanningDetailsState extends State<VesselPlanningDetailsView> {
  bool progress = false;

  String UserName = objfun.storagenew.getString('Username') ?? "";

  @override
  void initState() {
    progress = true;
    super.initState();

  }

  @override
  void dispose() {
    super.dispose();
  }


  Future<bool> _onBackPressed() async {
    Navigator.pop(context);
    return true;
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
