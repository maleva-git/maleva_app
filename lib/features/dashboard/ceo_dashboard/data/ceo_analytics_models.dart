import 'package:maleva/core/utils/json_read.dart';

/// The CEO analytics dashboard's answers, read as the shared Java API sends them
/// (`/api/ceo-dashboard/analytics/*`, change `ceo-analytics-dashboard`): camelCase names, money as
/// numbers, dates `yyyy-MM-dd`. A missing field reads as 0 / empty; a missing section reads as null so
/// the screen can show that part alone as not loaded.

Map<String, dynamic>? _section(Map<String, dynamic> json, String key) {
  final v = json[key];
  return v is Map ? Map<String, dynamic>.from(v) : null;
}

Map<String, dynamic> _map(dynamic v) => JsonRead.map(v);
List<Map<String, dynamic>> _list(dynamic v) => JsonRead.listOfMaps(v);
int _i(Map<String, dynamic> m, String k) => JsonRead.integer(m[k]);
double _n(Map<String, dynamic> m, String k) => JsonRead.number(m[k]);
String _s(Map<String, dynamic> m, String k) => JsonRead.string(m[k]).trim();

/// The period the numbers are for and the one they are compared with.
class CeoPeriodRange {
  const CeoPeriodRange({this.fromDate = '', this.toDate = '', this.previousFromDate = '', this.previousToDate = ''});

  factory CeoPeriodRange.fromJava(dynamic json) {
    final m = _map(json);
    return CeoPeriodRange(
      fromDate: _s(m, 'fromDate'),
      toDate: _s(m, 'toDate'),
      previousFromDate: _s(m, 'previousFromDate'),
      previousToDate: _s(m, 'previousToDate'),
    );
  }

  final String fromDate;
  final String toDate;
  final String previousFromDate;
  final String previousToDate;
}

/// A count and an amount with the previous period's.
class CeoTotals {
  const CeoTotals({this.count = 0, this.amount = 0, this.previousCount = 0, this.previousAmount = 0});

  factory CeoTotals.fromJava(dynamic json) {
    final m = _map(json);
    return CeoTotals(
      count: _i(m, 'count'),
      amount: _n(m, 'amount'),
      previousCount: _i(m, 'previousCount'),
      previousAmount: _n(m, 'previousAmount'),
    );
  }

  final int count;
  final double amount;
  final int previousCount;
  final double previousAmount;

  /// Percent change of the amount against the previous period; null when there was nothing before.
  double? get change => percentChange(amount, previousAmount);
}

/// `(now - before) / before * 100`, or null when [before] is 0.
double? percentChange(double now, double before) => before == 0 ? null : (now - before) / before * 100;

class CeoMonth {
  const CeoMonth({
    this.month = '',
    this.label = '',
    this.saleOrderAmount = 0,
    this.saleOrderCount = 0,
    this.invoiceAmount = 0,
  });

  factory CeoMonth.fromJava(Map<String, dynamic> m) => CeoMonth(
        month: _s(m, 'month'),
        label: _s(m, 'label'),
        saleOrderAmount: _n(m, 'saleOrderAmount'),
        saleOrderCount: _i(m, 'saleOrderCount'),
        invoiceAmount: _n(m, 'invoiceAmount'),
      );

  /// `yyyy-MM`.
  final String month;

  /// `Nov 2025`.
  final String label;
  final double saleOrderAmount;
  final int saleOrderCount;
  final double invoiceAmount;

  /// `Nov`, for the chart axis.
  String get short {
    final w = (label.isEmpty ? month : label).trim().split(RegExp(r'\s+')).first;
    return w.length <= 3 ? w : w.substring(0, 3);
  }
}

/// A ranked party (customer or sales employee): id, name, jobs and amount.
class CeoRanked {
  const CeoRanked({this.id = 0, this.name = '', this.jobs = 0, this.amount = 0});

  final int id;
  final String name;
  final int jobs;
  final double amount;
}

class CeoRevenue {
  const CeoRevenue({
    this.saleOrders = const CeoTotals(),
    this.invoices = const CeoTotals(),
    this.months = const [],
    this.topCustomers = const [],
  });

