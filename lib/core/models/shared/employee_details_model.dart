
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
      });

  // Named constructor: from JSON
  EmployeeDetailsModel.fromJson(Map<String, dynamic> json)
      : Id = int.tryParse(json['Id'].toString()) ?? 0,
        EmployeeName = json['EmployeeName']?.toString() ?? '',
        Employeecurrency = json['Employeecurrency']?.toString() ?? '',
        EmployeeType = json['EmployeeType']?.toString() ?? '',
        Address1 = json['Address1']?.toString() ?? '',
        Address2 = json['Address2']?.toString() ?? '',
        City = json['City']?.toString() ?? '',
        State = json['State']?.toString() ?? '',
        Zipcode = json['Zipcode']?.toString() ?? '',
        Country = json['Country']?.toString() ?? '',
        GSTNO = json['GSTNO']?.toString() ?? '',
        Email = json['Email']?.toString() ?? '',
        MobileNo = json['MobileNo']?.toString() ?? '',
        EmergencyNo = json['EmergencyNo']?.toString() ?? '',
        UserName = json['UserName']?.toString() ?? '',
        JoiningDate = json['JoiningDate']?.toString() ?? '',
        LeavingDate = json['LeavingDate']?.toString() ?? '',
        Password = json['Password']?.toString() ?? '',
        RulesType = json['RulesType']?.toString() ?? '',
        Latitude = json['Latitude']?.toString() ?? '',
        longitude = json['longitude']?.toString() ?? '',
        BankName = json['BankName']?.toString() ?? '',
        AccountNo = json['AccountNo']?.toString() ?? '',
        AccountCode = json['AccountCode']?.toString() ?? '',
        Active = int.tryParse(json['Active']?.toString() ?? '1') ?? 1;

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'Id': Id,
      'EmployeeName': EmployeeName,
      'Employeecurrency': Employeecurrency,
      'EmployeeType': EmployeeType,
      'Address1': Address1,
      'Address2': Address2,
      'City': City,
      'State': State,
      'Zipcode': Zipcode,
      'Country': Country,
      'GSTNO': GSTNO,
      'Email': Email,
      'MobileNo': MobileNo,
      'EmergencyNo': EmergencyNo,
      'UserName': UserName,
      'JoiningDate': JoiningDate,
      'LeavingDate': LeavingDate,
      'Password': Password,
      'RulesType': RulesType,
      'Latitude': Latitude,
      'longitude': longitude,
      'BankName': BankName,
      'AccountNo': AccountNo,
      'AccountCode': AccountCode,
      'Active': Active,
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
        Active = 1;
}