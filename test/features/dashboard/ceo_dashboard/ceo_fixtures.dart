/// Sample answers in the shape of `maleva-backend/openspec/changes/ceo-analytics-dashboard/contract.md`.
/// Made-up numbers and names; no production data.
library;

Map<String, dynamic> overviewJson() => {
      'period': {
        'fromDate': '2026-10-01',
        'toDate': '2026-10-16',
        'previousFromDate': '2026-09-15',
        'previousToDate': '2026-09-30',
      },
      'revenue': {
        'saleOrders': {'count': 412, 'amount': 98450.00, 'previousCount': 380, 'previousAmount': 90100.00},
        'invoices': {'count': 205, 'amount': 55000.00, 'previousCount': 190, 'previousAmount': 51000.00},
        'months': [
          for (var i = 0; i < 12; i++)
            {
              'month': i < 2 ? '2025-${11 + i}' : '2026-${(i - 1).toString().padLeft(2, '0')}',
              'label': '${['Nov', 'Dec', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct'][i]} ${i < 2 ? 2025 : 2026}',
              'saleOrderAmount': 50000.0 + i * 4000,
              'saleOrderCount': 200 + i * 10,
              'invoiceAmount': 30000.0 + i * 2000,
            },
        ],
        'topCustomers': [
          {'customerId': 12, 'customerName': 'ACME SHIPPING', 'jobs': 30, 'amount': 12000.00},
          {'customerId': 13, 'customerName': 'BETA MARINE', 'jobs': 22, 'amount': 9000.00},
        ],
      },
      'cash': {
        'receivableOutstanding': 250000.00,
        'receivableAgeing': [
          {'bucket': 'CURRENT', 'amount': 100000},
          {'bucket': 'D1_30', 'amount': 60000},
          {'bucket': 'D31_60', 'amount': 40000},
          {'bucket': 'D61_90', 'amount': 30000},
          {'bucket': 'OVER_90', 'amount': 20000},
        ],
        'payableOutstanding': 80000.00,
        'payableAgeing': [
          {'bucket': 'CURRENT', 'amount': 50000},
          {'bucket': 'D1_30', 'amount': 30000},
        ],
        'paidOut': {'count': 120, 'amount': 64000.00},
        'receivableCurrencies': [
          {'currency': 'RM', 'customers': 40, 'invoices': 90, 'amount': 215500, 'amountRm': 215500, 'rate': 1},
          {'currency': 'SGD', 'customers': 2, 'invoices': 3, 'amount': 10000, 'amountRm': 34500, 'rate': 3.45},
        ],
      },
      'expenses': {
        'count': 140,
        'total': 72000.00,
        'previousTotal': 69000.00,
        'categories': [
          {'key': 'REPAIR', 'name': 'REPAIR', 'count': 40, 'amount': 30000.00, 'previousAmount': 25000.00},
          {'key': 'FUEL', 'name': 'FUEL', 'count': 5, 'amount': 4200.00, 'previousAmount': 3900.00},
          {'key': 'OTHER', 'name': 'OTHER', 'count': 95, 'amount': 37800.00, 'previousAmount': 40100.00},
        ],
        'running': [
          {'key': 'FUEL', 'name': 'Fuel entries', 'count': 88, 'amount': 15000.00},
          {'key': 'TOLL', 'name': 'Toll', 'count': 0, 'amount': 0},
          {'key': 'LEVI', 'name': 'Levi', 'count': 0, 'amount': 0},
          {'key': 'AUTOPASS', 'name': 'Auto pass', 'count': 0, 'amount': 0},
        ],
      },
      'operations': {
        'saleOrderStatus': [
          {'key': '6', 'name': 'IN PROGRESS', 'count': 52},
          {'key': '2', 'name': 'BOOKED', 'count': 18},
        ],
        'jobOrderStatus': [
          {'key': '1', 'name': 'New', 'count': 9},
        ],
        'openIncidents': {'count': 5, 'amount': 3200.00},
        'unreleasedForwarding': {'count': 14, 'k8Count': 3},
        'trucks': {'active': 31, 'workshop': 3, 'sold': 2},
      },
      'people': {
        'activeEmployees': 86,
        'onLeaveToday': 4,
        'topSales': [
          {'employeeId': 7, 'employeeName': 'ALI', 'jobs': 40, 'amount': 20000.00},
        ],
      },
      'unavailable': <String>[],
    };

Map<String, dynamic> fuelDetailsJson({int rows = 5, int count = 5, bool truncated = false}) => {
      'kind': 'EXPENSE_CATEGORY',
      'key': 'FUEL',
      'title': 'FUEL purchase orders',
      'count': count,
      'total': 4200.00,
      'truncated': truncated,
      'rows': [
        for (var i = 0; i < rows; i++)
          {
            'id': 991 + i,
            'reference': 'PO00000123$i',
            'date': '2026-10-1$i',
            'title': 'PETRONAS DAGANGAN',
            'subtitle': 'WXY 123$i · INV-77$i',
            'amount': 840.00,
            'status': i == 0 ? 'PAYMENT COMPLETED' : 'Pending',
          },
      ],
    };

/// `SALE_ORDERS` for one period: [count] orders, [rows] of them listed.
Map<String, dynamic> saleOrdersJson({int count = 3, int rows = 3, double total = 1500}) => {
      'kind': 'SALE_ORDERS',
      'key': '',
      'title': 'Sale orders, 16 Oct 2026',
      'count': count,
      'total': total,
      'truncated': count > rows,
      'rows': [
        for (var i = 0; i < rows; i++)
          {
            'id': 500 + i,
            'reference': 'SO2026100$i',
            'date': '2026-10-16',
            'title': 'GAMMA LOGISTICS',
            'subtitle': 'ALI · MV OCEAN $i · PORT KLANG',
            'amount': 500.00,
            'status': 'IN PROGRESS',
          },
      ],
    };

