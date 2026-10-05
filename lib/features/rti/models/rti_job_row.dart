import 'package:equatable/equatable.dart';
import 'package:maleva/features/rti/models/js_values.dart';

/// One line of the RTI job grid (`R/types/rtiApi.ts` `RTIGridRow`, `createInitialGridRow`),
/// named as the Java `RTIDetailsDto`. [salary] and [pwdType] hold the text typed in the
/// cell, as the web's grid does; [salaryValue] reads it the way the web's total does.
class RtiJobRow extends Equatable {
  const RtiJobRow({
    this.jobNo = '',
    this.customerName = '',
    this.jobDate = '',
    this.salary = '0',
    this.ppic = '',
    this.dpic = '',
    this.pwdType = '0',
    this.originD = '',
    this.destinationD = '',
    this.pickupDateD = '',
    this.deliveryDateD = '',
    this.pickupAddressD = '',
    this.deliveryAddressD = '',
    this.pickupAddressTimelistD = '',
    this.pickupAddressQuantityD = '',
    this.deliveryAddressQuantityD = '',
    this.deliveryAddressdatelistD = '',
    this.id = 0,
    this.saleOrderMasterRefId = 0,
    this.rtiMasterRefId = 0,
    this.editMode = 0,
  });

  final String jobNo;
  final String customerName;
  final String jobDate;
  final String salary;
  final String ppic;
  final String dpic;
  final String pwdType;
  final String originD;
  final String destinationD;
  final String pickupDateD;
  final String deliveryDateD;
  final String pickupAddressD;
  final String deliveryAddressD;
  final String pickupAddressTimelistD;
  final String pickupAddressQuantityD;
  final String deliveryAddressQuantityD;
  final String deliveryAddressdatelistD;

  /// The RTIDetails id; 0 for a new line.
  final int id;
  final int saleOrderMasterRefId;
  final int rtiMasterRefId;
  final int editMode;

  /// The calculation's `parseFloat(String(row.Salary || 0))`.
  double get salaryForTotal {
    final raw = salary.isEmpty ? '0' : salary;
    return Js.parseFloat(raw) ?? double.nan;
  }

  /// The save's `getNumber(row.Salary)`.
  num get salaryValue => Js.number([salary]);

  /// No job typed and nothing looked up (the web's blank row test in the lookup).
  bool get isBlank => jobNo.isEmpty && customerName.isEmpty;

  /// The grid's placeholder test: one row with no job, customer or salary.
  bool get isPlaceholder => jobNo.isEmpty && customerName.isEmpty && (Js.toNumber(salary) ?? 0) == 0;

  /// Text of an editable column: `JobNo`, `Salary`, `PPIC`, `DPIC`, `PWDType`.
  String cell(String column) => switch (column) {
        RtiJobColumns.jobNo => jobNo,
        RtiJobColumns.salary => salary,
        RtiJobColumns.ppic => ppic,
        RtiJobColumns.dpic => dpic,
        RtiJobColumns.pwdType => pwdType,
        _ => '',
      };

  /// The row with one editable column set (and `EditMode` 1), as `updateGridRow`.
  RtiJobRow withCell(String column, String value) => switch (column) {
        RtiJobColumns.jobNo => copyWith(jobNo: value, editMode: 1),
        RtiJobColumns.salary => copyWith(salary: value, editMode: 1),
        RtiJobColumns.ppic => copyWith(ppic: value, editMode: 1),
        RtiJobColumns.dpic => copyWith(dpic: value, editMode: 1),
        RtiJobColumns.pwdType => copyWith(pwdType: value, editMode: 1),
        _ => this,
      };

  RtiJobRow copyWith({
    String? jobNo,
    String? customerName,
    String? jobDate,
    String? salary,
    String? ppic,
    String? dpic,
    String? pwdType,
    String? originD,
    String? destinationD,
    String? pickupDateD,
    String? deliveryDateD,
    int? id,
    int? saleOrderMasterRefId,
    int? editMode,
  }) =>
      RtiJobRow(
        jobNo: jobNo ?? this.jobNo,
        customerName: customerName ?? this.customerName,
        jobDate: jobDate ?? this.jobDate,
        salary: salary ?? this.salary,
        ppic: ppic ?? this.ppic,
        dpic: dpic ?? this.dpic,
        pwdType: pwdType ?? this.pwdType,
        originD: originD ?? this.originD,
        destinationD: destinationD ?? this.destinationD,
        pickupDateD: pickupDateD ?? this.pickupDateD,
        deliveryDateD: deliveryDateD ?? this.deliveryDateD,
        pickupAddressD: pickupAddressD,
        deliveryAddressD: deliveryAddressD,
        pickupAddressTimelistD: pickupAddressTimelistD,
        pickupAddressQuantityD: pickupAddressQuantityD,
        deliveryAddressQuantityD: deliveryAddressQuantityD,
        deliveryAddressdatelistD: deliveryAddressdatelistD,
        id: id ?? this.id,
        saleOrderMasterRefId: saleOrderMasterRefId ?? this.saleOrderMasterRefId,
        rtiMasterRefId: rtiMasterRefId,
        editMode: editMode ?? this.editMode,
      );

  @override
  List<Object?> get props => [
        jobNo, customerName, jobDate, salary, ppic, dpic, pwdType, originD, destinationD, pickupDateD, deliveryDateD,
        pickupAddressD, deliveryAddressD, pickupAddressTimelistD, pickupAddressQuantityD, deliveryAddressQuantityD,
        deliveryAddressdatelistD, id, saleOrderMasterRefId, rtiMasterRefId, editMode,
      ];
}

/// The editable columns of the job grid, in the web's order (`R/utils/rtiGridClipboard.ts`).
abstract final class RtiJobColumns {
  static const jobNo = 'JobNo';
  static const salary = 'Salary';
  static const ppic = 'PPIC';
  static const dpic = 'DPIC';
  static const pwdType = 'PWDType';
  static const editable = [jobNo, salary, ppic, dpic, pwdType];
  static const numeric = {salary, pwdType};

  /// `coerceRTIEditableCellValue`: Salary / PWD become numbers (blank or bad → 0).
  static String coerce(String column, String raw) {
    if (!numeric.contains(column)) return raw;
    final t = raw.trim();
    if (t.isEmpty) return '0';
    final n = num.tryParse(t);
    return n == null || !n.isFinite ? '0' : Js.str(n);
  }

  /// `parseRTIClipboardMatrix`: rows by line, cells by tab, empty lines dropped.
  static List<List<String>> parseClipboard(String text) => text
      .replaceAll('\r', '')
      .split('\n')
      .where((r) => r.isNotEmpty)
      .map((r) => r.split('\t'))
      .toList();
}
