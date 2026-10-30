import 'package:maleva/core/utils/json_read.dart';
import 'package:maleva/core/widgets/ui/formats.dart';

import '../../records/data/payable_record.dart';

/// A choice in a list (supplier, account, term, truck…): id and the name people see.
class Option {
  const Option(this.id, this.name, {this.sub = '', this.extra = 0});

  final int id;
  final String name;

  /// A second line (account code, parent…).
  final String sub;

  /// Supplier: its default payment term id. GL account: its classification id.
  final int extra;

  @override
  bool operator ==(Object other) => other is Option && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// The PO statuses of the web form (`maleva-front-end/src/features/purchaseOrder/model/constants.ts`).
const poStatuses = ['ASSIGNED', 'RECEIPT RECEIVED', 'RECEIPT UPLOADED', 'INVOICE MADE', 'PAYMENT COMPLETED', 'Cancel'];

/// The expense types offered when the company has none saved yet (web `constants.ts`).
const poDefaultDescriptions = ['BREAKDOWN', 'REPAIR', 'SERVICE', 'SPARE PARTS'];

double _r2(double v) => (v * 100).roundToDouble() / 100;

/// One PO line: a GL account (the web calls it "product"), what it is for, qty × rate + tax.
class PoLine {
  PoLine({
    this.id = 0,
    this.account,
    this.remarks = '',
    this.serialNo = '',
    this.qty = 1,
    this.rate = 0,
    this.taxPercent = 0,
    this.inventoryProductId,
    this.quoteValue = 0,
  });

  /// 0 for a new line; the saved id keeps the line on an edit (the server deletes saved lines missing from the list).
  int id;
  Option? account;
  String remarks;
  String serialNo;
  double qty;
  double rate;
  double taxPercent;
  int? inventoryProductId;
  double quoteValue;

  /// The web's formula (`utils/purchaseOrderForm.ts`): tax = qty × rate × tax% ÷ 100; amount = qty × rate + tax.
  double get taxAmount => _r2(qty * rate * taxPercent / 100);
  double get amount => _r2(qty * rate + taxAmount);

  PoLine copy() => PoLine(
      id: id,
      account: account,
      remarks: remarks,
      serialNo: serialNo,
      qty: qty,
      rate: rate,
      taxPercent: taxPercent,
      inventoryProductId: inventoryProductId,
      quoteValue: quoteValue);

  Map<String, dynamic> toJson() => {
        'id': id,
        'accountMasterRefId': account?.id ?? 0,
        'productRefId': account?.id ?? 0,
        'inventoryProductRefId': (inventoryProductId ?? 0) > 0 ? inventoryProductId : null,
        'itemQty': qty,
        'salesRate': rate,
        'taxPercent': taxPercent,
        'taxAmount': taxAmount,
        'amount': amount,
        'mrp': 0,
        'purchaseRate': 0,
        'discPer': 0,
        'discAmount': 0,
        'landingCost': 0,
        'netSalesRate': 0,
        'remarksD': remarks.trim(),
        'serialNo': serialNo.trim(),
        'quoteValue': quoteValue,
        'currencyValue': 0,
        'actualAmount': 0,
      };
}

/// The purchase order being made or changed in the app (change `payable-po-create`): the web form's fields and rules.
class PoDraft {
  PoDraft({
    this.id = 0,
    this.number = '',
    this.supplier,
    DateTime? poDate,
    this.invoiceNo = '',
    DateTime? invoiceDate,
    this.dueDate,
    this.paymentTermId,
    this.description = '',
    this.payTo = 'DIRECT PAYMENT',
    this.status = 'ASSIGNED',
    this.truck,
    this.driver,
    this.jobNo = '',
    this.saleMasterRefId,
    this.offVessel = '',
    this.loadingVessel = '',
    this.remarks = '',
    List<PoLine>? lines,
    this.fromJobOrder = false,
  })  : poDate = poDate ?? Fmt.today(),
        invoiceDate = invoiceDate ?? Fmt.today(),
        lines = lines ?? [];

