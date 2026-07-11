
import 'package:maleva/core/utils/app_globals.dart';
import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/di/injection.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ViewSaleOrderRepository {
  final SharedPreferences prefs = sl<SharedPreferences>();

  Future<List<dynamic>> getJobNoForwarding(int billId) async {
    final comid = prefs.getInt('Comid') ?? 0;
    final url = "${AppGlobals.apiGetJobNo}$comid&JobType=$billId";
    
    final resultData = await AppGlobals.apiAllinoneSelectArray(Uri.encodeFull(url), null, null, null);
    
    if (resultData != null && resultData.isNotEmpty && resultData["Data1"] != null) {
      final List<dynamic> data1List = resultData["Data1"].toList();
      
      // Legacy support for unrefactored modules
      AppGlobals.ForwardingList = data1List
          .map((element) => ForwardingModel.fromJson(element))
          .toList()
          .cast<ForwardingModel>();
      AppGlobals.JobNoList = data1List;
      
      return data1List;
    } else {
      // Legacy support: clear if empty
      AppGlobals.ForwardingList.clear();
      AppGlobals.JobNoList.clear();
      return [];
    }
  }

  Future<void> editSalesOrder(int id, int saleNo) async {
    final comid = prefs.getInt('Comid') ?? 0;
    final url = "${AppGlobals.apiEditSalesOrder}$id&SaleorderNo=$saleNo&Comid=$comid";
    
    final resultData = await AppGlobals.apiAllinoneSelect(Uri.encodeFull(url), null, null, null);
    
    if (resultData != null && resultData.isNotEmpty) {
      // Legacy support for unrefactored modules
      AppGlobals.SaleEditMasterList = resultData;
      if (resultData[0]["SaleDetails"] != null) {
        AppGlobals.SaleEditDetailList = (resultData[0]["SaleDetails"] as List)
            .map((element) => SaleEditDetailModel.fromJson(element))
            .toList()
            .cast<SaleEditDetailModel>();
      } else {
        AppGlobals.SaleEditDetailList.clear();
      }
    } else {
      throw Exception("Data empty ah iruku");
    }
  }
}
