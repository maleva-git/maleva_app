import 'package:maleva/core/utils/json_read.dart';
import 'package:maleva/core/widgets/ui/formats.dart';

import '../../po/data/po_draft.dart';
import '../../records/data/payable_record.dart';

double _r2(double v) => (v * 100).roundToDouble() / 100;

/// The bill statuses of the web form (`features/bills`): Completed (the default) or Cancel.
const billStatuses = ['Completed', 'Cancel'];

/// A supplier bill being made or changed in the app (change `payable-bill-form`): the web bill form's fields and rules
/// (`features/bills/api/billsApi.ts`, `utils/billCalculations.ts`, `hooks/useBillSave.ts`). Lines use [PoLine]: same
/// maths (tax = qty × rate × tax% ÷ 100; amount = qty × rate + tax).
class BillDraft {
  BillDraft({
    this.id = 0,
    this.number = '',
    this.supplier,
    DateTime? billDate,
    this.invoiceNo = '',
    DateTime? invoiceDate,
    this.dueDate,
    this.paymentTermId,
    this.description = '',
    this.saleType = 'CREDIT',
    this.status = 'Completed',
    this.truck,
    this.driver,
    this.remarks = '',
    this.currencyValue = 0,
    this.currencyValue1 = 1,
    this.poId,
    this.poNumber = '',
    List<PoLine>? lines,
  })  : billDate = billDate ?? Fmt.today(),
        invoiceDate = invoiceDate ?? Fmt.today(),
        lines = lines ?? [];

  int id;
  String number;
  Option? supplier;
  DateTime billDate;
  String invoiceNo;
  DateTime invoiceDate;
  DateTime? dueDate;
  int? paymentTermId;
  String description;

  /// CREDIT (default) or CASH.
  String saleType;
  String status;
  Option? truck;
  Option? driver;
  String remarks;

  /// The supplier's currency rate (`/api/bills/supplier-currency`); the web sends 0 when none.
  double currencyValue;
  double currencyValue1;

  /// The purchase order this bill is made from (Push to Bill); stored by the server on a new bill only.
  int? poId;
  String poNumber;
  List<PoLine> lines;

  bool get isNew => id == 0;

  /// Rows the web sends: those with an account.
  List<PoLine> get accountLines => lines.where((l) => l.account != null).toList();

  /// The web adds qty × rate + tax over the rows and rounds once.
  double get total => _r2(accountLines.fold(0.0, (s, l) => s + l.qty * l.rate + l.qty * l.rate * l.taxPercent / 100));
  double get taxTotal => _r2(accountLines.fold(0.0, (s, l) => s + l.qty * l.rate * l.taxPercent / 100));

  /// The web's checks in order (`hooks/useBillSave.ts`). [invoiceUsed]: a new bill's invoice no. is on another bill;
  /// [paid]: what is already paid on this bill (edit), which the total may not go below.
  List<String> problems({bool invoiceUsed = false, double paid = 0}) {
    final p = <String>[];
    if (supplier == null) p.add('Choose the supplier');
    if (paymentTermId == null || paymentTermId! <= 0) p.add('Choose the payment term');
    if (invoiceNo.trim().isEmpty) p.add('Type the invoice number');
    if (description.trim().isEmpty) p.add('Choose the expense type');
    for (var i = 0; i < lines.length; i++) {
      final l = lines[i];
      if (l.account == null && (l.qty != 0 || l.rate != 0) && (l.rate != 0 || l.remarks.trim().isNotEmpty)) {
        p.add('Item ${i + 1}: choose the account');
      }
    }
    if (accountLines.isEmpty) p.add('Add at least one item');
    if (accountLines.any((l) => l.qty <= 0)) p.add('Every item needs a quantity above 0');
    if (accountLines.any((l) => l.rate < 0 || l.taxPercent < 0)) p.add('Amounts cannot be below zero');
    if (isNew && invoiceUsed) p.add('Invoice number ${invoiceNo.trim()} already exists');
    if (!isNew && paid > 0 && total < paid) {
      p.add('The total ${Fmt.rm(total)} is below what is already paid (${Fmt.rm(paid)})');
    }
    return p;
  }

  static String _dt(DateTime d) => '${Fmt.ymd(d)}T00:00:00';

  /// The body of `POST /api/bills/save` (web `billsApi.ts` buildSavePayload).
  Map<String, dynamic> toJson({required int companyId, required int? employeeId}) {
    final cv = currencyValue;
    final cv1 = currencyValue1 == 0 ? 1.0 : currencyValue1;
    return {
      'id': id,
      'companyRefId': companyId,
      'userRefId': null,
      'employeeRefId': (employeeId ?? 0) > 0 ? employeeId : null,
      'supplierRefId': supplier?.id ?? 0,
      'saleDate': _dt(billDate),
      'invoiceDate': _dt(invoiceDate),
      'invoiceNo': invoiceNo.trim().toUpperCase(),
      'saleType': saleType,
      'coinage': 0,
      'discountAmount': 0,
      'plusAmount': 0,
      'minusAmount': 0,
      'grossAmount': total,
      'amount': total,
      'taxAmount': taxTotal,
      'remarks': remarks.trim(),
      'description': description.trim(),
      'paymentTermsRefid': paymentTermId ?? 0,
      'billStatus': status,
      'truckRefid': truck?.id,
      'driverRefid': driver?.id,
      'currencyValue': cv,
      'currencyValue1': cv1,
      'actualAmount': _r2(total * cv),
      'dueDate': dueDate == null ? null : Fmt.ymd(dueDate!),
      'billsOrderMasterRefId': (poId ?? 0) > 0 ? poId : null,
      'billDetails': [
        for (final l in accountLines)
          {
            'id': l.id,
            'accountMasterRefId': l.account!.id,
            'mrp': 0,
            'purchaseRate': 0,
            'itemQty': l.qty,
            'discPer': 0,
            'discAmount': 0,
            'landingCost': 0,
            'taxPercent': l.taxPercent,
            'taxAmount': l.taxAmount,
            'salesRate': l.rate,
            'netSalesRate': 0,
            'amount': l.amount,
            'remarksD': l.remarks.trim(),
            'currencyValue': cv,
            'actualAmount': _r2(l.rate * cv),
            'actualAmount1': _r2(l.rate / cv1),
          },
      ],
    };
  }