  /// 0 = new.
  int id;
  String number;
  Option? supplier;
  DateTime poDate;
  String invoiceNo;
  DateTime invoiceDate;
  DateTime? dueDate;
  int? paymentTermId;
  String description;
  String payTo;
  String status;
  Option? truck;
  Option? driver;
  String jobNo;
  int? saleMasterRefId;
  String offVessel;
  String loadingVessel;
  String remarks;
  List<PoLine> lines;

  /// Raised from a workshop job order: its line links are not carried by the app, so it is edited on the web.
  final bool fromJobOrder;

  bool get isNew => id == 0;

  /// Lines with something in them (the web drops empty rows).
  List<PoLine> get filledLines =>
      lines.where((l) => l.account != null || l.amount != 0 || l.remarks.trim().isNotEmpty).toList();

  double get total => _r2(filledLines.fold(0.0, (s, l) => s + l.amount));
  double get taxTotal => _r2(filledLines.fold(0.0, (s, l) => s + l.taxAmount));

  /// The web's checks before saving, in its order (`hooks/usePurchaseOrderSave.ts`); empty = can save.
  /// [usedInvoiceNos]: the company's invoice numbers (trimmed, upper case), checked for a new PO only.
  List<String> problems({Set<String> usedInvoiceNos = const {}}) {
    final p = <String>[];
    if (supplier == null) p.add('Choose the supplier');
    if (paymentTermId == null || paymentTermId! <= 0) p.add('Choose the payment term');
    if (description.trim().isEmpty) p.add('Choose the expense type');
    if (invoiceNo.trim().isEmpty) p.add('Type the invoice number');
    final filled = filledLines;
    if (filled.isEmpty) p.add('Add at least one item');
    final noAccount = filled.where((l) => l.account == null).length;
    if (noAccount > 0) p.add('$noAccount item${noAccount == 1 ? '' : 's'} without an account');
    if (filled.any((l) => l.qty < 0 || l.rate < 0 || l.taxPercent < 0)) p.add('Amounts cannot be below zero');
    if (isNew && invoiceNo.trim().isNotEmpty && usedInvoiceNos.contains(invoiceNo.trim().toUpperCase())) {
      p.add('Invoice number ${invoiceNo.trim()} is already on another PO');
    }
    if (invoiceNo.trim().length > 100) p.add('Invoice number is too long (100 max)');
    if (description.trim().length > 50) p.add('Expense type is too long (50 max)');
    if (remarks.trim().length > 300) p.add('Remarks are too long (300 max)');
    return p;
  }

  static String? _ymd(DateTime? d) => d == null ? null : Fmt.ymd(d);

  /// The body of `POST /api/bills-order/insert`, as the web sends it (`api/purchaseOrderApi.ts` whitelist).
  Map<String, dynamic> toJson({required int companyId, required int? employeeId}) {
    final filled = filledLines;
    return {
      'id': id,
      'companyRefId': companyId,
      'userRefId': null,
      'employeeRefId': (employeeId ?? 0) > 0 ? employeeId : null,
      'supplierRefId': supplier?.id ?? 0,
      'saleDate': _ymd(poDate),
      'invoiceDate': _ymd(invoiceDate),
      'invoiceNo': invoiceNo.trim().toUpperCase(),
      'saleType': 'CREDIT',
      'cNumberDisplay': number,
      'cNumber': 0,
      'coinage': 0,
      'discountAmount': 0,
      'plusAmount': 0,
      'minusAmount': 0,
      'checkloadingVessel': 0,
      'checkoffgVessel': 0,
      'currencyValue': 0,
      'actualAmount': 0,
      'grossAmount': total,
      'amount': total,
      'taxAmount': taxTotal,
      'remarks': remarks.trim(),
      'offVessal': offVessel.trim(),
      'lodingVessal': loadingVessel.trim(),
      'pStatus': status == 'PAYMENT COMPLETED' ? 1 : 0,
      'payTo': payTo.trim().isEmpty ? 'DIRECT PAYMENT' : payTo.trim(),
      'billStatus': status,
      'truckRefid': truck?.id,
      'driverRefid': driver?.id,
      'fileupload': 0,
      'description': description.trim(),
      'dueDate': _ymd(dueDate),
      'paymentTermsRefid': paymentTermId ?? 0,
      'saleMasterRefId': saleMasterRefId,
      'jobNo': jobNo.trim(),
      'jobOrderMasterRefId': null,
      'jobOrderNo': null,
      'jobOrderDetailIds': <int>[],
      'active': 1,
      'billsOrderDetails': [for (final l in filled) l.toJson()],
    };
  }