  factory CeoRevenue.fromJava(Map<String, dynamic> m) => CeoRevenue(
        saleOrders: CeoTotals.fromJava(m['saleOrders']),
        invoices: CeoTotals.fromJava(m['invoices']),
        months: [for (final r in _list(m['months'])) CeoMonth.fromJava(r)],
        topCustomers: [
          for (final r in _list(m['topCustomers']))
            CeoRanked(id: _i(r, 'customerId'), name: _s(r, 'customerName'), jobs: _i(r, 'jobs'), amount: _n(r, 'amount')),
        ],
      );

  final CeoTotals saleOrders;
  final CeoTotals invoices;

  /// Oldest first, as the server sends them.
  final List<CeoMonth> months;
  final List<CeoRanked> topCustomers;
}

/// One ageing bucket: CURRENT, D1_30, D31_60, D61_90, OVER_90.
class CeoBucket {
  const CeoBucket({required this.bucket, this.amount = 0});

  final String bucket;
  final double amount;

  static const order = ['CURRENT', 'D1_30', 'D31_60', 'D61_90', 'OVER_90'];

  String get label => switch (bucket) {
        'CURRENT' => 'Current',
        'D1_30' => '1-30',
        'D31_60' => '31-60',
        'D61_90' => '61-90',
        'OVER_90' => '90+',
        _ => bucket,
      };

  /// Always the five buckets in order; one the server left out reads 0.
  static List<CeoBucket> listFromJava(dynamic json) {
    final byKey = {for (final r in _list(json)) _s(r, 'bucket').toUpperCase(): _n(r, 'amount')};
    return [for (final b in order) CeoBucket(bucket: b, amount: byKey[b] ?? 0)];
  }
}

/// One currency of the receivable: [amount] in that currency (as on the customer statement), [amountRm] at
/// today's [rate].
class CeoReceivableCurrency {
  const CeoReceivableCurrency({
    this.currency = 'RM',
    this.customers = 0,
    this.invoices = 0,
    this.amount = 0,
    this.amountRm = 0,
    this.rate = 1,
  });

  factory CeoReceivableCurrency.fromJava(Map<String, dynamic> m) => CeoReceivableCurrency(
        currency: _s(m, 'currency').isEmpty ? 'RM' : _s(m, 'currency'),
        customers: _i(m, 'customers'),
        invoices: _i(m, 'invoices'),
        amount: _n(m, 'amount'),
        amountRm: _n(m, 'amountRm'),
        rate: _n(m, 'rate') == 0 ? 1 : _n(m, 'rate'),
      );

  final String currency;
  final int customers;
  final int invoices;
  final double amount;
  final double amountRm;
  final double rate;

  bool get isForeign => currency != 'RM';
}

/// Receivable figures are RM: each customer's balance at their currency's current rate.
class CeoCash {
  const CeoCash({
    this.receivableOutstanding = 0,
    this.receivableAgeing = const [],
    this.payableOutstanding = 0,
    this.payableAgeing = const [],
    this.paidOutCount = 0,
    this.paidOutAmount = 0,
    this.receivableCurrencies = const [],
  });

  factory CeoCash.fromJava(Map<String, dynamic> m) {
    final paid = _map(m['paidOut']);
    return CeoCash(
      receivableOutstanding: _n(m, 'receivableOutstanding'),
      receivableAgeing: CeoBucket.listFromJava(m['receivableAgeing']),
      payableOutstanding: _n(m, 'payableOutstanding'),
      payableAgeing: CeoBucket.listFromJava(m['payableAgeing']),
      paidOutCount: _i(paid, 'count'),
      paidOutAmount: _n(paid, 'amount'),
      receivableCurrencies: [for (final c in _list(m['receivableCurrencies'])) CeoReceivableCurrency.fromJava(c)],
    );
  }

  final double receivableOutstanding;
  final List<CeoBucket> receivableAgeing;
  final double payableOutstanding;
  final List<CeoBucket> payableAgeing;
  final int paidOutCount;
  final double paidOutAmount;

  /// RM first, then foreign currencies by RM value.
  final List<CeoReceivableCurrency> receivableCurrencies;

  bool get hasForeignReceivable => receivableCurrencies.any((c) => c.isForeign);
}

/// A keyed group: expense category, running cost or a status. [key] is what the details call takes.
class CeoGroup {
  const CeoGroup({this.key = '', this.name = '', this.count = 0, this.amount = 0, this.previousAmount = 0});

  factory CeoGroup.fromJava(Map<String, dynamic> m) => CeoGroup(
        key: _s(m, 'key'),
        name: _s(m, 'name').isEmpty ? _s(m, 'key') : _s(m, 'name'),
        count: _i(m, 'count'),
        amount: _n(m, 'amount'),
        previousAmount: _n(m, 'previousAmount'),
      );

