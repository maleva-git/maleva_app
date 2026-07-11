import 'package:flutter/material.dart';
import '../models/vesselplanningweb_model.dart';
import '../../../../../core/utils/app_globals.dart';

class VesselPlanningUpdateSheet extends StatefulWidget {
  final VesselPlanningWebModel jobData;
  final Function(List<Map<String, dynamic>>) onUpdate;

  const VesselPlanningUpdateSheet({super.key, required this.jobData, required this.onUpdate});

  @override
  _VesselPlanningUpdateSheetState createState() => _VesselPlanningUpdateSheetState();
}

class _VesselPlanningUpdateSheetState extends State<VesselPlanningUpdateSheet> {
  late TextEditingController _ptwController;
  late TextEditingController _etbController;
  late TextEditingController _etdController;
  
  @override
  void initState() {
    super.initState();
    _ptwController = TextEditingController(text: widget.jobData.ptw);
    _etbController = TextEditingController(text: widget.jobData.etb);
    _etdController = TextEditingController(text: widget.jobData.etd);
  }

  @override
  void dispose() {
    _ptwController.dispose();
    _etbController.dispose();
    _etdController.dispose();
    super.dispose();
  }

  void _submitUpdate(int type) {
    // Type 100 is save all in the backend
    List<Map<String, dynamic>> updateList = [
      {
        "Id": widget.jobData.saleOrderMasterRefId,
        "PTW": _ptwController.text,
        "BoardingOfficeName": "",
        "BoardingOfficeName1": "",
        "BoardingAmount": 0,
        "BoardingAmount1": 0,
        "ETB": _etbController.text.isNotEmpty ? _etbController.text : null,
        "ETD": _etdController.text.isNotEmpty ? _etdController.text : null,
        "BoardingOfficerRefid": null,
        "BoardingOfficer1Refid": null,
        "OETB": null,
        "OETD": null,
        "Comid": AppGlobals.Comid,
        "Type": type,
      }
    ];
    
    widget.onUpdate(updateList);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      height: MediaQuery.of(context).size.height * 0.6,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Update Job: ${widget.jobData.jobNo}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            ],
          ),
          const Divider(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: _ptwController,
                    decoration: const InputDecoration(labelText: "PTW"),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _etbController,
                    decoration: const InputDecoration(labelText: "ETB (yyyy-MM-dd HH:mm:ss)"),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _etdController,
                    decoration: const InputDecoration(labelText: "ETD (yyyy-MM-dd HH:mm:ss)"),
                  ),
                ],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => _submitUpdate(100),
            child: const Text("Save Updates"),
          )
        ],
      ),
    );
  }
}
