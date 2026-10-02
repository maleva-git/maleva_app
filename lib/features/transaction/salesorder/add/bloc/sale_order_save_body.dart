import 'package:maleva/features/transaction/salesorder/add/bloc/salesorderadd_state.dart';

/// The Java `SaleOrderDTO` for the save: the order as loaded, with this form's fields on
/// top. Fields the form does not show (loading/off boarding officers, PO flags, Remarks1,
/// ...) go back as they were; the React form's forwarding rows are not sent, so they stay.
Map<String, dynamic> saleOrderSaveBody(SalesOrderAddLoaded s, {required int companyId, required int employeeId}) {
  String? at(bool ticked, String value) => ticked ? _isoDateTime(value) : null;
  int? idOrNull(int id) => id == 0 ? null : id;

  List<String> col(List<dynamic> list) => [for (final v in list) v?.toString() ?? ''];
  String at3(List<dynamic> list, int i) => i < list.length ? (list[i]?.toString() ?? '') : '';

  final pickupAddresses = s.pickUpAddressList.isNotEmpty ? col(s.pickUpAddressList)
      : (s.txtPickUpAddress.isNotEmpty ? [s.txtPickUpAddress] : <String>[]);
  final pickupQuantities = s.pickUpAddressList.isNotEmpty ? col(s.pickUpQuantityList) : [s.txtPickUpQuantity];
  final pickupWeights = s.pickUpAddressList.isNotEmpty ? col(s.pickUpWeightList) : [s.txtPickUpWeight];
  final deliveryAddresses = s.deliveryAddressList.isNotEmpty ? col(s.deliveryAddressList)
      : (s.txtDeliveryAddress.isNotEmpty ? [s.txtDeliveryAddress] : <String>[]);
  final deliveryQuantities = s.deliveryAddressList.isNotEmpty ? col(s.deliveryQuantityList) : [s.txtDeliveryQuantity];
  final deliveryWeights = s.deliveryAddressList.isNotEmpty ? col(s.deliveryWeightList) : [s.txtDeliveryWeight];
  final pickupTime = at(s.checkBoxValuePickUp, s.dtpPickUpdate);
  final deliveryTime = at(s.checkBoxValueDelivery, s.dtpDeliverydate);

  return {
    ...s.loadedMaster,
    'id': s.editId,
    'cNumber': s.editId > 0 ? s.loadedMaster['cNumber'] : 0,
    'cNumberDisplay': s.editId > 0 ? s.loadedMaster['cNumberDisplay'] : '',
    'companyRefId': companyId,
    'employeeRefId': idOrNull(employeeId),
    'customerRefId': s.custId,
    'jobMasterRefId': s.jobTypeId,
    'jStatus': idOrNull(s.statusId),
    'billType': s.dropdownValue,
    'saleDate': _isoDateTime(s.dtpSaleOrderdate),
    'agentCompanyRefId': idOrNull(s.lAgentCompanyId),
    'agentMasterRefId': idOrNull(s.lAgentId),
    'oAgentCompanyRefId': idOrNull(s.oAgentCompanyId),
    'oAgentMasterRefId': idOrNull(s.oAgentId),
    'remarks': s.txtRemarks,
    'doDescription': s.txtDoDescription,
    'amount': s.totalAmount,
    'grossAmount': s.totalAmount,
    'taxAmount': s.taxAmount,
    'coinage': s.coinage,
    'currencyValue': s.currencyValue,
    'actualNetAmount': s.actualAmount,
    'offvesselname': s.txtOffVessel,
    'loadingvesselname': s.txtLoadingVessel,
    'sPort': s.txtLPort,
    'oPort': s.txtOPort,
    'vessel': s.txtLVesselType,
    'oVessel': s.txtOVesselType,
    'commodity': s.txtCommodityType,
    'cargo': s.txtCargo,
    'eta': at(s.checkBoxValueLETA, s.dtpLETAdate),
    'etb': at(s.checkBoxValueLETB, s.dtpLETBdate),
    'etd': at(s.checkBoxValueLETD, s.dtpLETDdate),
    'flighTime': at(s.checkBoxValueFlightTime, s.dtpFlightTimedate),
    'oeta': at(s.checkBoxValueOETA, s.dtpOETAdate),
    'oetb': at(s.checkBoxValueOETB, s.dtpOETBdate),
    'oetd': at(s.checkBoxValueOETD, s.dtpOETDdate),
    'awbNo': s.txtAWBNo,
    'blCopy': s.txtBLCopy,
    'quantity': s.txtQuantity,
    'totalWeight': s.txtWeight,
    'truckSize': s.txtTruckSize,
    'scn': s.txtOSCN,
    'lscn': s.txtLSCN,
    'ptw': s.txtPTWNo,
    'sealbyRefid': idOrNull(s.sealEmpId1),
    'sealbreakbyRefid': idOrNull(s.breakEmpId1),
    'sealbyRefid2': idOrNull(s.sealEmpId2),
    'sealbreakbyRefid2': idOrNull(s.breakEmpId2),
    'sealbyRefid3': idOrNull(s.sealEmpId3),
    'sealbreakbyRefid3': idOrNull(s.breakEmpId3),
    'boardingOfficerRefid': idOrNull(s.boardOfficerId1),
    'boardingOfficer1Refid': idOrNull(s.boardOfficerId2),
    'boardingAmount': s.txtAmount1,
    'boardingAmount1': s.txtAmount2,
    'forwarding': s.dropdownValueFW1,
    'forwarding2': s.dropdownValueFW2,
    'forwarding3': s.dropdownValueFW3,
    'forwardingDate': at(s.checkBoxValueFW1, s.dtpFW1date),
    'forwarding2Date': at(s.checkBoxValueFW2, s.dtpFW2date),
    'forwarding3Date': at(s.checkBoxValueFW3, s.dtpFW3date),
    'forwardingEnterRef': s.txtENRef1,
    'forwardingExitRef': s.txtExRef1,
    'forwardingEnterRef2': s.txtENRef2,
    'forwardingExitRef2': s.txtExRef2,
    'forwardingEnterRef3': s.txtENRef3,
    'forwardingExitRef3': s.txtExRef3,
    'forwardingSMKNo': s.txtSmk1,
    'forwardingSMKNo2': s.txtSmk2,
    'forwardingSMKNo3': s.txtSmk3,
    'forwarding1S1': s.txtForwarding1S1,
    'forwarding1S2': s.txtForwarding1S2,
    'forwarding2S1': s.txtForwarding2S1,
    'forwarding2S2': s.txtForwarding2S2,
    'forwarding3S1': s.txtForwarding3S1,
    'forwarding3S2': s.txtForwarding3S2,
    'portChargesRef': s.txtPortChargeRef1,
    'portCharges': s.txtPortCharges,
    'zb': s.dropdownValueZB1,
    'zb2': s.dropdownValueZB2,
    'zbRef': s.txtZBRef1,
    'zbRef2': s.txtZBRef2,
    'origin': s.txtOrigin,
    'destination': s.txtDestination,
    'originRefId': idOrNull(s.originId),
    'destinationRefId': idOrNull(s.destinationId),
    'pickupDate': pickupTime,
    'deliveryDate': deliveryTime,
    'wareHouseEnterDate': at(s.checkBoxValueWHEntry, s.dtpWHEntrydate),
    'wareHouseExitDate': at(s.checkBoxValueWHExit, s.dtpWHExitdate),
    'wareHouseAddress': s.txtWarehouseAddress,
    // the legacy columns, "{@}"-joined as .NET wrote and the edit read splits them
    'pickupAddress': pickupAddresses.join('{@}'),
    'pickupQuantityList': pickupQuantities.join('{@}'),
    'deliveryAddress': deliveryAddresses.join('{@}'),
    'deliveryQuantityList': deliveryQuantities.join('{@}'),
    'pickupDetails': [
      for (var i = 0; i < pickupAddresses.length; i++)
        {
          'pickupAddress': pickupAddresses[i],
          'pickupQuantity': at3(pickupQuantities, i),
          'pickupWeaight': at3(pickupWeights, i),
          'pickupTime': pickupTime,
          'rowNumber': i + 1,
        }
    ],
    'deliveryDetails': [
      for (var i = 0; i < deliveryAddresses.length; i++)
        {
          'deliveryAddress': deliveryAddresses[i],
          'deliveryQuantity': at3(deliveryQuantities, i),
          'deliveryWeight': at3(deliveryWeights, i),
          'deliveryTime': deliveryTime,
          'rowNumber': i + 1,
        }
    ],
    'SaleOrderDetails': [
      for (var i = 0; i < s.productViewList.length; i++)
        s.productViewList[i].toJava(
            itemMasterRefId: i < s.productIds.length ? s.productIds[i] : s.productViewList[i].ItemMasterRefId)
    ],
  };
}

/// The form's "yyyy-MM-dd[ HH:mm:ss]" as the ISO date-time Java reads.
String _isoDateTime(String value) => DateTime.parse(value).toIso8601String().split('.').first;