  final String key;
  final String name;
  final int count;
  final double amount;
  final double previousAmount;

  double? get change => percentChange(amount, previousAmount);
}

class CeoExpenses {
  const CeoExpenses({
    this.count = 0,
    this.total = 0,
    this.previousTotal = 0,
    this.categories = const [],
    this.running = const [],
  });

  factory CeoExpenses.fromJava(Map<String, dynamic> m) => CeoExpenses(
        count: _i(m, 'count'),
        total: _n(m, 'total'),
        previousTotal: _n(m, 'previousTotal'),
        categories: [for (final r in _list(m['categories'])) CeoGroup.fromJava(r)],
        running: [for (final r in _list(m['running'])) CeoGroup.fromJava(r)],
      );

  final int count;
  final double total;
  final double previousTotal;

  /// Amount desc, as the server sends them.
  final List<CeoGroup> categories;
  final List<CeoGroup> running;

  double? get change => percentChange(total, previousTotal);
}

class CeoOperations {
  const CeoOperations({
    this.saleOrderStatus = const [],
    this.jobOrderStatus = const [],
    this.openIncidents = 0,
    this.openIncidentsAmount = 0,
    this.unreleasedForwarding = 0,
    this.unreleasedK8 = 0,
    this.trucksActive = 0,
    this.trucksWorkshop = 0,
    this.trucksSold = 0,
  });

  factory CeoOperations.fromJava(Map<String, dynamic> m) {
    final ir = _map(m['openIncidents']);
    final fw = _map(m['unreleasedForwarding']);
    final trucks = _map(m['trucks']);
    return CeoOperations(
      saleOrderStatus: [for (final r in _list(m['saleOrderStatus'])) CeoGroup.fromJava(r)],
      jobOrderStatus: [for (final r in _list(m['jobOrderStatus'])) CeoGroup.fromJava(r)],
      openIncidents: _i(ir, 'count'),
      openIncidentsAmount: _n(ir, 'amount'),
      unreleasedForwarding: _i(fw, 'count'),
      unreleasedK8: _i(fw, 'k8Count'),
      trucksActive: _i(trucks, 'active'),
      trucksWorkshop: _i(trucks, 'workshop'),
      trucksSold: _i(trucks, 'sold'),
    );
  }

  final List<CeoGroup> saleOrderStatus;
  final List<CeoGroup> jobOrderStatus;
  final int openIncidents;
  final double openIncidentsAmount;
  final int unreleasedForwarding;
  final int unreleasedK8;
  final int trucksActive;
  final int trucksWorkshop;
  final int trucksSold;

  /// Open sale orders: the sum of the status counts.
  int get openJobs => saleOrderStatus.fold(0, (a, g) => a + g.count);
  int get openJobOrders => jobOrderStatus.fold(0, (a, g) => a + g.count);

  /// Unreleased forwarding numbers: the non-K8 ones plus the K8 ones.
  int get unreleasedTotal => unreleasedForwarding + unreleasedK8;
}

class CeoPeople {
  const CeoPeople({this.activeEmployees = 0, this.onLeaveToday = 0, this.topSales = const []});

  factory CeoPeople.fromJava(Map<String, dynamic> m) => CeoPeople(
        activeEmployees: _i(m, 'activeEmployees'),
        onLeaveToday: _i(m, 'onLeaveToday'),
        topSales: [
          for (final r in _list(m['topSales']))
            CeoRanked(id: _i(r, 'employeeId'), name: _s(r, 'employeeName'), jobs: _i(r, 'jobs'), amount: _n(r, 'amount')),
        ],
      );

  final int activeEmployees;
  final int onLeaveToday;
  final List<CeoRanked> topSales;
}

/// `GET /api/ceo-dashboard/analytics/overview`. A section the answer does not carry is null.
class CeoOverview {
  const CeoOverview({
    this.period = const CeoPeriodRange(),
    this.revenue,
    this.cash,
    this.expenses,
    this.operations,
    this.people,
    this.unavailable = const [],
  });

