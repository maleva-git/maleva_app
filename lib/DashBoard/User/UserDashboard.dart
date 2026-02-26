
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/colors/colors.dart' as colour;
import 'package:maleva/menu/menulist.dart';
import 'package:maleva/core/models/model.dart';

part 'package:maleva/DashBoard/User/mobileUserDashboard.dart';
part 'package:maleva/DashBoard/User/tabletUserDashboard.dart';


class Homemobile extends StatefulWidget {
  const Homemobile({super.key});

  @override
  HomemobileState createState() => HomemobileState();
}

class HomemobileState extends State<Homemobile> {
  bool progress = false;
  late MenuMasterModel menuControl;

  @override
  void initState() {
    startup();
    super.initState();
  }

  Future startup() async {
    objfun.checkVersion(context);
    setState(() {
      progress = true;
    });
  }

  Future<bool> _onBackPressed() async {
    bool result = await objfun.ConfirmationMsgYesNo(
        context, "Are you Sure you want to Exit?");
    if (result == true) {
      if (Platform.isAndroid) {
        SystemNavigator.pop();
      } else if (Platform.isIOS) {
        exit(0);
      }
    } else {
      return false;
      // Navigator.of(context).pop();
    }
    return result;
  }

  late File ff;
  bool show = false;

  @override
  Widget build(BuildContext context) {
    return objfun.MalevaScreen == 1
        ? mobiledesign(this, context)
        : tabletdesign(this, context);

  }
}
