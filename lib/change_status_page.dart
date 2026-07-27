import 'package:maleva/core/theme/app_typography.dart';
import 'package:maleva/core/colors/colors.dart' as colour;
import 'package:maleva/core/network/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:maleva/core/utils/app_globals.dart';
import 'core/models/model.dart';
import 'package:maleva/core/network/legacy_api_repository.dart';
import 'package:maleva/core/di/injection.dart';

class ChangeStatusPage extends StatefulWidget {
  final int masterId;

  const ChangeStatusPage({
    super.key,
    required this.masterId,
  });

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
    await sl<LegacyApiRepository>().apiAllinoneSelectArray(
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