  factory CeoOverview.fromJava(dynamic json) {
    final m = _map(json);
    final revenue = _section(m, 'revenue');
    final cash = _section(m, 'cash');
    final expenses = _section(m, 'expenses');
    final operations = _section(m, 'operations');
    final people = _section(m, 'people');
    return CeoOverview(
      period: CeoPeriodRange.fromJava(m['period']),
      revenue: revenue == null ? null : CeoRevenue.fromJava(revenue),
      cash: cash == null ? null : CeoCash.fromJava(cash),
      expenses: expenses == null ? null : CeoExpenses.fromJava(expenses),
      operations: operations == null ? null : CeoOperations.fromJava(operations),
      people: people == null ? null : CeoPeople.fromJava(people),
      unavailable: [
        if (m['unavailable'] is List)
          for (final u in m['unavailable'] as List)
            if (JsonRead.stringOrNull(u) != null) JsonRead.string(u).trim(),
      ],
    );
  }

  final CeoPeriodRange period;
  final CeoRevenue? revenue;
  final CeoCash? cash;
  final CeoExpenses? expenses;
  final CeoOperations? operations;
  final CeoPeople? people;

  /// Parts whose query failed on the server (`cash.payable`, `operations.trucks`); they come as zeros.
  final List<String> unavailable;

  /// The failed parts of [section] (`cash` -> `payable`), or the section itself when named whole.
  List<String> unavailableIn(String section) => [
        for (final u in unavailable)
          if (u == section)
            section
          else if (u.startsWith('$section.'))
            u.substring(section.length + 1),
      ];
}

/// The lists behind the numbers (`details?kind=`).
abstract final class CeoDetailKind {
  static const expenseCategory = 'EXPENSE_CATEGORY';
  static const saleOrderStatus = 'SALE_ORDER_STATUS';
  static const jobOrderStatus = 'JOB_ORDER_STATUS';
  static const topCustomer = 'TOP_CUSTOMER';
  static const topSales = 'TOP_SALES';
  static const incidentsOpen = 'INCIDENTS_OPEN';
  static const leaveToday = 'LEAVE_TODAY';

  /// Every sale order of `fromDate..toDate`; `count`/`total` match the Super Admin tiles. Optional key =
  /// employee id (`0` = no employee) for only that employee's orders (update 2026-10-17).
  static const saleOrders = 'SALE_ORDERS';

  /// How many sale orders each employee opened in `fromDate..toDate` (no key), most first, max 500:
  /// id = employee id (0 = `NO EMPLOYEE`), reference = rank, subtitle = `N jobs`, amount.
  static const saleOrderEmployees = 'SALE_ORDER_EMPLOYEES';

  /// Every customer of `fromDate..toDate` ranked by amount, max 500 (no key): id = customerId,
  /// reference = rank, date null, subtitle = `N jobs`. Open one with [topCustomer] and its id.
  static const customers = 'CUSTOMERS';

  /// The 12 calendar months ending with `toDate`'s month, newest first (reads `invoice`): id = yyyyMM,
  /// reference = `yyyy-MM`, title = `Oct 2026`, subtitle = `N jobs`.
  static const saleOrderMonths = 'SALE_ORDER_MONTHS';

  /// Invoices (SaleMaster) of the period; optional key = salesperson id, optional `customer`.
  static const invoices = 'INVOICES';
  static const invoiceEmployees = 'INVOICE_EMPLOYEES';
  static const invoiceCustomers = 'INVOICE_CUSTOMERS';
  static const invoiceMonths = 'INVOICE_MONTHS';

  /// Purchase orders per supplier / truck / month, and one supplier's or truck's POs (key = id).
  static const poSuppliers = 'PO_SUPPLIERS';
  static const poTrucks = 'PO_TRUCKS';
  static const poSupplier = 'PO_SUPPLIER';
  static const poTruck = 'PO_TRUCK';
  static const poMonths = 'PO_MONTHS';

  /// The spend flow's lists: a paid part (key = part key), a check (key = check key), open purchase
  /// orders, credit bills still owing, and monthly dues not yet paid.
  static const spendPart = 'SPEND_PART';
  static const spendCheck = 'SPEND_CHECK';
  static const poOpen = 'PO_OPEN';
  static const billsOutstanding = 'BILLS_OUTSTANDING';
  static const monthlyDues = 'MONTHLY_DUES';

  /// Who owes us today (unpaid credit invoices) per customer, most first; one customer's invoices (key = id).
  static const receivableCustomers = 'RECEIVABLE_CUSTOMERS';
  static const receivableCustomer = 'RECEIVABLE_CUSTOMER';

