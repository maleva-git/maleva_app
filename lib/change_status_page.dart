import 'package:maleva/core/theme/app_typography.dart';
import 'package:maleva/core/colors/colors.dart' as colour;
import 'package:maleva/core/finance/petty_cash_api.dart';
import 'package:maleva/features/dashboard/common_tabs/pettycash/data/change_status_loader.dart';
import 'package:flutter/material.dart';
import 'package:maleva/core/utils/app_globals.dart';
import 'core/models/model.dart';
import 'package:maleva/core/di/injection.dart';

class ChangeStatusPage extends StatefulWidget {
  final int masterId;
  final ChangeStatusLoader? loader;

  const ChangeStatusPage({
    super.key,
    required this.masterId,
    this.loader,
  });

  @override
  ChangeStatusPageState createState() => ChangeStatusPageState();
}

class ChangeStatusPageState extends State<ChangeStatusPage> {

  late final ChangeStatusLoader _loader = widget.loader ?? ChangeStatusLoader(api: sl<PettyCashApi>());
  late int EditId;
  bool progress = false;
  @override
  void initState() {
    super.initState();
//check
    EditId = widget.masterId;
    if (EditId != 0){
      loadpettycash();
    }
  }
  List<PattycashMasterModel> get pettycashMaster => _loader.masters;
  set pettycashMaster(List<PattycashMasterModel> value) => _loader.masters = value;
  List<PattyCashDetailsModel> get pettycashDetails => _loader.details;
  set pettycashDetails(List<PattyCashDetailsModel> value) => _loader.details = value;

  Future loadpettycash() async {
    setState(() {
      progress = false;
    });
    await _loader.load(EditId).onError((error, stackTrace) {
      msgshow(
        error.toString(),
        stackTrace.toString(),
        Colors.white,
        colour.commonColorred,
        null,
        18.00 - AppGlobals.reducesize,
        AppGlobals.tll,
        AppGlobals.tgc,
        context,
        2,
      );
    });

    setState(() {
      progress = true;
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Change Status'),
      ),
      body: Center(
        child: Text(
          "Selected ID: ${widget.masterId}",
          style: AppTypography.heading1(),
        ),
      ),
    );
  }
}