  /// A saved PO from `GET /api/bills-order/edit-bills-order` (`data[0]`), with the names of its supplier, truck and
  /// driver found in [suppliers] / [trucks] / [drivers].
  factory PoDraft.fromEdit(Map<String, dynamic> m,
      {List<Option> suppliers = const [], List<Option> trucks = const [], List<Option> drivers = const []}) {
    Option? find(List<Option> list, String key, String fallbackName) {
      final id = JsonRead.integer(JsonRead.field(m, key));
      if (id <= 0) return null;
      for (final o in list) {
        if (o.id == id) return o;
      }
      return Option(id, fallbackName.isEmpty ? '#$id' : fallbackName);
    }

    final jobOrder = JsonRead.integer(JsonRead.field(m, 'jobOrderMasterRefId'));
    final term = JsonRead.integer(JsonRead.field(m, 'paymentTermsRefid'));
    return PoDraft(
      id: JsonRead.integer(JsonRead.field(m, 'id')),
      number: pick(m, const ['cNumberDisplay', 'billNoDisplay']),
      supplier: find(suppliers, 'supplierRefId', pick(m, const ['supplierName'])),
      poDate: readDate(pick(m, const ['saleDate', 'sSaleDate'])),
      invoiceNo: pick(m, const ['invoiceNo']),
      invoiceDate: readDate(pick(m, const ['invoiceDate', 'sInvoiceDate'])),
      dueDate: readDate(pick(m, const ['dueDate', 'sDueDate'])),
      paymentTermId: term > 0 ? term : null,
      description: pick(m, const ['description']),
      payTo: pick(m, const ['payTo']).isEmpty ? 'DIRECT PAYMENT' : pick(m, const ['payTo']),
      status: pick(m, const ['billStatus']).isEmpty ? 'ASSIGNED' : pick(m, const ['billStatus']),
      truck: find(trucks, 'truckRefid', pick(m, const ['truckName'])),
      driver: find(drivers, 'driverRefid', pick(m, const ['driverName'])),
      jobNo: pick(m, const ['jobNo']),
      saleMasterRefId: JsonRead.intOrNull(JsonRead.field(m, 'saleMasterRefId')),
      offVessel: pick(m, const ['offVessal', 'offVessel']),
      loadingVessel: pick(m, const ['lodingVessal', 'loadingVessel']),
      remarks: pick(m, const ['remarks']),
      fromJobOrder: jobOrder > 0,
      lines: [
        for (final l in JsonRead.listOfMaps(JsonRead.field(m, 'billsOrderDetails')))
          PoLine(
            id: JsonRead.integer(JsonRead.field(l, 'id')),
            account: JsonRead.integer(JsonRead.field(l, 'accountMasterRefId')) > 0
                ? Option(JsonRead.integer(JsonRead.field(l, 'accountMasterRefId')),
                    pick(l, const ['productName', 'productCode']),
                    sub: pick(l, const ['productCode']))
                : null,
            remarks: pick(l, const ['remarksD']),
            serialNo: pick(l, const ['serialNo']),
            qty: pickNumber(l, const ['itemQty']),
            rate: pickNumber(l, const ['salesRate', 'saleRate']),
            taxPercent: pickNumber(l, const ['taxPercent']),
            inventoryProductId: JsonRead.intOrNull(JsonRead.field(l, 'inventoryProductRefId')),
            quoteValue: pickNumber(l, const ['quoteValue']),
          ),
      ],
    );
  }
}