  /// Whom we owe today (supplier credit bills and monthly dues) per party, most first; one party's bills
  /// (key = the party name).
  static const payableParties = 'PAYABLE_PARTIES';
  static const payableParty = 'PAYABLE_PARTY';

  /// Money received: the receipts (optional key = Payment By bank id, optional `customer`), and who paid
  /// (optional key = Payment By bank id).
  static const receipts = 'RECEIPTS';
  static const receiptCustomers = 'RECEIPT_CUSTOMERS';

  /// Fuel from the fuel entries (the saved PAmount): per truck, and the entries (optional key =
  /// truck id, 0 = no truck).
  static const fuelTrucks = 'FUEL_TRUCKS';
  static const fuelEntries = 'FUEL_ENTRIES';
}

/// The `invoice` filter of the sale order lists (`ALL`, `WITH`, `WITHOUT`; the Super Admin Sale Order filter).
enum CeoInvoiceFilter {
  all('ALL', 'All'),
  withInvoice('WITH', 'With invoice'),
  withoutInvoice('WITHOUT', 'Without invoice');

  const CeoInvoiceFilter(this.param, this.label);

  final String param;
  final String label;
}

class CeoDetailRow {
  const CeoDetailRow({
    this.id = 0,
    this.reference = '',
    this.date = '',
    this.title = '',
    this.subtitle = '',
    this.amount = 0,
    this.status = '',
    this.foreignAmount = '',
  });

  factory CeoDetailRow.fromJava(Map<String, dynamic> m) => CeoDetailRow(
        id: _i(m, 'id'),
        reference: _s(m, 'reference'),
        date: _s(m, 'date'),
        title: _s(m, 'title'),
        subtitle: _s(m, 'subtitle'),
        amount: _n(m, 'amount'),
        status: _s(m, 'status'),
        foreignAmount: _s(m, 'foreignAmount'),
      );

  final int id;
  final String reference;

  /// `yyyy-MM-dd`, or '' when the server sent null.
  final String date;
  final String title;
  final String subtitle;
  /// RM.
  final double amount;
  final String status;

  /// The same money in the customer's foreign currency (`SGD 300.00`), shown under the RM amount; '' for RM.
  final String foreignAmount;
}

/// `GET /api/ceo-dashboard/analytics/details`: at most 100 rows, newest first; [count] and [total] over
/// all matching rows.
class CeoDetails {
  const CeoDetails({
    this.kind = '',
    this.key = '',
    this.title = '',
    this.count = 0,
    this.total = 0,
    this.truncated = false,
    this.rows = const [],
  });

  factory CeoDetails.fromJava(dynamic json) {
    final m = _map(json);
    return CeoDetails(
      kind: _s(m, 'kind'),
      key: _s(m, 'key'),
      title: _s(m, 'title'),
      count: _i(m, 'count'),
      total: _n(m, 'total'),
      truncated: JsonRead.boolean(m['truncated']),
      rows: [for (final r in _list(m['rows'])) CeoDetailRow.fromJava(r)],
    );
  }

  final String kind;
  final String key;
  final String title;
  final int count;
  final double total;
  final bool truncated;
  final List<CeoDetailRow> rows;
}

/// A count and an amount.
class CeoCountAmount {
  const CeoCountAmount({this.count = 0, this.amount = 0});

  factory CeoCountAmount.fromJava(dynamic json) {
    final m = _map(json);
    return CeoCountAmount(count: _i(m, 'count'), amount: _n(m, 'amount'));
  }

  final int count;
  final double amount;
}

/// Paid money: approved (COMPLETED / ACCEPTED, and cash bills) and waiting for approval.
class CeoPaidTotals {
  const CeoPaidTotals({this.count = 0, this.amount = 0, this.approved = 0, this.waiting = 0});

  factory CeoPaidTotals.fromJava(dynamic json) {
    final m = _map(json);
    return CeoPaidTotals(
        count: _i(m, 'count'), amount: _n(m, 'amount'), approved: _n(m, 'approved'), waiting: _n(m, 'waiting'));
  }

  final int count;
  final double amount;
  final double approved;
  final double waiting;
}

/// One part of the paid money. [key]: `SUPPLIER_PAYMENTS` (Payment screen), `PO_VOUCHERS` (Payment
/// Voucher for a PO), `CASH_BILLS` (cash bill, paid when billed) or `DIRECT:<category>` (a Payment
/// Voucher opened directly: salary, hire purchase, tenancy…).
class CeoSpendPart {
  const CeoSpendPart({
    this.key = '',
    this.name = '',
    this.count = 0,
    this.amount = 0,
    this.approved = 0,
    this.waiting = 0,
  });

