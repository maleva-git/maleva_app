import 'package:intl/intl.dart';
import 'package:maleva/core/utils/json_read.dart';


class RTIMasterViewModel {
  int Id;
  int RTINo;
  int TruckMasterRefId;
  String RTIDate;
  String RTINoDisplay;
  String DriverName;
  String TruckName;
  String Remarks;
  double Amount;

  RTIMasterViewModel(
      this.Id, this.RTINo,this.TruckMasterRefId,this.RTINoDisplay, this.RTIDate, this.DriverName, this.TruckName, this.Remarks, this.Amount);

  /// One RTI of the shared Java list (`/api/rti-masters/with-jobs`).
  RTIMasterViewModel.fromJava(Map<String, dynamic> json)
      : Id = JsonRead.integer(json['id']),
        RTINo = JsonRead.integer(json['rtiNo']),
        TruckMasterRefId = JsonRead.integer(json['truckRefId']),
        RTINoDisplay = JsonRead.string(json['rtiNoDisplay']),
        RTIDate = _dmy(json['rtiDate']),
        DriverName = JsonRead.string(json['driverName']),
        TruckName = JsonRead.string(json['truckName']),
        Remarks = JsonRead.string(json['remarks']),
        Amount = JsonRead.number(json['amount']);

  /// A Java date as the screens show it, `dd/MM/yyyy`.
  static String _dmy(dynamic value) {
    final d = JsonRead.date(value);
    return d == null ? '' : DateFormat('dd/MM/yyyy').format(d);
  }

  // method
  Map<String, dynamic> toJson() {
    return {
      'Id': Id,
      'RTINo': RTINo,
      'TruckMasterRefId': TruckMasterRefId,
      'RTINoDisplay': RTINoDisplay,
      'RTIDate': RTIDate,
      'DriverName': DriverName,
      'TruckName': TruckName,
      'Remarks': Remarks,
      'Amount': Amount
    };
  }

  RTIMasterViewModel.Empty()
      : Id = 0,
        RTINo = 0,
        TruckMasterRefId = 0,
        RTINoDisplay = '',
        RTIDate = '',
        DriverName = '',
        TruckName = '',
        Remarks = '',
        Amount = 0.0;
}