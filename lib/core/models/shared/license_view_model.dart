import 'package:maleva/core/utils/json_read.dart';


class LicenseViewModel {
  // ── Old fields (existing) ──────────────────────────
  String LicenseName;
  String Category;
  String ExpiryDate;
  String LDate;
  int Active;

  // ── New fields (API response) ──────────────────────
  int Id;
  String DriverName;
  String licenseNo;
  String? licenseExp;
  String AccountCode;
  String? JoiningDate;
  String? GDLNo;
  String? GDLExp;
  String MobileNo;
  String Email;

  LicenseViewModel(
      this.LicenseName,
      this.Category,
      this.ExpiryDate,
      this.LDate,
      this.Active, {
        this.Id = 0,
        this.DriverName = "",
        this.licenseNo = "",
        this.licenseExp,
        this.AccountCode = "",
        this.JoiningDate,
        this.GDLNo,
        this.GDLExp,
        this.MobileNo = "",
        this.Email = "",
      });

  /// A driver of the shared Java `/api/driver-masters/search` (dates `yyyy-MM-dd`).
  factory LicenseViewModel.fromJava(Map<String, dynamic> json) {
    dynamic f(String k) => JsonRead.field(json, k);
    final name = JsonRead.string(f('driverName'));
    final account = JsonRead.string(f('accountCode'));
    final expiry = JsonRead.stringOrNull(f('licenseExp'));
    final joined = JsonRead.stringOrNull(f('joiningDate'));
    return LicenseViewModel(
      name,
      account,
      expiry ?? '',
      joined ?? '',
      JsonRead.integer(f('active')),
      Id: JsonRead.integer(f('id')),
      DriverName: name,
      licenseNo: JsonRead.string(f('licenseNo')),
      licenseExp: expiry,
      AccountCode: account,
      JoiningDate: joined,
      GDLNo: JsonRead.stringOrNull(f('gdlNo')),
      GDLExp: JsonRead.stringOrNull(f('gdlExp')),
      MobileNo: JsonRead.string(f('mobileNo')),
      Email: JsonRead.string(f('email')),
    );
  }

  Map<String, dynamic> toJson() => {
    'LicenseName': LicenseName,
    'Category': Category,
    'ExpiryDate': ExpiryDate,
    'LDate': LDate,
    'Active': Active,
    'Id': Id,
    'DriverName': DriverName,
    'licenseNo': licenseNo,
    'licenseExp': licenseExp,
    'AccountCode': AccountCode,
    'JoiningDate': JoiningDate,
    'GDLNo': GDLNo,
    'GDLExp': GDLExp,
    'MobileNo': MobileNo,
    'Email': Email,
  };

  LicenseViewModel.Empty()
      : LicenseName = "",
        Category = "",
        ExpiryDate = "",
        LDate = "",
        Active = 0,
        Id = 0,
        DriverName = "",
        licenseNo = "",
        licenseExp = null,
        AccountCode = "",
        JoiningDate = null,
        GDLNo = null,
        GDLExp = null,
        MobileNo = "",
        Email = "";
}