  factory CeoSpendPart.fromJava(Map<String, dynamic> m) => CeoSpendPart(
        key: _s(m, 'key'),
        name: _s(m, 'name'),
        count: _i(m, 'count'),
        amount: _n(m, 'amount'),
        approved: _n(m, 'approved'),
        waiting: _n(m, 'waiting'),
      );

  final String key;
  final String name;
  final int count;
  final double amount;
  final double approved;
  final double waiting;

  bool get isDirect => key.toUpperCase().startsWith('DIRECT:');
}

/// Money that looks entered twice (counted once in paid): [key] `PO_PAID_TWICE`, `PO_BILLED_TWICE`,
/// `PO_VOUCHERED_TWICE`, `SAME_VOUCHER`, `BILL_OVERPAID`; [amount] = the extra money.
class CeoSpendCheck {
  const CeoSpendCheck({this.key = '', this.name = '', this.count = 0, this.amount = 0});

  factory CeoSpendCheck.fromJava(Map<String, dynamic> m) =>
      CeoSpendCheck(key: _s(m, 'key'), name: _s(m, 'name'), count: _i(m, 'count'), amount: _n(m, 'amount'));

  final String key;
  final String name;
  final int count;
  final double amount;
}

/// `GET /api/ceo-dashboard/analytics/spend`: Purchase Order → Bill → Paid out (each payment once) →
/// Still owed, and the checks (contract update 2026-10-17, "the spend flow").
class CeoSpendFlow {
  const CeoSpendFlow({
    this.period = const CeoPeriodRange(),
    this.ordered = const CeoCountAmount(),
    this.orderedOpen = const CeoCountAmount(),
    this.billed = const CeoCountAmount(),
    this.billedWithoutPo = 0,
    this.billedCash = 0,
    this.paid = const CeoPaidTotals(),
    this.paidParts = const [],
    this.paidThroughPoOrBill = 0,
    this.paidDirect = 0,
    this.owed = const CeoCountAmount(),
    this.monthlyDues = const CeoCountAmount(),
    this.checks = const [],
    this.unavailable = const [],
  });

  factory CeoSpendFlow.fromJava(dynamic json) {
    final m = _map(json);
    return CeoSpendFlow(
      period: CeoPeriodRange.fromJava(m['period']),
      ordered: CeoCountAmount.fromJava(m['ordered']),
      orderedOpen: CeoCountAmount.fromJava(m['orderedOpen']),
      billed: CeoCountAmount.fromJava(m['billed']),
      billedWithoutPo: _n(m, 'billedWithoutPo'),
      billedCash: _n(m, 'billedCash'),
      paid: CeoPaidTotals.fromJava(m['paid']),
      paidParts: [for (final p in _list(m['paidParts'])) CeoSpendPart.fromJava(p)],
      paidThroughPoOrBill: _n(m, 'paidThroughPoOrBill'),
      paidDirect: _n(m, 'paidDirect'),
      owed: CeoCountAmount.fromJava(m['owed']),
      monthlyDues: CeoCountAmount.fromJava(m['monthlyDues']),
      checks: [for (final c in _list(m['checks'])) CeoSpendCheck.fromJava(c)],
      unavailable: [
        if (m['unavailable'] is List)
          for (final u in m['unavailable'] as List)
            if (JsonRead.stringOrNull(u) != null) JsonRead.string(u).trim(),
      ],
    );
  }

  final CeoPeriodRange period;
  final CeoCountAmount ordered;
  final CeoCountAmount orderedOpen;
  final CeoCountAmount billed;
  final double billedWithoutPo;
  final double billedCash;
  final CeoPaidTotals paid;
  final List<CeoSpendPart> paidParts;
  final double paidThroughPoOrBill;
  final double paidDirect;
  final CeoCountAmount owed;
  final CeoCountAmount monthlyDues;
  final List<CeoSpendCheck> checks;
  final List<String> unavailable;

  /// Still owed today: supplier credit bills plus monthly dues.
  double get stillOwed => owed.amount + monthlyDues.amount;
}

/// One Payment By (cash, a bank account, …) of the money received.
class CeoReceivedMethod {
  const CeoReceivedMethod({this.bankId = 0, this.name = '', this.count = 0, this.amount = 0});

