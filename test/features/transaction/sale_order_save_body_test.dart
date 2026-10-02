import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/models/shared/sale_edit_detail_model.dart';
import 'package:maleva/core/sale_order/sale_order_keys.dart';
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

  test('an enquiry row reads as a Java sale order', () {
    expect(javaSaleOrderFromDotNet({'CustomerRefId': 5, 'SPort': 'PKG', 'AWBNo': 'A1', 'OETA': null, 'LiveCPop': 1}),
        {'customerRefId': 5, 'sPort': 'PKG', 'awbNo': 'A1', 'oeta': null, 'livecpop': 1});
  });
}