  static Option? _find(Map<String, dynamic> m, String key, List<Option> list, String name) {
    final id = JsonRead.integer(JsonRead.field(m, key));
    if (id <= 0) return null;
    for (final o in list) {
      if (o.id == id) return o;
    }
    return Option(id, name.isEmpty ? '#$id' : name);
  }

  static List<PoLine> _lines(List<Map<String, dynamic>> rows, {required bool keepIds}) => [
        for (final l in rows)
          PoLine(
            id: keepIds ? JsonRead.integer(JsonRead.field(l, 'id')) : 0,
            account: JsonRead.integer(JsonRead.field(l, 'accountMasterRefId')) > 0
                ? Option(JsonRead.integer(JsonRead.field(l, 'accountMasterRefId')),
                    pick(l, const ['productName', 'productCode']),
                    sub: pick(l, const ['productCode']))
                : null,
            remarks: pick(l, const ['remarksD']),
            qty: pickNumber(l, const ['itemQty']),
            rate: pickNumber(l, const ['salesRate', 'saleRate']),
            taxPercent: pickNumber(l, const ['taxPercent']),
          ),
      ];

  /// A saved bill (`GET /api/bills/edit` Data1); its saved currency rate and term are kept, as on the web.
  factory BillDraft.fromEdit(Map<String, dynamic> m,
      {List<Option> suppliers = const [], List<Option> trucks = const [], List<Option> drivers = const []}) {
    final term = JsonRead.integer(JsonRead.field(m, 'paymentTermsRefid'));
    final cv1 = pickNumber(m, const ['currencyValue1']);
    return BillDraft(
      id: JsonRead.integer(JsonRead.field(m, 'id')),
      number: pick(m, const ['cNumberDisplay']),
      supplier: _find(m, 'supplierRefId', suppliers, ''),
      billDate: readDate(pick(m, const ['saleDate', 'sSaleDate'])),
      invoiceNo: pick(m, const ['invoiceNo']),
      invoiceDate: readDate(pick(m, const ['invoiceDate', 'sInvoiceDate'])),
      dueDate: readDate(pick(m, const ['dueDate', 'sDueDate'])),
      paymentTermId: term > 0 ? term : null,
      description: pick(m, const ['description']),
      saleType: pick(m, const ['saleType']).isEmpty ? 'CREDIT' : pick(m, const ['saleType']),
      status: pick(m, const ['billStatus']).isEmpty ? 'Completed' : pick(m, const ['billStatus']),
      truck: _find(m, 'truckRefid', trucks, ''),
      driver: _find(m, 'driverRefid', drivers, ''),
      remarks: pick(m, const ['remarks']),
      currencyValue: pickNumber(m, const ['currencyValue']),
      currencyValue1: cv1 == 0 ? 1 : cv1,
      poId: JsonRead.intOrNull(JsonRead.field(m, 'billsOrderMasterRefId')),
      lines: _lines(JsonRead.listOfMaps(JsonRead.field(m, 'billDetails')), keepIds: true),
    );
  }

  /// A new bill made from a purchase order (web `useBillOpen.ts` hydrateBill, fromBillOrder): the PO's supplier,
  /// invoice, dates, type, expense type, remarks, term, truck, driver and lines; [number] is the next bill number.
  factory BillDraft.fromPo(Map<String, dynamic> po,
      {required String number,
      List<Option> suppliers = const [],
      List<Option> trucks = const [],
      List<Option> drivers = const []}) {
    final term = JsonRead.integer(JsonRead.field(po, 'paymentTermsRefid'));
    final status = pick(po, const ['billStatus']);
    return BillDraft(
      number: number,
      supplier: _find(po, 'supplierRefId', suppliers, pick(po, const ['supplierName'])),
      billDate: readDate(pick(po, const ['saleDate', 'sSaleDate'])),
      invoiceNo: pick(po, const ['invoiceNo']),
      invoiceDate: readDate(pick(po, const ['invoiceDate', 'sInvoiceDate'])),
      dueDate: readDate(pick(po, const ['dueDate', 'sDueDate'])),
      paymentTermId: term > 0 ? term : null,
      description: pick(po, const ['description']),
      saleType: pick(po, const ['saleType']).isEmpty ? 'CREDIT' : pick(po, const ['saleType']),
      // the PO's own status words (ASSIGNED…) are not bill statuses
      status: billStatuses.contains(status) ? status : 'Completed',
      truck: _find(po, 'truckRefid', trucks, ''),
      driver: _find(po, 'driverRefid', drivers, ''),
      remarks: pick(po, const ['remarks']),
      poId: JsonRead.integer(JsonRead.field(po, 'id')),
      poNumber: pick(po, const ['cNumberDisplay']),
      lines: _lines(JsonRead.listOfMaps(JsonRead.field(po, 'billsOrderDetails')), keepIds: false),
    );
  }
}
