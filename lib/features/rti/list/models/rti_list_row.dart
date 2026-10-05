import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/utils/json_read.dart';

/// A job on an RTI: the Java `RtiJob` of `/with-jobs` (`id`, `saleOrderMasterRefId`, `jobNo`,
/// `jobDate`, `customerName`), or a line of the full RTI (`jobNo`, `customerName`).
class RtiListJob extends Equatable {
  const RtiListJob({required this.jobNo, this.customerName = '', this.id = 0, this.saleOrderId = 0});

  factory RtiListJob.fromJava(Map<String, dynamic> j) => RtiListJob(
        id: JsonRead.integer(j['id']),
        saleOrderId: JsonRead.integer(j['saleOrderMasterRefId']),
        jobNo: JsonRead.string(JsonRead.field(j, 'jobNo')).trim(),
        customerName: JsonRead.string(JsonRead.field(j, 'customerName')).trim(),
      );

  final int id;
  final int saleOrderId;
  final String jobNo;
  final String customerName;

  @override
  List<Object?> get props => [id, saleOrderId, jobNo, customerName];
}

/// One RTI of the list: the Java `RtiWithJobs` row (`id`, `rtiNoDisplay`, `rtiDate`,
/// `driverRefId`, `driverName`, `truckRefId`, `truckName`, `employeeRefId`, `remarks`,
/// `amount`, `jobs`).
class RtiListRow extends Equatable {
  const RtiListRow({
    required this.id,
    required this.rtiNo,
    this.rtiDate,
    this.driverRefId = 0,
    this.driverName = '',
    this.truckRefId = 0,
    this.truckName = '',
    this.employeeRefId = 0,
    this.remarks = '',
    this.amount = 0,
    this.jobs = const [],
  });

  factory RtiListRow.fromJava(Map<String, dynamic> r) => RtiListRow(
        id: JsonRead.integer(r['id']),
        rtiNo: JsonRead.string(r['rtiNoDisplay']).trim(),
        rtiDate: JsonRead.date(r['rtiDate']),
        driverRefId: JsonRead.integer(r['driverRefId']),
        driverName: JsonRead.string(r['driverName']).trim(),
        truckRefId: JsonRead.integer(r['truckRefId']),
        truckName: JsonRead.string(r['truckName']).trim(),
        employeeRefId: JsonRead.integer(r['employeeRefId']),
        remarks: JsonRead.string(r['remarks']),
        amount: JsonRead.number(r['amount']),
        jobs: [for (final j in JsonRead.listOfMaps(r['jobs'])) RtiListJob.fromJava(j)],
      );

  final int id;
  final String rtiNo;
  final DateTime? rtiDate;
  final int driverRefId;
  final String driverName;
  final int truckRefId;
  final String truckName;
  final int employeeRefId;
  final String remarks;
  final double amount;
  final List<RtiListJob> jobs;

  /// "Not Salary Entered RTI" (`RTIViewPage.tsx:174-183`): the amount is 0.
  bool get salaryMissing => amount == 0;

  /// `RM x.xx`, as React's Amount column (`toFixed(2)`).
  String get amountText => rmFixed(amount);

  /// React's Date column, `toLocaleDateString('en-GB')`: "05/10/2026".
  String get dateText => rtiDate == null ? '-' : DateFormat('dd/MM/yyyy').format(rtiDate!);

  /// The preview's date: "05 Oct 2026".
  String get longDateText => rtiDate == null ? '-' : DateFormat('dd MMM yyyy', 'en_US').format(rtiDate!);

  static String rmFixed(num amount) => 'RM ${amount.toStringAsFixed(2)}';

  @override
  List<Object?> get props =>
      [id, rtiNo, rtiDate, driverRefId, driverName, truckRefId, truckName, employeeRefId, remarks, amount, jobs];
}

/// What the preview adds from the full RTI (`RTIDetailPanel`, `RTIViewPage.tsx:749-848`): the
/// destination, the remarks and the job lines.
class RtiPreviewData extends Equatable {
  const RtiPreviewData({this.destination = '', this.remarks = '', this.jobs = const []});

  factory RtiPreviewData.fromJava(Map<String, dynamic> master, List<Map<String, dynamic>> lines) => RtiPreviewData(
        destination: JsonRead.string(master['destination']).trim(),
        remarks: JsonRead.string(master['remarks']).trim(),
        jobs: [
          for (final l in lines)
            if (JsonRead.string(JsonRead.field(l, 'jobNo')).trim().isNotEmpty) RtiListJob.fromJava(l),
        ],
      );

  final String destination;
  final String remarks;
  final List<RtiListJob> jobs;

  @override
  List<Object?> get props => [destination, remarks, jobs];
}

/// The answer of "share to WhatsApp" (`Data1`: `sent`, `rtiNo`, `truck`, `detail`,
/// `documentSkipped`).
class RtiShareResult extends Equatable {
  const RtiShareResult({required this.sent, this.rtiNo = '', this.truck = '', this.detail = '', this.documentSkipped});

  factory RtiShareResult.fromJava(Map<String, dynamic> m) => RtiShareResult(
        sent: JsonRead.boolean(m['sent']),
        rtiNo: JsonRead.string(m['rtiNo']).trim(),
        truck: JsonRead.string(m['truck']).trim(),
        detail: JsonRead.string(m['detail']).trim(),
        documentSkipped: JsonRead.stringOrNull(m['documentSkipped']),
      );

  final bool sent;
  final String rtiNo;
  final String truck;
  final String detail;
  final String? documentSkipped;

  @override
  List<Object?> get props => [sent, rtiNo, truck, detail, documentSkipped];
}
