import 'package:flutter/material.dart';
import 'package:maleva/core/utils/json_read.dart';

/// The payable records the Records tab shows (change `payable-records`), with the upload folder the web uses for
/// each (`maleva-front-end/src/features/attachments/model/attachmentFolders.ts`).
enum RecordKind {
  po('PO', 'Purchase order', 'BillOrderMaster', Icons.shopping_cart_outlined),
  bill('Bill', 'Bill', 'BillMaster', Icons.receipt_long_outlined),
  payBill('Pay bill', 'Pay bill', 'PayBills', Icons.payments_outlined),
  voucher('Voucher', 'Payment voucher', 'PaymentVoucher', Icons.request_quote_outlined),
  pettyCash('Petty cash', 'Petty cash', 'PettyCash', Icons.account_balance_wallet_outlined),
  levy('Levy', 'Levy', 'LeviEntry', Icons.local_shipping_outlined);

  const RecordKind(this.label, this.title, this.folder, this.icon);

  final String label;
  final String title;
  final String folder;
  final IconData icon;
}

/// How a status reads: approved / completed (green), waiting (amber), rejected (red), other (blue).
enum StatusTone { done, waiting, rejected, other }

/// The status as people say it (the data keeps `ACCEPETED`; an empty status is "Pending", as on the web).
String statusLabel(String raw) {
  final s = raw.trim().toUpperCase();
  if (s.isEmpty) return 'Pending';
  if (s == 'ACCEPETED' || s == 'ACCEPTED') return 'Accepted';
  return s[0] + s.substring(1).toLowerCase();
}

StatusTone statusTone(String raw) {
  final s = raw.trim().toUpperCase();
  if (s.contains('REJECT')) return StatusTone.rejected;
  if (s == 'ACCEPETED' || s == 'ACCEPTED' || s == 'APPROVED' || s.contains('COMPLETED') || s == 'DONE' || s == 'PAID') {
    return StatusTone.done;
  }
  if (s.isEmpty || s.contains('APPROVAL') || s.contains('PENDING') || s.contains('WAITING')) return StatusTone.waiting;
  return StatusTone.other;
}

/// A date as the server sends it: `dd/MM/yyyy`, ISO `yyyy-MM-dd[THH:mm…]` or `yyyy-MM-dd HH:mm:ss`.
DateTime? readDate(dynamic value) {
  final t = JsonRead.string(value).trim();
  if (t.isEmpty) return null;
  final dmy = RegExp(r'^(\d{1,2})/(\d{1,2})/(\d{4})').firstMatch(t);
  if (dmy != null) {
    return DateTime(int.parse(dmy.group(3)!), int.parse(dmy.group(2)!), int.parse(dmy.group(1)!));
  }
  final d = DateTime.tryParse(t.replaceFirst(' ', 'T'));
  if (d == null || d.year <= 1900) return null; // '1900-01-01' is the SQL "no date"
  return d;
}

/// The first non-empty field among [keys], read without case (Jackson writes `cNumberDisplay` or `cnumberDisplay`).
String pick(Map<String, dynamic> m, List<String> keys) {
  for (final k in keys) {
    final v = JsonRead.stringOrNull(JsonRead.field(m, k))?.trim();
    if (v != null && v.isNotEmpty) return v;
  }
  return '';
}

double pickNumber(Map<String, dynamic> m, List<String> keys) {
  for (final k in keys) {
    final v = JsonRead.field(m, k);
    if (v != null && '$v'.trim().isNotEmpty) return JsonRead.number(v);
  }
  return 0;
}

/// One row of a record list.
class PayableRecord {
  const PayableRecord({
    required this.kind,
    required this.id,
    required this.number,
    required this.date,
    required this.party,
    required this.amount,
    required this.status,
    this.tag = '',
    this.description = '',
    this.lineCount = 0,
    this.head = '',
  });

  final RecordKind kind;
  final int id;
  final String number;
  final DateTime? date;

  /// Supplier, pay to, employee or truck.
  final String party;
  final double amount;

  /// The raw status text (see [statusLabel] / [statusTone]).
  final String status;

  /// A second label: PO type (MAINTENANCE, SPARE PARTS…), CASH / CREDIT, IN / OUT…
  final String tag;
  final String description;
  final int lineCount;

  /// The expense head as stored (`Description` of a voucher or pay bill), which the expense report groups by.
  final String head;

  /// Matches a search on number, party, description or tag.
  bool matches(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return [number, party, description, tag].any((t) => t.toLowerCase().contains(q));
  }
}

/// One line of a record: an item, an account, or a bill paid.
class RecordLine {
  const RecordLine({required this.title, this.subtitle = '', this.quantity, this.rate, required this.amount});

  final String title;
  final String subtitle;
  final double? quantity;
  final double? rate;
  final double amount;
}

/// A record's detail: the facts (label → value), its lines and the total.
class RecordDetail {
  const RecordDetail({required this.facts, required this.lines, required this.total, this.lineTitle = 'Lines'});

  /// In the order shown; empty values are left out by the screen.
  final List<(String, String)> facts;
  final List<RecordLine> lines;
  final double total;

  /// "Items", "Accounts", "Bills paid"…
  final String lineTitle;
}

/// One stored file of a record.
class RecordFile {
  const RecordFile({required this.name, required this.path, required this.contentType, required this.size});

  factory RecordFile.fromJava(Map<String, dynamic> m) => RecordFile(
        name: JsonRead.string(m['fileName']),
        path: JsonRead.string(m['path']),
        contentType: JsonRead.string(m['contentType']).toLowerCase(),
        size: JsonRead.integer(m['sizeBytes']),
      );

  final String name;
  final String path;
  final String contentType;
  final int size;

  bool get isImage {
    if (contentType.startsWith('image/')) return true;
    final n = name.toLowerCase();
    return n.endsWith('.jpg') || n.endsWith('.jpeg') || n.endsWith('.png') || n.endsWith('.webp') || n.endsWith('.gif');
  }

  bool get isPdf => contentType.contains('pdf') || name.toLowerCase().endsWith('.pdf');
}
