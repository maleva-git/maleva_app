import 'package:maleva/core/utils/json_read.dart';


class EmployeeDetailsModel {
  int Id;
  String EmployeeName;
  String Employeecurrency;
  String EmployeeType;
  String Address1;
  String Address2;
  String City;
  String State;
  String Zipcode;
  String Country;
  String GSTNO;
  String Email;
  String MobileNo;
  String EmergencyNo;
  String UserName;
  String JoiningDate;
  String LeavingDate;
  String Password;
  String RulesType;
  String Latitude;
  String longitude; // Fixed: was duplicated
  String BankName;
  String AccountNo;
  String AccountCode;
  int Active;
  /// The employee's role (`UserRoles` id, e.g. 200 ADMIN); 0 = not chosen yet.
  int RoleId;

  // Constructor
  EmployeeDetailsModel(
      this.Id,
      this.EmployeeName,
      this.Employeecurrency,
      this.EmployeeType, {
        this.Address1 = "",
        this.Address2 = "",
        this.City = "",
        this.State = "",
        this.Zipcode = "",
        this.Country = "",
        this.GSTNO = "",
        this.Email = "",
        this.MobileNo = "",
        this.EmergencyNo = "",
        this.UserName = "",
        this.JoiningDate = "",
        this.LeavingDate = "",
        this.Password = "",
        this.RulesType = "",
        this.Latitude = "",
        this.longitude = "",
        this.BankName = "",
        this.AccountNo = "",
        this.AccountCode = "",
        this.Active = 1,
        this.RoleId = 0,
      });

  /// An employee of the shared Java list (`/api/employees/search`). Passwords
  /// are never sent, so [Password] starts blank (blank on save = keep it).
  EmployeeDetailsModel.fromJava(Map<String, dynamic> json)
      : Id = JsonRead.integer(json['id']),
        EmployeeName = _text(json, 'employeeName'),
        Employeecurrency = _text(json, 'employeecurrency'),
        EmployeeType = _text(json, 'employeeType'),
        Address1 = _text(json, 'address1'),
        Address2 = _text(json, 'address2'),
        City = _text(json, 'city'),
        State = _text(json, 'state'),
        Zipcode = _text(json, 'zipcode'),
        Country = _text(json, 'country'),
        GSTNO = _text(json, 'gstNo'),
        Email = _text(json, 'email'),
        MobileNo = _text(json, 'mobileNo'),
        EmergencyNo = _text(json, 'emergencyNo'),
        UserName = _text(json, 'userName'),
        JoiningDate = _date(json, 'joiningDate'),
        LeavingDate = _date(json, 'leavingDate'),
        Password = '',
        RulesType = _text(json, 'rulesType'),
        Latitude = _text(json, 'latitude'),
        longitude = _text(json, 'longitude'),
        BankName = _text(json, 'bankName'),
        AccountNo = _text(json, 'accountNo'),
        AccountCode = _text(json, 'accountCode'),
        Active = JsonRead.integer(JsonRead.field(json, 'active'), fallback: 1),
        RoleId = JsonRead.integer(JsonRead.field(json, 'roleId'));

  static String _text(Map<String, dynamic> json, String key) => JsonRead.string(JsonRead.field(json, key));

  /// A Java date (`2026-10-04`) as the form keeps it, `yyyy-MM-dd`.
  static String _date(Map<String, dynamic> json, String key) {
    final text = _text(json, key);
    return text.length >= 10 ? text.substring(0, 10) : text;
  }

  /// The Java save row (`EmployeeMasterDto`). The account code is the
  /// employee's ledger code, read only; capabilities are not sent, so the
  /// server leaves them as they are.
  Map<String, dynamic> toJava() {
    String? orNull(String v) => v.trim().isEmpty ? null : v.trim();
    return {
      'id': Id,
      'employeeName': EmployeeName.trim(),
      'employeecurrency': orNull(Employeecurrency),
      'employeeType': orNull(EmployeeType),
      'address1': orNull(Address1),
      'address2': orNull(Address2),
      'city': orNull(City),
      'state': orNull(State),
      'zipcode': orNull(Zipcode),
      'country': orNull(Country),
      'gstNo': orNull(GSTNO),
      'email': orNull(Email),
      'mobileNo': orNull(MobileNo),
      'emergencyNo': orNull(EmergencyNo),
      'userName': orNull(UserName),
      'joiningDate': orNull(JoiningDate),
      'leavingDate': orNull(LeavingDate),
      'password': Password,
      'rulesType': orNull(RulesType),
      'latitude': orNull(Latitude),
      'longitude': orNull(longitude),
      'bankName': orNull(BankName),
      'accountNo': orNull(AccountNo),
      'active': Active,
      'roleId': RoleId == 0 ? null : RoleId,
    };
  }

  // Empty constructor
  EmployeeDetailsModel.Empty()
      : Id = 0,
        EmployeeName = "",
        Employeecurrency = "",
        EmployeeType = "",
        Address1 = "",
        Address2 = "",
        City = "",
        State = "",
        Zipcode = "",
        Country = "",
        GSTNO = "",
        Email = "",
        MobileNo = "",
        EmergencyNo = "",
        UserName = "",
        JoiningDate = "",
        LeavingDate = "",
        Password = "",
        RulesType = "",
        Latitude = "",
        longitude = "",
        BankName = "",
        AccountNo = "",
        AccountCode = "",
        Active = 1,
        RoleId = 0;
}