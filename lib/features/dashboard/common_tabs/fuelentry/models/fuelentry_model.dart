import 'package:intl/intl.dart';
import 'package:maleva/core/utils/json_read.dart';
import '../../../../../core/utils/app_preferences.dart';

class FuelEntryModel {
  int id;
  String entryNo;
  String entryDate;
  int truckId;
  String truckName;
  int driverId;
  String driverName;
  String remarks;

  double aLiter;
  double aAmount;

  double pLiter;
  double pRate;
  double pAmount;

  double gLiter;
  double gAmount;

  double dpLiter;
  double dpAmount;
  double dgLiter;
  double dgAmount;

  int comid;

  /// The fuel card used (null = not sent, kept on the server; '' = no card). db/fleet/fl-01.
  String? cardCode;

  /// Engine on while filling (null = not sent, kept on the server).
  bool? engineOn;

  /// The receipt photo(s) on the server (`/Upload/...`, comma separated); '' = none. Read only: never sent, the
  /// server keeps it on an edit and the upload writes it.
  String filePath;

  /// Where the entry was made: 1 = driver app (the driver may change it), else web / office (photo only).
  int fStatus;

  FuelEntryModel({
    this.id = 0,
    this.entryNo = '',
    this.entryDate = '',
    this.truckId = 0,
    this.truckName = '',
    this.driverId = 0,
    this.driverName = '',
    this.remarks = '',
    this.aLiter = 0.0,
    this.aAmount = 0.0,
    this.pLiter = 0.0,
    this.pRate = 0.0,
    this.pAmount = 0.0,
    this.gLiter = 0.0,
    this.gAmount = 0.0,
    this.dpLiter = 0.0,
    this.dpAmount = 0.0,
    this.dgLiter = 0.0,
    this.dgAmount = 0.0,
    this.comid = 0,
    this.cardCode,
    this.engineOn,
    this.filePath = '',
    this.fStatus = 0,
  });

  /// A row of the shared Java fuel list (`/api/fuel-entries`), with the web's
  /// difference columns: patron minus actual (`dp`), and the server's patron
  /// minus GPS (`diffLiter` / `diffAmount`, the `dg` columns).
  factory FuelEntryModel.fromJava(Map<String, dynamic> json) {
    dynamic f(String key) => JsonRead.field(json, key);
    double n(String key) => JsonRead.number(f(key));
    double round2(double v) => (v * 100).roundToDouble() / 100;
    final saleDate = JsonRead.date(f('saleDate'));
    final aliter = n('aliter');
    final pliter = n('pliter');
    return FuelEntryModel(
      id: JsonRead.integer(f('id')),
      entryNo: JsonRead.string(f('cNumberDisplay')),
      entryDate: saleDate == null ? '' : DateFormat('dd/MM/yyyy').format(saleDate),
      truckId: JsonRead.integer(f('truckRefId')),
      truckName: JsonRead.string(f('truckName')),
      driverId: JsonRead.integer(f('driverRefId')),
      driverName: JsonRead.string(f('driverName')),
      remarks: JsonRead.string(f('remarks')),
      aLiter: aliter,
      aAmount: n('aAmount'),
      pLiter: pliter,
      pRate: n('pRate'),
      pAmount: n('pAmount'),
      gLiter: n('gliter'),
      gAmount: n('gAmount'),
      dpLiter: round2(pliter - aliter),
      dpAmount: round2(n('pAmount') - aliter * n('pRate')),
      dgLiter: n('diffLiter'),
      dgAmount: n('diffAmount'),
      comid: JsonRead.integer(f('companyRefId')),
      cardCode: f('cardCode') as String?,
      engineOn: f('engineOn') as bool?,
      filePath: (f('filePath') ?? '').toString(),
      fStatus: JsonRead.integer(f('fStatus')),
    );
  }

  /// The Java save request. The server recomputes the patron, GPS and
  /// difference amounts from the litres and the rate, so they are not sent.
  Map<String, dynamic> toJava() {
    final empRefId = AppPreferences.getEmpRefId();
    return {
      'id': id,
      'truckRefId': truckId == 0 ? null : truckId,
      'driverRefId': driverId == 0 ? null : driverId,
      'employeeRefId': empRefId == 0 ? null : empRefId,
      'saleDate': _isoDate(entryDate),
      'aliter': aLiter,
      'aAmount': aAmount,
      'pliter': pLiter,
      'gliter': gLiter,
      'pRate': pRate,
      'remarks': remarks,
      'fStatus': 0,
      if (cardCode != null) 'cardCode': cardCode,
      if (engineOn != null) 'engineOn': engineOn,
    };
  }

  /// `dd/MM/yyyy` (as the form shows it) or an ISO date, as `yyyy-MM-dd`.
  static String? _isoDate(String value) {
    final text = value.trim();
    if (text.isEmpty) return null;
    final parts = text.split('/');
    if (parts.length == 3) {
      return '${parts[2].padLeft(4, '0')}-${parts[1].padLeft(2, '0')}-${parts[0].padLeft(2, '0')}';
    }
    return text.length >= 10 ? text.substring(0, 10) : text;
  }
}
