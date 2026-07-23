
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

  factory LicenseViewModel.fromJson(Map<String, dynamic> json) {
    return LicenseViewModel(
      // Old fields — mapped from API
      json['DriverName'] ?? "",       // LicenseName
      json['AccountCode'] ?? "",      // Category
      json['licenseExp'] ?? "",       // ExpiryDate
      json['JoiningDate'] ?? "",      // LDate
      json['Active'] ?? 0,
      // New fields
      Id: json['Id'] ?? 0,
      DriverName: json['DriverName'] ?? "",
      licenseNo: json['licenseNo'] ?? "",
      licenseExp: json['licenseExp']?.toString(),
      AccountCode: json['AccountCode'] ?? "",
      JoiningDate: json['JoiningDate']?.toString(),
      GDLNo: json['GDLNo']?.toString(),
      GDLExp: json['GDLExp']?.toString(),
      MobileNo: json['MobileNo'] ?? "",
      Email: json['Email'] ?? "",
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