/// `CUSTOMERS`: [rows] customers ranked by amount (date null, reference = rank).
Map<String, dynamic> customersJson({int rows = 3, String title = 'Customers, 1 Oct 2026 – 16 Oct 2026'}) => {
      'kind': 'CUSTOMERS',
      'key': '',
      'title': title,
      'count': rows,
      'total': rows * 1000.0,
      'truncated': false,
      'rows': [
        for (var i = 0; i < rows; i++)
          {
            'id': 100 + i,
            'reference': '${i + 1}',
            'date': null,
            'title': 'CUSTOMER ${i + 1}',
            'subtitle': '${30 - i} jobs',
            'amount': 2000.0 - i * 10,
            'status': '',
          },
      ],
    };

/// `SALE_ORDER_EMPLOYEES`: how many sale orders each employee opened, most first; id 0 = no employee.
Map<String, dynamic> saleOrderEmployeesJson() => {
      'kind': 'SALE_ORDER_EMPLOYEES',
      'key': '',
      'title': 'Sale orders by employee, 16 Oct 2026',
      'count': 3,
      'total': 1500.00,
      'truncated': false,
      'rows': [
        {'id': 7, 'reference': '1', 'date': null, 'title': 'ALI', 'subtitle': '40 jobs', 'amount': 900.00, 'status': ''},
        {'id': 9, 'reference': '2', 'date': null, 'title': 'SITI', 'subtitle': '20 jobs', 'amount': 400.00, 'status': ''},
        {'id': 0, 'reference': '3', 'date': null, 'title': 'NO EMPLOYEE', 'subtitle': '6 jobs', 'amount': 200.00, 'status': ''},
      ],
    };

/// A breakdown list (employees / customers / suppliers / trucks / months): id, rank, title, `N <noun>`.
Map<String, dynamic> breakdownJson(String kind, List<(int, String, int, double)> rows, {String noun = 'jobs'}) => {
      'kind': kind,
      'key': '',
      'title': kind,
      'count': rows.length,
      'total': rows.fold<double>(0, (a, r) => a + r.$4),
      'truncated': false,
      'rows': [
        for (var i = 0; i < rows.length; i++)
          {
            'id': rows[i].$1,
            'reference': '${i + 1}',
            'date': null,
            'title': rows[i].$2,
            'subtitle': '${rows[i].$3} $noun',
            'amount': rows[i].$4,
            'status': '',
          },
      ],
    };

/// `/spend`: a PO paid twice, a direct hire purchase voucher and monthly dues.
Map<String, dynamic> spendJson() => {
      'period': {'fromDate': '2026-10-01', 'toDate': '2026-10-16'},
      'ordered': {'count': 10, 'amount': 5000},
      'orderedOpen': {'count': 2, 'amount': 800},
      'billed': {'count': 8, 'amount': 4500},
      'billedWithoutPo': 300,
      'billedCash': 700,
      'paid': {'count': 11, 'amount': 12700, 'approved': 1700, 'waiting': 11000},
      'paidParts': [
        {'key': 'SUPPLIER_PAYMENTS', 'name': 'Payment (pay bill)', 'count': 3, 'amount': 2500, 'approved': 1000, 'waiting': 1500},
        {'key': 'PO_VOUCHERS', 'name': 'Payment Voucher for a PO', 'count': 1, 'amount': 500, 'approved': 0, 'waiting': 500},
        {'key': 'CASH_BILLS', 'name': 'Cash bill (paid when billed)', 'count': 2, 'amount': 700, 'approved': 700, 'waiting': 0},
        {'key': 'DIRECT:HIRE PURCHASE', 'name': 'HIRE PURCHASE', 'count': 5, 'amount': 9000, 'approved': 0, 'waiting': 9000},
      ],
      'paidThroughPoOrBill': 3700,
      'paidDirect': 9000,
      'owed': {'count': 3, 'amount': 1200},
      'monthlyDues': {'count': 2, 'amount': 3000},
      'checks': [
        {'key': 'PO_PAID_TWICE', 'name': 'PO paid by Payment and by Payment Voucher', 'count': 1, 'amount': 250},
      ],
      'unavailable': [],
    };

/// `/received`: 1–3 Oct against 1–3 Sep, two Payment By, a quiet day.
Map<String, dynamic> receivedJson() => {
      'period': {'fromDate': '2026-10-01', 'toDate': '2026-10-03'},
      'total': {'count': 6, 'amount': 15000},
      'compare': {'count': 4, 'amount': 10000},
      'compareFromDate': '2026-09-01',
      'compareToDate': '2026-09-03',
      'customers': 3,
      'methods': [
        {'bankId': 3, 'name': 'MAYBANK CURRENT', 'count': 4, 'amount': 12000},
        {'bankId': 1, 'name': 'CASH', 'count': 2, 'amount': 3000},
      ],
      'currencies': [
        {'currency': 'RM', 'count': 5, 'amount': 11550, 'amountRm': 11550},
        {'currency': 'SGD', 'count': 1, 'amount': 1000, 'amountRm': 3450},
      ],
      'days': [
        {'date': '2026-10-01', 'count': 2, 'amount': 5000},
        {'date': '2026-10-02', 'count': 0, 'amount': 0},
        {'date': '2026-10-03', 'count': 4, 'amount': 10000},
      ],
    };
