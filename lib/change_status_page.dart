import 'package:maleva/core/network/api_legacy_helper.dart';
import 'package:maleva/core/network/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:maleva/core/utils/app_globals.dart';
import 'package:maleva/core/utils/app_globals.dart';
import 'core/models/model.dart';
import 'package:maleva/core/models/shared/pattycash_master_model.dart';
import 'package:maleva/core/models/shared/patty_cash_details_model.dart';

class ChangeStatusPage extends StatefulWidget {
  final int masterId;

  const ChangeStatusPage({
    Key? key,
    required this.masterId,
  }) : super(key: key);

  @override
  ChangeStatusPageState createState() => ChangeStatusPageState();
}

class ChangeStatusPageState extends State<ChangeStatusPage> {

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
  List<PattycashMasterModel> pettycashMaster = [];
  List<PattyCashDetailsModel> pettycashDetails = [];

  Future loadpettycash() async {
    setState(() {
      progress = false;
    });
    Map<String, String> header = {
      'Content-Type': 'application/json; charset=UTF-8',
    };
    await ApiLegacyHelper.apiAllinoneSelectArray(
      "${ApiConstants.apiGetpettycash}${AppGlobals.Comid}""",
      null,
      header,
      context,
    ).then((resultData) async {
      if (resultData != null && resultData.isNotEmpty) {
        var data = resultData[0];
        if (data != null) {
          // Parse master data
          if (data['PattycashMasterModel'] != null) {
            pettycashMaster = (data['PattycashMasterModel'] as List)
                .map((item) => PattycashMasterModel.fromJson(item))
                .toList();
          }
          // Parse details data
          if (data['PattyCashDetailsModel'] != null) {
            pettycashDetails = (data['PattyCashDetailsModel'] as List)
                .map((item) => PattyCashDetailsModel.fromJson(item))
                .toList();
          }
        }
      }
    }).onError((error, stackTrace) {
      msgshow(
        error.toString(),
        stackTrace.toString(),
        Colors.white,
        Colors.red,
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
        title: const Text('Change Status'),
      ),
      body: Center(
        child: Text(
          "Selected ID: ${widget.masterId}",
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
