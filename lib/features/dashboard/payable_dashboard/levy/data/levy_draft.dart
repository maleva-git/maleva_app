import 'package:maleva/core/utils/json_read.dart';
import 'package:maleva/core/widgets/ui/formats.dart';

import '../../po/data/po_draft.dart';
import '../../records/data/payable_record.dart';

/// Enter link choices of the web form (`features/pass-entry/model/passLinkOptions.ts`); '' = not set.
const levyEnterLinks = ['IN', 'OUT'];

/// Exit link choices of the web form; '' = not set.
const levyExitLinks = ['1ST LINK', '2ND LINK'];

/// The attachment folder the web files levy documents under (`leviEntryConfig.ts`).
const levyFolder = 'LeviEntry';

/// Remarks limit of the web form and the Java `PassEntrySaveRequest`.
const levyRemarksMax = 2000;

/// A levy (levi entry) being made or changed in the app (change `payable-levy-form`): the web form's fields and rules
/// (`features/pass-entry/pages/PassEntryFormPage.tsx`) and the Java `PassEntrySaveRequest` body.
class LevyDraft {
  LevyDraft({
    this.id = 0,
    this.number = '',
    DateTime? date,
    this.truck,
    this.driver,
    this.rti,
    this.enterLink = '',
    this.exitLink = '',
    this.amount,
    this.remarks = '',
  }) : date = date ?? Fmt.today();

  int id;
  String number;
  DateTime date;
  Option? truck;
  Option? driver;
  Option? rti;

  /// IN / OUT, or '' (not set).
  String enterLink;

  /// 1ST LINK / 2ND LINK, or '' (not set).
  String exitLink;

  /// Null = not typed yet.
  double? amount;
  String remarks;

  bool get isNew => id == 0;

  /// The web's checks in order, then the server's (amount not below zero, remarks length).
  List<String> problems() => [
        if (truck == null) 'Choose the truck',
        if (driver == null) 'Choose the driver',
        if (rti == null) 'Choose the RTI number',
        if (amount == null) 'Type the amount',
        if (amount != null && amount! < 0) 'The amount cannot be below zero',
        if (remarks.trim().length > levyRemarksMax) 'Remarks can have at most $levyRemarksMax letters',
      ];

  /// The body of `POST /api/levi-entries` as the web sends it: unset values are left out.
  Map<String, dynamic> toJson({required int companyId, int? employeeId}) => {
        if (id > 0) 'id': id,
        'companyRefId': companyId,
        'truckRefId': truck?.id,
        'driverRefId': driver?.id,
        'rtiRefId': rti?.id,
        if ((employeeId ?? 0) > 0) 'employeeRefId': employeeId,
        'saleDate': Fmt.ymd(date),
        'amount': amount ?? 0,
        if (remarks.trim().isNotEmpty) 'remarks': remarks.trim(),
        if (enterLink.isNotEmpty) 'enterLink': enterLink,
        if (exitLink.isNotEmpty) 'exitLink': exitLink,
      };

  /// The listed option with the saved id, else the saved name (a truck, driver or RTI no longer listed), as the web.
  static Option? _find(Map<String, dynamic> m, String idKey, String nameKey, List<Option> list) {
    final id = JsonRead.integer(JsonRead.field(m, idKey));
    if (id <= 0) return null;
    for (final o in list) {
      if (o.id == id) return o;
    }
    final name = pick(m, [nameKey]);
    return Option(id, name.isEmpty ? '#$id' : name);
  }

  /// A saved levy (`GET /api/levi-entries/{id}` Data1, `PassEntryDetailDto`).
  factory LevyDraft.fromEdit(Map<String, dynamic> m,
      {List<Option> trucks = const [], List<Option> drivers = const [], List<Option> rtis = const []}) {
    final amount = JsonRead.field(m, 'amount');
    return LevyDraft(
      id: JsonRead.integer(JsonRead.field(m, 'id')),
      number: pick(m, const ['cNumberDisplay', 'cnumberDisplay']),
      date: readDate(JsonRead.field(m, 'saleDate')) ?? Fmt.today(),
      truck: _find(m, 'truckRefId', 'truckName', trucks),
      driver: _find(m, 'driverRefId', 'driverName', drivers),
      rti: _find(m, 'rtiRefId', 'rtiNumber', rtis),
      enterLink: pick(m, const ['enterLink']),
      exitLink: pick(m, const ['exitLink']),
      amount: amount == null || '$amount'.trim().isEmpty ? null : JsonRead.number(amount),
      remarks: pick(m, const ['remarks']),
    );
  }
}
