import 'package:intl/intl.dart';
import 'package:maleva/core/models/shared/patty_cash_details_model.dart';
import 'package:maleva/core/utils/json_read.dart';

class PattycashMasterModel {
  int Id;
  int companyRefId;
  int employeeRefId;
  String? cNumberDisplay;
  String? employeeName;
  DateTime pettyCashDate;
  String? paymentStatus;
  int cNumber;
  int status;
  String? amount;
  List<PattyCashDetailsModel> pattyCashDetails;

  PattycashMasterModel({
    required this.Id,
    required this.companyRefId,
    required this.employeeRefId,
    this.cNumberDisplay,
    this.employeeName,
    required this.pettyCashDate,
    this.paymentStatus,
    required this.cNumber,
    required this.status,
    this.amount,
    required this.pattyCashDetails,
  });

  /// A petty cash of the shared Java `/api/petty-cash-masters` (`search` row
  /// or `edit`): the date comes as `spettyCashDate` dd/MM/yyyy (or the raw
  /// `pettyCashDate` on `edit`); the lines of `edit` are `pettyCashDetails`.
  factory PattycashMasterModel.fromJava(Map<String, dynamic> json, {int companyId = 0}) {
    dynamic f(String k) => JsonRead.field(json, k);
    DateTime? day;
    final shown = JsonRead.stringOrNull(f('sPettyCashDate'));
    if (shown != null) {
      try {
        day = DateFormat('dd/MM/yyyy').parseStrict(shown);
      } catch (_) {}
    }
    day ??= JsonRead.date(f('pettyCashDate'));
    return PattycashMasterModel(
      Id: JsonRead.integer(f('id')),
      companyRefId: JsonRead.intOrNull(f('companyRefId')) ?? companyId,
      employeeRefId: JsonRead.integer(f('employeeRefId')),
      cNumberDisplay: JsonRead.stringOrNull(f('cNumberDisplay')),
      employeeName: JsonRead.stringOrNull(f('employeeName')),
      pettyCashDate: day ?? DateTime(1900),
      paymentStatus: JsonRead.stringOrNull(f('paymentStatus')),
      cNumber: JsonRead.integer(f('cNumber')),
      status: JsonRead.integer(f('status')),
      amount: JsonRead.stringOrNull(f('amount')),
      pattyCashDetails: [
        for (final line in JsonRead.listOfMaps(f('pettyCashDetails')))
          PattyCashDetailsModel.fromJava(line, masterId: JsonRead.integer(f('id'))),
      ],
    );
  }

  Map<String, dynamic> toJson() => {
    'Id': Id,
    'CompanyRefId': companyRefId,
    'EmployeeRefId': employeeRefId,
    'CNumberDisplay': cNumberDisplay,
    'EmployeeName': employeeName,
    'PettyCashDate': pettyCashDate.toIso8601String(),
    'PaymentStatus': paymentStatus,
    'CNumber': cNumber,
    'Status': status,
    'Amount': amount,
    'PattyCashDetails':
    pattyCashDetails.map((e) => e.toJson()).toList(),
  };
}