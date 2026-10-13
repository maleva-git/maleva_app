import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/models/shared/sale_edit_detail_model.dart';
import 'package:maleva/core/enquiry/enquiry_api.dart';
import 'package:maleva/features/transaction/salesorder/add/bloc/sale_order_save_body.dart';
import 'package:maleva/features/transaction/salesorder/add/bloc/salesorderadd_state.dart';

const _now = '2026-10-02 09:30:00';

SalesOrderAddLoaded form({int editId = 0, Map<String, dynamic> loaded = const {}}) => SalesOrderAddLoaded(
      editId: editId,
      loadedMaster: loaded,
      dtpSaleOrderdate: '2026-10-02',
      dtpOETAdate: _now,
      dtpOETBdate: _now,
      dtpOETDdate: _now,
      dtpLETAdate: _now,
      dtpLETBdate: _now,
      dtpLETDdate: _now,
      dtpFlightTimedate: _now,
      dtpPickUpdate: _now,
      dtpDeliverydate: _now,
      dtpWHEntrydate: _now,
      dtpWHExitdate: _now,
      dtpFW1date: _now,
      dtpFW2date: _now,
      dtpFW3date: _now,
    );

/// The Java `SaleOrderDTO` the Sale Order form saves (change sale-order-on-shared-java-api).
void main() {
  test('an update keeps what the form does not show and sends the job number back', () {
    // The Java update clears the boarding officers and the dates it is not sent, so the
    // loaded order goes back as it was under the form's own fields.
    final loaded = {
      'id': 40,
      'cNumber': 40,
      'cNumberDisplay': 'MY00040',
      'lBoardingOfficerRefid': 11,
      'oBoardingOfficer1Refid': 22,
      'remarks1': 'TRIP',
      'livecpop': 1,
    };
    final body = saleOrderSaveBody(
        form(editId: 40, loaded: loaded).copyWith(custId: 5, txtRemarks: 'NEW', checkBoxValueLETA: true),
        companyId: 6,
        employeeId: 0);

    expect(body['id'], 40);
    expect(body['cNumber'], 40);
    expect(body['cNumberDisplay'], 'MY00040');
    expect(body['lBoardingOfficerRefid'], 11);
    expect(body['oBoardingOfficer1Refid'], 22);
    expect(body['remarks1'], 'TRIP');
    expect(body['livecpop'], 1);
    expect(body['companyRefId'], 6);
    expect(body['employeeRefId'], isNull);
    expect(body['customerRefId'], 5);
    expect(body['remarks'], 'NEW');
    expect(body['eta'], '2026-10-02T09:30:00');
    expect(body['etb'], isNull, reason: 'an unticked date is cleared, as the web form');
    expect(body['saleDate'], '2026-10-02T00:00:00');
    expect(body.containsKey('forwardingDetails'), isFalse, reason: "the web's forwarding rows stay");
  });

  test('a new order has job number 0 and its stops in both shapes', () {
    final body = saleOrderSaveBody(
        form().copyWith(
          pickUpAddressList: ['PORT KLANG', 'SHAH ALAM'],
          pickUpQuantityList: ['2', '3'],
          pickUpWeightList: ['10', '20'],
          checkBoxValuePickUp: true,
          productViewList: [SaleEditDetailModel.fromJava({'itemMasterRefId': 9, 'itemQty': 2, 'salesRate': 50})],
          productIds: [9],
        ),
        companyId: 6,
        employeeId: 7);

    expect(body['id'], 0);
    expect(body['cNumber'], 0);
    expect(body['employeeRefId'], 7);
    expect(body['pickupAddress'], 'PORT KLANG{@}SHAH ALAM');
    expect(body['pickupQuantityList'], '2{@}3');
    expect(body['pickupDetails'], [
      {'pickupAddress': 'PORT KLANG', 'pickupQuantity': '2', 'pickupWeaight': '10', 'pickupTime': '2026-10-02T09:30:00', 'rowNumber': 1},
      {'pickupAddress': 'SHAH ALAM', 'pickupQuantity': '3', 'pickupWeaight': '20', 'pickupTime': '2026-10-02T09:30:00', 'rowNumber': 2},
    ]);
    expect(body['deliveryDetails'], isEmpty);
    final line = (body['SaleOrderDetails'] as List).single as Map;
    expect(line['itemMasterRefId'], 9);
    expect(line['itemQty'], 2);
    expect(line['salesRate'], 50);
  });

  // Change vessel-master-and-ptp-schedule: vessel suggestions, PTP date fill and links after save must
  // not change the save body. These lock today's body for typed vessel names, SCNs and dates.
  group('typed vessels (locked before vessel suggestions)', () {
    SalesOrderAddLoaded typed() => form().copyWith(
          txtLoadingVessel: 'CMA CGM PETRON',
          txtOffVessel: 'MAERSK RIO NEGRO',
          txtLSCN: 'L123',
          txtOSCN: '269EK6',
          txtLPort: 'WESTPORT',
          txtOPort: 'PTP',
          dtpLETAdate: '2026-10-13 08:00:00',
          dtpLETBdate: '2026-10-13 20:00:00',
          dtpLETDdate: '2026-10-14 17:00:00',
          dtpOETAdate: '2026-10-10 06:30:00',
          dtpOETBdate: '2026-10-10 12:00:00',
          dtpOETDdate: '2026-10-11 17:00:00',
          checkBoxValueLETA: true,
          checkBoxValueLETD: true,
          checkBoxValueOETA: true,
          checkBoxValueOETD: true,
        );

    test('names, SCNs, ports and ticked dates go out as typed; unticked ETBs are cleared', () {
      final body = saleOrderSaveBody(typed(), companyId: 6, employeeId: 7);

      expect(body['loadingvesselname'], 'CMA CGM PETRON');
      expect(body['offvesselname'], 'MAERSK RIO NEGRO');
      expect(body['lscn'], 'L123');
      expect(body['scn'], '269EK6');
      expect(body['sPort'], 'WESTPORT');
      expect(body['oPort'], 'PTP');
      expect(body['eta'], '2026-10-13T08:00:00');
      expect(body['etb'], isNull);
      expect(body['etd'], '2026-10-14T17:00:00');
      expect(body['oeta'], '2026-10-10T06:30:00');
      expect(body['oetb'], isNull);
      expect(body['oetd'], '2026-10-11T17:00:00');
    });

    test('the body has exactly today\'s keys (no vessel ids or links are added)', () {
      final body = saleOrderSaveBody(typed(), companyId: 6, employeeId: 7);

      expect(body.keys.toSet(), {
        'id', 'cNumber', 'cNumberDisplay', 'companyRefId', 'employeeRefId', 'customerRefId', 'jobMasterRefId',
        'jStatus', 'billType', 'saleDate', 'agentCompanyRefId', 'agentMasterRefId', 'oAgentCompanyRefId',
        'oAgentMasterRefId', 'remarks', 'doDescription', 'amount', 'grossAmount', 'taxAmount', 'coinage',
        'currencyValue', 'actualNetAmount', 'offvesselname', 'loadingvesselname', 'sPort', 'oPort', 'vessel',
        'oVessel', 'commodity', 'cargo', 'eta', 'etb', 'etd', 'flighTime', 'oeta', 'oetb', 'oetd', 'awbNo',
        'blCopy', 'quantity', 'totalWeight', 'truckSize', 'scn', 'lscn', 'ptw', 'sealbyRefid', 'sealbreakbyRefid',
        'sealbyRefid2', 'sealbreakbyRefid2', 'sealbyRefid3', 'sealbreakbyRefid3', 'boardingOfficerRefid',
        'boardingOfficer1Refid', 'boardingAmount', 'boardingAmount1', 'forwarding', 'forwarding2', 'forwarding3',
        'forwardingDate', 'forwarding2Date', 'forwarding3Date', 'forwardingEnterRef', 'forwardingExitRef',
        'forwardingEnterRef2', 'forwardingExitRef2', 'forwardingEnterRef3', 'forwardingExitRef3', 'forwardingSMKNo',
        'forwardingSMKNo2', 'forwardingSMKNo3', 'forwarding1S1', 'forwarding1S2', 'forwarding2S1', 'forwarding2S2',
        'forwarding3S1', 'forwarding3S2', 'portChargesRef', 'portCharges', 'zb', 'zb2', 'zbRef', 'zbRef2', 'origin',
        'destination', 'originRefId', 'destinationRefId', 'pickupDate', 'deliveryDate', 'wareHouseEnterDate',
        'wareHouseExitDate', 'wareHouseAddress', 'pickupAddress', 'pickupQuantityList', 'deliveryAddress',
        'deliveryQuantityList', 'pickupDetails', 'deliveryDetails', 'SaleOrderDetails',
      });
    });

    test('the same typed values give the same body', () {
      expect(saleOrderSaveBody(typed(), companyId: 6, employeeId: 7),
          saleOrderSaveBody(typed(), companyId: 6, employeeId: 7));
    });
  });

  test('a Java enquiry row reads as a Java sale order', () {
    expect(EnquiryApi.asSaleOrder({'customerRefId': 5, 'sport': 'PKG', 'awbNo': 'A1', 'oeta': null, 'jstatus': 2,
      'oagentCompanyRefId': 7, 'customerName': 'ACME'}),
        {'customerRefId': 5, 'sPort': 'PKG', 'awbNo': 'A1', 'oeta': null, 'jStatus': 2, 'oAgentCompanyRefId': 7,
          'customerName': 'ACME'});
  });
}
