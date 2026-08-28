import 'package:maleva/core/network/legacy_api_repository.dart';
import 'package:maleva/core/di/injection.dart';
import 'package:maleva/core/network/api_constants.dart';
import 'package:maleva/core/utils/app_globals.dart';


class PlanningRepository {
  Future<List<dynamic>> getPlanning(
      String fromDate, String toDate, String planningNo, int empId) async {
    Map<String, dynamic> master = {
      "Comid": AppGlobals.storagenew.getInt('Comid') ?? 0,
      "Fromdate": fromDate,
      "Todate": toDate,
      "Employeeid": empId,
      "Search": planningNo,
    };
    Map<String, String> header = {
      'Content-Type': 'application/json; charset=UTF-8'
    };

    final resultData = await sl<LegacyApiRepository>().apiAllinoneSelectArray(
        ApiConstants.apiSelectPlanning, master, header, null);
    
    if (resultData == null || resultData == "") {
      return [];
    }
    return resultData as List<dynamic>;
  }

  Future<void> editPlanning(dynamic context, int id, int planningNo) async {
    var comId = AppGlobals.storagenew.getInt('Comid') ?? 0;

    final resultData = await sl<LegacyApiRepository>().apiAllinoneSelect(
        Uri.encodeFull(
            "${ApiConstants.apiEditPlanning}$id&PLANINGNo=$planningNo&Comid=$comId"),
        null,
        null,
        context);

    if (resultData.isNotEmpty) {
      AppGlobals.PlanningEditList = resultData[0]["SaleDetails"].toList();
    } else {
      AppGlobals.PlanningEditList = [];
    }
  }

  Future<Map<String, dynamic>?> getSharePdfUrl(dynamic context, int id, String planningNoDisplay) async {
    Map<String, dynamic> master = {
      'SoId': id,
      'Comid': AppGlobals.Comid,
    };
    Map<String, String> header = {
      'Content-Type': 'application/json; charset=UTF-8'
    };

    final resultData = await sl<LegacyApiRepository>().apiAllinoneSelectArray(
      "${ApiConstants.apiViewPlanningPdf}$planningNoDisplay",
      master,
      header,
      context,
    );
    
    if (resultData == null || resultData == "") {
      return null;
    }
    return resultData as Map<String, dynamic>;
  }

  Future<void> selectEmployee(dynamic context, String type, String userType) async {
    await sl<LegacyApiRepository>().SelectEmployee(context, type, userType);
  }
  Future<bool> savePlanning(dynamic state) async {
    try {
      final List<Map<String, dynamic>> payload = [];
      
      for (var master in state.masterList) {
        final details = state.detailsMap[master.id] ?? [];
        final saleDetails = details.map((d) => {
          'Id': d.id,
          'JobNo': d.jobNo,
          'JobDate': d.jobDate,
          'TruckName': d.truckName,
          'TruckRefid': d.truckRefId,
          'DriverName': d.driverName,
          'DriverRefid': d.driverRefId,
          'PickupDate': d.pickupDate,
          'DeliveryDate': d.deliveryDate,
          'Origin': d.origin,
          'Destination': d.destination,
          'PickupAddress': d.pickupAddress,
          'DeliveryAddress': d.deliveryAddress,
          'Package': d.package,
          'Weight': d.weight,
          'Remarks': d.remarks,
        }).toList();

        payload.add({
          'Id': master.id,
          'CompanyRefId': AppGlobals.Comid,
          'SaleDate': master.planningDate, // from state
          'CNumberDisplay': master.planningNoDisplay,
          'Remarks': master.remarks,
          'SaleDetails': saleDetails
        });
      }

      Map<String, String> header = {'Content-Type': 'application/json; charset=UTF-8', 'Comid': AppGlobals.Comid.toString()};
      
      final resultData = await sl<LegacyApiRepository>().apiAllinone(
          "${ApiConstants.port}/PLANING/InsertPLANING", payload, header, null);

      if (resultData != null && resultData.toString().isNotEmpty) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

}