  factory CeoReceivedMethod.fromJava(Map<String, dynamic> m) =>
      CeoReceivedMethod(bankId: _i(m, 'bankId'), name: _s(m, 'name'), count: _i(m, 'count'), amount: _n(m, 'amount'));

  final int bankId;
  final String name;
  final int count;
  final double amount;

  bool get isCash => RegExp(r'\bCASH\b', caseSensitive: false).hasMatch(name);
}

/// One currency of the money received: [amount] in that currency (as on the receipt and the customer
/// statement), [amountRm] its RM value at the receipts' rates.
class CeoReceivedCurrency {
  const CeoReceivedCurrency({this.currency = 'RM', this.count = 0, this.amount = 0, this.amountRm = 0});

  factory CeoReceivedCurrency.fromJava(Map<String, dynamic> m) => CeoReceivedCurrency(
        currency: _s(m, 'currency').isEmpty ? 'RM' : _s(m, 'currency'),
        count: _i(m, 'count'),
        amount: _n(m, 'amount'),
        amountRm: _n(m, 'amountRm'),
      );

  final String currency;
  final int count;
  final double amount;
  final double amountRm;

  bool get isForeign => currency != 'RM';
}

class CeoReceivedDay {
  const CeoReceivedDay({this.date = '', this.count = 0, this.amount = 0});

  factory CeoReceivedDay.fromJava(Map<String, dynamic> m) =>
      CeoReceivedDay(date: _s(m, 'date'), count: _i(m, 'count'), amount: _n(m, 'amount'));

  final String date;
  final int count;
  final double amount;
}

/// `GET /api/ceo-dashboard/analytics/received`: money received from customers in the days, against the same
/// days of the month before, per Payment By and per day (every day, zeros included).
class CeoReceived {
  const CeoReceived({
    this.period = const CeoPeriodRange(),
    this.total = const CeoCountAmount(),
    this.compare = const CeoCountAmount(),
    this.compareFromDate = '',
    this.compareToDate = '',
    this.customers = 0,
    this.methods = const [],
    this.currencies = const [],
    this.days = const [],
  });

  factory CeoReceived.fromJava(dynamic json) {
    final m = _map(json);
    return CeoReceived(
      period: CeoPeriodRange.fromJava(m['period']),
      total: CeoCountAmount.fromJava(m['total']),
      compare: CeoCountAmount.fromJava(m['compare']),
      compareFromDate: _s(m, 'compareFromDate'),
      compareToDate: _s(m, 'compareToDate'),
      customers: _i(m, 'customers'),
      methods: [for (final x in _list(m['methods'])) CeoReceivedMethod.fromJava(x)],
      currencies: [for (final x in _list(m['currencies'])) CeoReceivedCurrency.fromJava(x)],
      days: [for (final x in _list(m['days'])) CeoReceivedDay.fromJava(x)],
    );
  }

  final CeoPeriodRange period;
  final CeoCountAmount total;
  final CeoCountAmount compare;
  final String compareFromDate;
  final String compareToDate;
  final int customers;
  final List<CeoReceivedMethod> methods;

  /// RM first, then foreign currencies; every other amount here is in RM.
  final List<CeoReceivedCurrency> currencies;
  final List<CeoReceivedDay> days;

  bool get hasForeign => currencies.any((c) => c.isForeign);

  /// Percent change against the same days before; null when nothing came in then.
  double? get change => percentChange(total.amount, compare.amount);
}

/// `GET /api/ceo-dashboard/analytics/fuel`: fuel from the fuel entries only. [amount] = the sum of the saved
/// PAmount, shown as it is (never recalculated).
class CeoFuel {
  const CeoFuel({
    this.period = const CeoPeriodRange(),
    this.entries = 0,
    this.amount = 0,
    this.trucks = 0,
    this.previousEntries = 0,
    this.previousAmount = 0,
  });

  factory CeoFuel.fromJava(dynamic json) {
    final m = _map(json);
    return CeoFuel(
      period: CeoPeriodRange.fromJava(m['period']),
      entries: _i(m, 'entries'),
      amount: _n(m, 'amount'),
      trucks: _i(m, 'trucks'),
      previousEntries: _i(m, 'previousEntries'),
      previousAmount: _n(m, 'previousAmount'),
    );
  }

  final CeoPeriodRange period;
  final int entries;
  final double amount;
  final int trucks;
  final int previousEntries;
  final double previousAmount;

  double? get change => percentChange(amount, previousAmount);
}
