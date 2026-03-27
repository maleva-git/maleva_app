// ignore_for_file: non_constant_identifier_names

import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class SubscriptionKey {
  String MobileNo;
  String ShopName;
  String Email;
  String KeyType;
  String ProductKey;
  String ComputuerId;
  String TokenId;
  String Licence;
  String LicenceDate;
  String LastVerifitedDate;
  String SyncDate;
  String AmcStatus;
  String LicenceNo;
  String Trial;
  SubscriptionKey(
      this.MobileNo,
      this.ShopName,
      this.Email,
      this.KeyType,
      this.ProductKey,
      this.ComputuerId,
      this.TokenId,
      this.Licence,
      this.LicenceDate,
      this.LastVerifitedDate,
      this.SyncDate,
      this.AmcStatus,
      this.LicenceNo,
      this.Trial);
  SubscriptionKey.fromJson(Map<String, dynamic> json)
      : MobileNo = json['MobileNo'].toString(),
        ShopName = json['ShopName'].toString(),
        Email = json['Email'].toString(),
        KeyType = json['KeyType'].toString(),
        ProductKey = json['ProductKey'].toString(),
        ComputuerId = json['ComputuerId'].toString(),
        TokenId = json['TokenId'].toString(),
        Licence = json['Licence'].toString(),
        LicenceDate = json['LicenceDate'].toString(),
        LastVerifitedDate = json['LastVerifitedDate'].toString(),
        SyncDate = json['SyncDate'].toString(),
        AmcStatus = json['AmcStatus'].toString(),
        LicenceNo = json['LicenceNo'].toString(),
        Trial = json['Trial'].toString();
}
class ListItem {
  int id;
  String name;
  ListItem(
    this.id,
    this.name,
  );
}
class MaintenanceModel {
  int Id;
  int PStatus;
  String SupplierName;
  String TruckNumber;
  String DriverName;
  String SDueDate;
  double Amount;
  String Description;

  MaintenanceModel(this.Id, this.PStatus,this.SupplierName,this.TruckNumber,this.DriverName, this.SDueDate, this.Amount, this.Description);

  MaintenanceModel.fromJson(Map<String, dynamic> json)
      : Id = int.tryParse(json['Id'].toString()) ?? 0,
        PStatus = int.tryParse(json['PStatus'].toString()) ?? 0,
        SupplierName = json['SupplierName']?.toString() ?? '',
        TruckNumber = json['TruckNumber']?.toString() ?? '',
        DriverName = json['DriverName']?.toString() ?? '',
        SDueDate = json['SDueDate']?.toString() ?? '',
        Amount = double.tryParse(json['Amount']?.toString() ?? '0') ?? 0.0,
        Description = json['Description']?.toString() ?? '';

  Map<String, dynamic> toJson() {
    return {
      'Id': Id,
      'PStatus': PStatus,
      'SupplierName': SupplierName,
      'TruckNumber': TruckNumber,
      'DriverName': DriverName,
      'SDueDate': SDueDate,
      'Amount': Amount,
      'Description': Description,
    };
  }

  MaintenanceModel.Empty()
      : Id = 0,
         PStatus = 0,
        SupplierName = '',
        TruckNumber = '',
        DriverName = '',
        SDueDate = '',
        Amount = 0.0,
        Description = '';
}
class MenuMasterLoadModel {
  String FormText;
  int PageAdd;
  int PageEdit;
  int PageDelete;
  int PageView;
  MenuMasterLoadModel(this.FormText, this.PageAdd, this.PageEdit,
      this.PageDelete, this.PageView);
}
class Menureturn {
  final List<MenuMasterModel> master;
  final List<MenuMasterModel> parent;
  Menureturn(this.master, this.parent);
}
class QueryResponse {
  final bool result;
  final String message;
  QueryResponse(this.result, this.message);
}
class Review {
  final int id;
  final String shopName;
  final String? mobileNo;
  final String? googleReview;
  final String? googleMsg;
  final DateTime supportDate;
  final int empReffid;
  final String? employeeName;

  Review({
    required this.id,
    required this.shopName,
    this.mobileNo,
    this.googleReview,
    this.googleMsg,
    required this.supportDate,
    required this.empReffid,
    this.employeeName,
  });

  Review.fromJson(Map<String, dynamic> j)
      : id = j['Id'] ?? 0,
        shopName = j['ShopName'] ?? '',
        mobileNo = j['MobileNo'],
        googleReview = j['GoogleReview']?.toString(),
        googleMsg = j['GoogleMsg'],
        supportDate = DateTime.tryParse(j['RefDate'] ?? '') ?? DateTime.now(),
        empReffid = j['EmpReffid'] ?? 0,
        employeeName = j['EmployeeName'];

  Map<String, dynamic> toJson() => {
    "Id": id,
    "ShopName": shopName,
    "MobileNo": mobileNo,
    "GoogleReview": googleReview,
    "GoogleMsg": googleMsg,
    "RefDate": supportDate.toIso8601String().split('T')[0],
    "EmpReffid": empReffid,
    "EmployeeName": employeeName,
  };

  /// Empty constructor
  Review.empty()
      : id = 0,
        shopName = '',
        mobileNo = '',
        googleReview = '',
        googleMsg = '',
        supportDate = DateTime.now(),
        empReffid = 0,
        employeeName = '';
}
class EmailModel {
  final String subject;
  final String messageId;
  final String name;
  final int employeeRefId;
  final String emailId;
  final String sender;
  final DateTime receivedDate;
  final bool isUnread;
  final bool isReplied;
  final String debugInfo;
  bool isActive;

  EmailModel({
    required this.subject,
    required this.messageId,
    required this.name,
    required this.employeeRefId,
    required this.emailId,
    required this.sender,
    required this.receivedDate,
    required this.isUnread,
    required this.isReplied,
    required this.debugInfo,
    this.isActive = false,
  });

  factory EmailModel.fromJson(Map<String, dynamic> json) {
    return EmailModel(
      subject: json["Subject"] ?? "",
      messageId: json["MessageId"] ?? "",
      name: json["Name"] ?? "",
      employeeRefId: json["EmployeeRefId"] ?? 0,
      emailId: json["EmailID"] ?? "",
      sender: json["Sender"] ?? "",
      receivedDate:
      DateTime.tryParse(json["ReceivedDate"] ?? "") ?? DateTime.now(),
      isUnread: json["IsUnread"] ?? false,
      isReplied: json["IsReplied"] ?? false,
      isActive: json["isActive"] ?? false,
      debugInfo: json["DebugInfo"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
    "Subject": subject,
    "MessageId": messageId,
    "Name": name,
    "EmployeeRefId": employeeRefId,
    "EmailID": emailId,
    "Sender": sender,
    "ReceivedDate": receivedDate.toIso8601String(),
    "IsUnread": isUnread,
    "IsReplied": isReplied,
    "isActive": isActive,
    "DebugInfo": debugInfo,
  };

  EmailModel.empty()
      : subject = '',
        messageId = '',
        name = '',
        employeeRefId = 0,
        emailId = '',
        sender = '',
        receivedDate = DateTime.now(),
        isUnread = false,
        isReplied = false,
        isActive = false,
        debugInfo = '';


  /// ✅ Add this
  EmailModel copyWith({
    String? subject,
    String? messageId,
    String? name,
    int? employeeRefId,
    String? emailId,
    String? sender,
    DateTime? receivedDate,
    bool? isUnread,
    bool? isReplied,
    String? debugInfo,
    bool? isActive,
  }) {
    return EmailModel(
      subject: subject ?? this.subject,
      messageId: messageId ?? this.messageId,
      name: name ?? this.name,
      employeeRefId: employeeRefId ?? this.employeeRefId,
      emailId: emailId ?? this.emailId,
      sender: sender ?? this.sender,
      receivedDate: receivedDate ?? this.receivedDate,
      isUnread: isUnread ?? this.isUnread,
      isReplied: isReplied ?? this.isReplied,
      isActive: isActive ?? this.isActive,
      debugInfo: debugInfo ?? this.debugInfo,
    );
  }
}
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
class EmployeeModel {
  int Id;
  String AccountName;
  String Password;

  EmployeeModel(this.Id, this.AccountName, this.Password);

  EmployeeModel.fromJson(Map<String, dynamic> json)
      : Id = int.parse(json['Id'].toString()),
        AccountName = json['AccountName'].toString(),
        Password = json['Password'].toString();
  Map<String, dynamic> toJson() {
    return {
      'Id': Id,
      'AccountName': AccountName,
      'Password': Password,
    };
  }

  EmployeeModel.Empty()
      : Id = 0,
        AccountName = '',
        Password = '';
}
class ForwardingModel {
  int Id;
  int CNumber;
  String ForwardingEnterRef;
  String ForwardingEnterRef2;
  String ForwardingEnterRef3;

  ForwardingModel(this.Id, this.CNumber,this.ForwardingEnterRef, this.ForwardingEnterRef2, this.ForwardingEnterRef3);

  ForwardingModel.fromJson(Map<String, dynamic> json)
      : Id = int.parse(json['Id'].toString()),
        CNumber = int.parse(json['CNumber'].toString()),
        ForwardingEnterRef = json['ForwardingEnterRef'].toString(),
        ForwardingEnterRef2 = json['ForwardingEnterRef2'].toString(),
        ForwardingEnterRef3 = json['ForwardingEnterRef3'].toString();
  Map<String, dynamic> toJson() {
    return {
      'Id': Id,
      'CNumber': CNumber,
      'ForwardingEnterRef': ForwardingEnterRef,
      'ForwardingEnterRef2': ForwardingEnterRef2,
      'ForwardingEnterRef3': ForwardingEnterRef3,
    };
  }

  ForwardingModel.Empty()
      : Id = 0,
        CNumber = 0,
        ForwardingEnterRef = '',
        ForwardingEnterRef2 = '',
        ForwardingEnterRef3 = '';
}
class DriverDetailsModel {
  int Id;
  String DriverName;
  String licenseNo;
  String licenseExp;
  String ExpDate;

  DriverDetailsModel(this.Id, this.DriverName, this.licenseNo, this.licenseExp, this.ExpDate);

  DriverDetailsModel.fromJson(Map<String, dynamic> json)
      : Id = int.tryParse(json['Id'].toString()) ?? 0,
        DriverName = json['DriverName']?.toString() ?? '',
        licenseNo = json['licenseNo']?.toString() ?? '',
        licenseExp = json['licenseExp']?.toString() ?? '',
        ExpDate = json['ExpDate']?.toString() ?? '';

  Map<String, dynamic> toJson() {
    return {
      'Id': Id,
      'DriverName': DriverName,
      'licenseNo': licenseNo,
      'licenseExp': licenseExp,
      'ExpDate': ExpDate,
    };
  }

  DriverDetailsModel.Empty()
      : Id = 0,
        DriverName = '',
        licenseNo = '',
        licenseExp = '',
        ExpDate = '';
}
class BillOrderMaster {
  final int id;
  final String billNoDisplay;
  final String billNoDisplay1;
  final int billNo;
  final int pStatus;
  final String billDate;
  final String invoiceNo;
  final String invoiceDate;
  final String billTime;
  final String saleType;
  final String supplierName;
  final String employeeName;
  final String? cashierName;
  final String truckName;
  final String driverName;
  final String billStatus;
  final String description;
  final String? remarks;
  final double netAmt;

  BillOrderMaster({
    required this.id,
    required this.billNoDisplay,
    required this.billNoDisplay1,
    required this.billNo,
    required this.pStatus,
    required this.billDate,
    required this.invoiceNo,
    required this.invoiceDate,
    required this.billTime,
    required this.saleType,
    required this.supplierName,
    required this.employeeName,
    this.cashierName,
    required this.truckName,
    required this.driverName,
    required this.billStatus,
    required this.description,
    this.remarks,
    required this.netAmt,
  });

  factory BillOrderMaster.fromJson(Map<String, dynamic> json) {
    return BillOrderMaster(
      id: int.tryParse(json['Id']?.toString() ?? '') ?? 0,
      billNoDisplay: json['BillNoDisplay']?.toString() ?? '',
      billNoDisplay1: json['BillNoDisplay1']?.toString() ?? '',
      billNo: int.tryParse(json['BillNo']?.toString() ?? '') ?? 0,
      pStatus: int.tryParse(json['PStatus']?.toString() ?? '') ?? 0,
      billDate: json['BillDate']?.toString() ?? '',
      invoiceNo: json['InvoiceNo']?.toString() ?? '',
      invoiceDate: json['InvoiceDate']?.toString() ?? '',
      billTime: json['BillTime']?.toString() ?? '',
      saleType: json['SaleType']?.toString() ?? '',
      supplierName: json['SupplierName']?.toString() ?? '',
      employeeName: json['EmployeeName']?.toString() ?? '',
      cashierName: json['CashierName']?.toString(),
      truckName: json['TruckName']?.toString() ?? '',
      driverName: json['DriverName']?.toString() ?? '',
      billStatus: json['BillStatus']?.toString() ?? '',
      description: json['Description']?.toString() ?? '',
      remarks: json['Remarks']?.toString(),
      netAmt: double.tryParse(json['NetAmt']?.toString() ?? '') ?? 0.0,
    );
  }
}
class BillOrderDetail {
  final int id;
  final int saleRefId;
  final String productCode;
  final String productName;
  final double mrp;
  final double saleRate;
  final double taxPercent;
  final double taxAmt;
  final double discountPercent;
  final double discountAmt;
  final double itemQty;
  final double sAmount;
  final double quoteValue;
  final String? RemarksD;
  final String serialNo;

  BillOrderDetail({
    required this.id,
    required this.saleRefId,
    required this.productCode,
    required this.productName,
    required this.mrp,
    required this.saleRate,
    required this.taxPercent,
    required this.taxAmt,
    required this.discountPercent,
    required this.discountAmt,
    required this.itemQty,
    required this.sAmount,
    required this.quoteValue,
    this.RemarksD,
    required this.serialNo,
  });

  factory BillOrderDetail.fromJson(Map<String, dynamic> json) {
    return BillOrderDetail(
      id: int.tryParse(json['Id']?.toString() ?? '') ?? 0,
      saleRefId: int.tryParse(json['SaleRefId']?.toString() ?? '') ?? 0,
      productCode: json['ProductCode']?.toString() ?? '',
      productName: json['ProductName']?.toString() ?? '',
      mrp: double.tryParse(json['MRP']?.toString() ?? '') ?? 0.0,
      saleRate: double.tryParse(json['SaleRate']?.toString() ?? '') ?? 0.0,
      taxPercent: double.tryParse(json['TaxPercent']?.toString() ?? '') ?? 0.0,
      taxAmt: double.tryParse(json['TaxAmt']?.toString() ?? '') ?? 0.0,
      discountPercent: double.tryParse(json['DiscountPercent']?.toString() ?? '') ?? 0.0,
      discountAmt: double.tryParse(json['DiscountAmt']?.toString() ?? '') ?? 0.0,
      itemQty: double.tryParse(json['ItemQty']?.toString() ?? '') ?? 0.0,
      sAmount: double.tryParse(json['SAmount']?.toString() ?? '') ?? 0.0,
      quoteValue: double.tryParse(json['QuoteValue']?.toString() ?? '') ?? 0.0,
      RemarksD: json['RemarksD']?.toString(),
      serialNo: json['SerialNo']?.toString() ?? '',
    );
  }
}
class BoDetailResponse {
  final List<BillOrderMaster> masters;
  final List<BillOrderDetail> details;

  BoDetailResponse({required this.masters, required this.details});

  factory BoDetailResponse.fromJson(Map<String, dynamic> json) {
    var mastersJson = json['BillsOrderMaster'] as List? ?? [];
    var detailsJson = json['BillsOrderDetails'] as List? ?? [];

    return BoDetailResponse(
      masters: mastersJson.map((e) => BillOrderMaster.fromJson(e)).toList(),
      details: detailsJson.map((e) => BillOrderDetail.fromJson(e)).toList(),
    );
  }
}
class FuelFilling {
  int Id;
  String truckName;
  String vehicle;
  String time;
  String dtime;
  String location;
  String count;
  String filled;
  String driver ;
  FuelFilling(this.Id, this.truckName, this.vehicle, this.time,this.dtime, this.location ,this.count,this.filled,this.driver);

  FuelFilling.fromJson(Map<String, dynamic> json)
      : Id = int.tryParse(json['Id'].toString()) ?? 0,
        truckName = json['truckName']?.toString() ?? '',
        time = json['time']?.toString() ?? '',
        vehicle = json['vehicle']?.toString() ?? '',
        dtime = json['dtime']?.toString() ?? '',
        location = json['location']?.toString() ?? '',
        count = json['count']?.toString() ?? '',
        filled = json['filled']?.toString() ?? '',
        driver = json['driver']?.toString() ?? '';
  Map<String, dynamic> toJson() {
    return {
      'Id': Id,
      'truckName': truckName,
      'time': time,
      'vehicle': vehicle,
      'dtime': dtime,
      'location': location,
      'count': count,
      'filled': filled,
      'driver': driver,
    };
  }

  FuelFilling.Empty()
      : Id = 0,
        truckName = '',
        time = '',
        vehicle = '',
        dtime = '',
        location = '',
        count = '',
        filled = '',
        driver = '';
}
class EngineHoursdata {
  int Id;
  String DbeginTime;
  String DendTime;
  String TruckName;
  String beginTime;
  String endTime;
  String beginLocation;
  String endLocation;
  String totalTime;
  String inMotion;
  String idling;
  String mileage;
  String consumedbyFLSinidlerun;
  EngineHoursdata(this.Id, this.DbeginTime, this.DendTime, this.TruckName,this.beginTime, this.endTime ,this.beginLocation,this.endLocation,this.totalTime,this.inMotion,this.idling,this.mileage,this.consumedbyFLSinidlerun);

  EngineHoursdata.fromJson(Map<String, dynamic> json)
      : Id = int.tryParse(json['Id'].toString()) ?? 0,
        DbeginTime = json['DbeginTime']?.toString() ?? '',
        DendTime = json['DendTime']?.toString() ?? '',
        TruckName = json['TruckName']?.toString() ?? '',
        beginTime = json['beginTime']?.toString() ?? '',
        endTime = json['endTime']?.toString() ?? '',
        beginLocation = json['beginLocation']?.toString() ?? '',
        endLocation = json['endLocation']?.toString() ?? '',
        totalTime = json['totalTime']?.toString() ?? '',
        inMotion = json['inMotion']?.toString() ?? '',
        idling = json['idling']?.toString() ?? '',
        mileage = json['mileage']?.toString() ?? '',
        consumedbyFLSinidlerun = json['consumedbyFLSinidlerun']?.toString() ?? '';

  Map<String, dynamic> toJson() {
    return {
      'Id': Id,
      'DbeginTime': DbeginTime ,
      'DendTime': DendTime,
      'TruckName': TruckName,
      'beginTime': beginTime,
      'endTime': endTime,
      'beginLocation': beginLocation,
      'endLocation': endLocation,
      'totalTime': totalTime,
      'inMotion': inMotion,
      'idling': idling,
      'mileage': mileage,
      'consumedbyFLSinidlerun': consumedbyFLSinidlerun,
    };
  }

  EngineHoursdata.Empty()
      : Id = 0,
        DbeginTime = '',
        DendTime = '',
        TruckName = '',
        beginTime = '',
        endTime = '',
        beginLocation = '',
        endLocation = '',
        totalTime = '',
        inMotion = '',
        idling = '',
        mileage = '',
        consumedbyFLSinidlerun = '';
}
class PattycashMasterModel {
  int Id;
  int companyRefId;
  int employeeRefId;
  String? cNumberDisplay;
  String? employeeName;
  DateTime pettyCashDate;
  String? paymentStatus;
  int cNumber;
  int status;
  String? amount;
  List<PattyCashDetailsModel> pattyCashDetails;

  PattycashMasterModel({
    required this.Id,
    required this.companyRefId,
    required this.employeeRefId,
    this.cNumberDisplay,
    this.employeeName,
    required this.pettyCashDate,
    this.paymentStatus,
    required this.cNumber,
    required this.status,
    this.amount,
    required this.pattyCashDetails,
  });

  factory PattycashMasterModel.fromJson(Map<String, dynamic> json) {
    return PattycashMasterModel(
      Id: json['Id'],
      companyRefId: json['CompanyRefId'],
      employeeRefId: json['EmployeeRefId'],
      cNumberDisplay: json['CNumberDisplay'],
      employeeName: json['EmployeeName'],
      pettyCashDate: DateTime.parse(json['PettyCashDate']),
      paymentStatus: json['PaymentStatus'],
      cNumber: json['CNumber'],
      status: json['Status'],
      amount: json['Amount'],
      pattyCashDetails: json['PattyCashDetails'] != null
          ? (json['PattyCashDetails'] as List<dynamic>)
              .map((e) => PattyCashDetailsModel.fromJson(e))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
    'Id': Id,
    'CompanyRefId': companyRefId,
    'EmployeeRefId': employeeRefId,
    'CNumberDisplay': cNumberDisplay,
    'EmployeeName': employeeName,
    'PettyCashDate': pettyCashDate.toIso8601String(),
    'PaymentStatus': paymentStatus,
    'CNumber': cNumber,
    'Status': status,
    'Amount': amount,
    'PattyCashDetails':
    pattyCashDetails.map((e) => e.toJson()).toList(),
  };
}
class PattyCashDetailsModel {
  int Id;
  int sdId;
  int pettyCashMasterRefId;
  String? notes;
  String? items;
  String? amount;

  PattyCashDetailsModel({
    required this.Id,
    required this.sdId,
    required this.pettyCashMasterRefId,
    this.notes,
    this.items,
    this.amount,
  });

  factory PattyCashDetailsModel.fromJson(Map<String, dynamic> json) {
    return PattyCashDetailsModel(
      Id: json['Id'],
      sdId: json['SDId'],
      pettyCashMasterRefId: json['PettyCashMasterRefId'],
      notes: json['Notes'],
      items: json['Items'],
      amount: json['Amount'],
    );
  }

  Map<String, dynamic> toJson() => {
    'Id': Id,
    'SDId': sdId,
    'PettyCashMasterRefId': pettyCashMasterRefId,
    'Notes': notes,
    'Items': items,
    'Amount': amount,
  };
}
class PattycashView {
  List<PattycashMasterModel> pattycashMasterModel;
  List<PattyCashDetailsModel> pattyCashDetailsModel;

  PattycashView({
    required this.pattycashMasterModel,
    required this.pattyCashDetailsModel,
  });

  factory PattycashView.fromJson(Map<String, dynamic> json) {
    return PattycashView(
      pattycashMasterModel:
      (json['PattycashMasterModel'] as List<dynamic>)
          .map((e) => PattycashMasterModel.fromJson(e))
          .toList(),
      pattyCashDetailsModel:
      (json['PattyCashDetailsModel'] as List<dynamic>)
          .map((e) => PattyCashDetailsModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'PattycashMasterModel':
    pattycashMasterModel.map((e) => e.toJson()).toList(),
    'PattyCashDetailsModel':
    pattyCashDetailsModel.map((e) => e.toJson()).toList(),
  };
}
class SpeedingView {
  int Id;
  String truckName;
  String vehicle;
  String time;
  String dtime;
  String location;
  String count;
  String filled;
  String driver ;
  SpeedingView(this.Id, this.truckName, this.vehicle, this.time,this.dtime, this.location ,this.count,this.filled,this.driver);

  SpeedingView.fromJson(Map<String, dynamic> json)
      : Id = int.tryParse(json['Id'].toString()) ?? 0,
        truckName = json['truckName']?.toString() ?? '',
        time = json['time']?.toString() ?? '',
        vehicle = json['vehicle']?.toString() ?? '',
        dtime = json['dtime']?.toString() ?? '',
        location = json['location']?.toString() ?? '',
        count = json['count']?.toString() ?? '',
        filled = json['filled']?.toString() ?? '',
        driver = json['driver']?.toString() ?? '';
  Map<String, dynamic> toJson() {
    return {
      'Id': Id,
      'truckName': truckName,
      'time': time,
      'vehicle': vehicle,
      'dtime': dtime,
      'location': location,
      'count': count,
      'filled': filled,
      'driver': driver,
    };
  }

  SpeedingView.Empty()
      : Id = 0,
        truckName = '',
        time = '',
        vehicle = '',
        dtime = '',
        location = '',
        count = '',
        filled = '',
        driver = '';
}
class ForwardingSalaryModel {
  int id;
  String rtiNoDisplay;

  ForwardingSalaryModel({
    required this.id,
    required this.rtiNoDisplay,
  });

  factory ForwardingSalaryModel.fromJson(Map<String, dynamic> json) {
    return ForwardingSalaryModel(
      id: int.tryParse(json['Id'].toString()) ?? 0,
      rtiNoDisplay: json['RTINoDisplay']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'Id': id,
    'RTINoDisplay': rtiNoDisplay,
  };

  ForwardingSalaryModel.empty()
      : id = 0,
        rtiNoDisplay = '';
}
class UserLoginModel {
  int Id;
  String UserName;

  UserLoginModel(this.Id, this.UserName);

  UserLoginModel.fromJson(Map<String, dynamic> json)
      : Id = int.parse(json['Id'].toString()),
        UserName = json['UserName'].toString();
  Map<String, dynamic> toJson() {
    return {
      'Id': Id,
      'AccountName': UserName,
    };
  }
}
class CustomerModel {
  int Id;
  String AccountName;
  String Password;

  CustomerModel(this.Id, this.AccountName, this.Password);

  CustomerModel.fromJson(Map<String, dynamic> json)
      : Id = int.parse(json['Id'].toString()),
        AccountName = json['AccountName'].toString(),
        Password = json['Password'] == null ? '' : json['Password'].toString();
  Map<String, dynamic> toJson() {
    return {
      'Id': Id,
      'AccountName': AccountName,
      'Password': Password,
    };
  }

  CustomerModel.Empty()
      : Id = 0,
        AccountName = '',
        Password = '';
}
class EmployeeTypeModel {
  int Id;
  String CustomerName;

  EmployeeTypeModel(this.Id, this.CustomerName);

  EmployeeTypeModel.fromJson(Map<String, dynamic> json)
      : Id = int.tryParse(json['Id']?.toString() ?? '0') ?? 0,
        CustomerName = json['CustomerName'].toString();

  Map<String, dynamic> toJson() {
    return {
      'Id': Id,
      'CustomerName': CustomerName,
    };
  }

  EmployeeTypeModel.Empty()
      : Id = 0,
        CustomerName = '';
}
class LocationModel {
  int Id;
  int CompanyRefId;
  String Location;
  int Active;

  LocationModel(this.Id,this.CompanyRefId, this.Location, this.Active);

  LocationModel.fromJson(Map<String, dynamic> json)
      : Id = int.parse(json['Id'].toString()),
        CompanyRefId = int.parse(json['CompanyRefId'].toString()),
        Location = json['Location'].toString(),
        Active = int.parse(json['Active'].toString());
  Map<String, dynamic> toJson() {
    return {
      'Id': Id,
      'CompanyRefId': CompanyRefId,
      'Location': Location,
      'Active': Active,
    };
  }

  LocationModel.Empty()
      : Id = 0,
        CompanyRefId =0,
        Location = '',
        Active = 0;
}
class WareHouseModel {
  int Id;
  String PortName;

  WareHouseModel(this.Id,this.PortName);

  WareHouseModel.fromJson(Map<String, dynamic> json)
      : Id = int.parse(json['Id'].toString()),
        PortName = json['PortName'].toString();
        Map<String, dynamic> toJson() {
    return {
      'Id': Id,
      'PortName': PortName,
    };
  }
  WareHouseModel.Empty()
      : Id = 0,
        PortName = '';
}
class GetTruckModel {
  int Id;
  String AccountName;
  String Password;

  GetTruckModel(this.Id, this.AccountName, this.Password);

  GetTruckModel.fromJson(Map<String, dynamic> json)
      : Id = int.parse(json['Id'].toString()),
        AccountName = json['AccountName'].toString(),
        Password = json['Password'] == null ? '' : json['Password'].toString();
  Map<String, dynamic> toJson() {
    return {
      'Id': Id,
      'AccountName': AccountName,
      'Password': Password,
    };
  }
  GetTruckModel.Empty()
      : Id = 0,
        AccountName = '',
        Password = '';

}
class JobTypeDetailsModel {
  int ID;
  int JobMasterRefId;
  String Description;
  String JobName;
  String StatusName;
  int Active;
  int Mandatory;
  int Status;

  JobTypeDetailsModel(this.ID, this.JobMasterRefId, this.Description,
      this.JobName, this.StatusName, this.Active, this.Mandatory, this.Status);

  JobTypeDetailsModel.fromJson(Map<String, dynamic> json)
      : ID = int.parse(json['ID'].toString()),
        JobMasterRefId = int.parse(json['JobMasterRefId'].toString()),
        Description = json['Description'].toString(),
        JobName = json['JobName'].toString(),
        StatusName = json['StatusName'].toString(),
        Active = int.parse(json['Active'].toString()),
        Mandatory = int.parse(json['Mandatory'].toString()),
        Status = int.parse(json['Status'].toString());
  Map<String, dynamic> toJson() {
    return {
      'ID': ID,
      'JobMasterRefId': JobMasterRefId,
      'Description': Description,
      'JobName': JobName,
      'StatusName': StatusName,
      'Active': Active,
      'Mandatory': Mandatory,
      'Status': Status
    };
  }

  JobTypeDetailsModel.Empty()
      : ID = 0,
        JobMasterRefId = 0,
        Description = '',
        JobName = '',
        StatusName = '',
        Active = 0,
        Mandatory = 0,
        Status = 0;
}
class JobStatusModel {
  int Id;
  String Name;
  int DFlag;
  int Svalue;
  int Active;

  JobStatusModel(this.Id, this.Name, this.DFlag, this.Svalue, this.Active);

  JobStatusModel.fromJson(Map<String, dynamic> json)
      : Id = int.parse(json['Id'].toString()),
        Name = json['Name'].toString(),
        DFlag = int.parse(json['DFlag'].toString()),
        Svalue = int.parse(json['Svalue'].toString()),
        Active = int.parse(json['Active'].toString());
  Map<String, dynamic> toJson() {
    return {
      'Id': Id,
      'Name': Name,
      'DFlag': DFlag,
      'Svalue': Svalue,
      'Active': Active,
    };
  }

  JobStatusModel.Empty()
      : Id = 0,
        Name = '',
        DFlag = 0,
        Svalue = 0,
        Active = 0;
}
class JobTypeModel {
  int Id;
  String Name;
  int DFlag;
  int Active;

  JobTypeModel(this.Id, this.Name, this.DFlag, this.Active);

  JobTypeModel.fromJson(Map<String, dynamic> json)
      : Id = int.parse(json['Id'].toString()),
        Name = json['Name'].toString(),
        DFlag = int.parse(json['DFlag'].toString()),
        Active = int.parse(json['Active'].toString());
  Map<String, dynamic> toJson() {
    return {
      'Id': Id,
      'Name': Name,
      'DFlag': DFlag,
      'Active': Active,
    };
  }

  JobTypeModel.Empty()
      : Id = 0,
        Name = '',
        DFlag = 0,
        Active = 0;
}
class JobAllStatusModel {
  int ID;
  int JobMasterRefId;
  int Status;
  String StatusName;
  String MinStatusName;
  int MinStatus;
  int Sort;

  JobAllStatusModel(this.ID, this.JobMasterRefId, this.Status, this.StatusName,
      this.MinStatusName, this.MinStatus, this.Sort);

  JobAllStatusModel.fromJson(Map<String, dynamic> json)
      : ID = int.parse(json['ID'].toString()),
        JobMasterRefId = int.parse(json['JobMasterRefId'].toString()),
        Status = int.parse(json['Status'].toString()),
        StatusName = json['StatusName'].toString(),
        MinStatusName = json['MinStatusName'].toString(),
        MinStatus = int.parse(json['MinStatus'].toString()),
        Sort = int.parse(json['Sort'].toString());
  Map<String, dynamic> toJson() {
    return {
      'ID': ID,
      'JobMasterRefId': JobMasterRefId,
      'Status': Status,
      'StatusName': StatusName,
      'MinStatusName': MinStatusName,
      'MinStatus': MinStatus,
      'Sort': Sort,
    };
  }

  JobAllStatusModel.Empty()
      : ID = 0,
        JobMasterRefId = 0,
        Status = 0,
        StatusName = '',
        MinStatusName = '',
        MinStatus = 0,
        Sort = 0;
}
class AgentCompanyModel {
  int Id;
  String Name;
  int DFlag;
  int Active;

  AgentCompanyModel(this.Id, this.Name, this.DFlag, this.Active);

  AgentCompanyModel.fromJson(Map<String, dynamic> json)
      : Id = int.parse(json['Id'].toString()),
        Name = json['Name'].toString(),
        DFlag = int.parse(json['DFlag'].toString()),
        Active = int.parse(json['Active'].toString());
  Map<String, dynamic> toJson() {
    return {
      'Id': Id,
      'Name': Name,
      'DFlag': DFlag,
      'Active': Active,
    };
  }

  AgentCompanyModel.Empty()
      : Id = 0,
        Name = '',
        DFlag = 0,
        Active = 0;
}
class AgentModel {
  int Id;
  int CompanyRefId;
  String CNumberDisplay;
  int CNumber;
  String AgentName;
  String Address1;
  int AgentCompanyRefId;
  String Email;
  String MobileNo;
  String UserName;
  String Password;
  String TokenId;
  String SName;
  int Active;
  String Created_Date;
  String Modified_Date;
  String Modified_By;

  AgentModel(
      this.Id,
      this.CompanyRefId,
      this.CNumberDisplay,
      this.CNumber,
      this.AgentName,
      this.Address1,
      this.AgentCompanyRefId,
      this.Email,
      this.MobileNo,
      this.UserName,
      this.Password,
      this.TokenId,
      this.SName,
      this.Active,
      this.Created_Date,
      this.Modified_Date,
      this.Modified_By);

  AgentModel.fromJson(Map<String, dynamic> json)
      : Id = int.parse(json['Id'].toString()),
        CompanyRefId = int.parse(json['CompanyRefId'].toString()),
        CNumberDisplay = json['CNumberDisplay'].toString(),
        CNumber = int.parse(json['CNumber'].toString()),
        AgentName = json['AgentName'].toString(),
        Address1 = json['Address1'].toString(),
        AgentCompanyRefId = int.parse(json['AgentCompanyRefId'].toString()),
        Email = json['Email'].toString(),
        MobileNo = json['MobileNo'].toString(),
        UserName = json['UserName'].toString(),
        Password = json['Password'].toString(),
        TokenId = json['TokenId'].toString(),
        SName = json['SName'].toString(),
        Active = int.parse(json['Active'].toString()),
        Created_Date = json['Created_Date'].toString(),
        Modified_Date = json['Modified_Date'].toString(),
        Modified_By = json['Modified_By'].toString();

  Map<String, dynamic> toJson() {
    return {
      'Id': Id,
      'CompanyRefId': CompanyRefId,
      'CNumberDisplay': CNumberDisplay,
      'CNumber': CNumber,
      'AgentName': AgentName,
      'Address1': Address1,
      'AgentCompanyRefId': AgentCompanyRefId,
      'Email': Email,
      'MobileNo': MobileNo,
      'UserName': UserName,
      'Password': Password,
      'TokenId': TokenId,
      'SName': SName,
      'Active': Active,
      'Created_Date': Created_Date,
      'Modified_Date': Modified_Date,
      'Modified_By': Modified_By,
    };
  }

  AgentModel.Empty()
      : Id = 0,
        CompanyRefId = 0,
        CNumberDisplay = '',
        CNumber = 0,
        AgentName = '',
        Address1 = '',
        AgentCompanyRefId = 0,
        Email = '',
        MobileNo = '',
        UserName = '',
        Password = '',
        TokenId = '',
        SName = '',
        Active = 0,
        Created_Date = '',
        Modified_Date = '',
        Modified_By = '';
}
class ProductModel {
  String ProductName;
  String Productcode;
  String PrintName;
  double SaleRate;
  double WholeSaleRate;
  double PurRate;
  double MRP;
  double GST;
  int Id;
  int CategoryId;
  String Imagepath;

  ProductModel(
      this.ProductName,
      this.Productcode,
      this.PrintName,
      this.SaleRate,
      this.WholeSaleRate,
      this.PurRate,
      this.MRP,
      this.GST,
      this.Id,
      this.CategoryId,
      this.Imagepath);

  ProductModel.fromJson(Map<String, dynamic> json)
      : ProductName = json['ProductName'].toString(),
        Productcode = json['Productcode'].toString(),
        PrintName = json['PrintName'].toString(),
        SaleRate = double.parse(json['SaleRate'].toString()),
        WholeSaleRate = double.parse(json['WholeSaleRate'].toString()),
        PurRate = double.parse(json['PurRate'].toString()),
        MRP = double.parse(json['MRP'].toString()),
        GST = double.parse(json['GST'].toString()),
        Id = int.parse(json['Id'].toString()),
        CategoryId = int.parse(json['CategoryId'].toString()),
        Imagepath = json['Imagepath'].toString();

  Map<String, dynamic> toJson() {
    return {
      'ProductName': ProductName,
      'Productcode': Productcode,
      'PrintName': PrintName,
      'SaleRate': SaleRate,
      'WholeSaleRate': WholeSaleRate,
      'PurRate': PurRate,
      'MRP': MRP,
      'GST': GST,
      'Id': Id,
      'CategoryId': CategoryId,
      'Imagepath': Imagepath,
    };
  }

  ProductModel.Empty()
      : ProductName = '',
        Productcode = '',
        PrintName = '',
        SaleRate = 0.0,
        WholeSaleRate = 0.0,
        PurRate = 0.0,
        MRP = 0.0,
        GST = 0.0,
        Id = 0,
        CategoryId = 0,
        Imagepath = '';
}
class ProductViewModel {
  String ProductName;
  String Productcode;
  double SaleRate;
  double GST;
  int Qty;
  double Amount;
  ProductViewModel(this.ProductName, this.Productcode, this.SaleRate, this.GST,
      this.Qty, this.Amount);
  ProductViewModel.fromJson(Map<String, dynamic> json)
      : ProductName = json['ProductName'].toString(),
        Productcode = json['Productcode'].toString(),
        SaleRate = double.parse(json['SaleRate'].toString()),
        GST = double.parse(json['GST'].toString()),
        Qty = int.parse(json['Qty'].toString()),
        Amount = double.parse(json['Amount'].toString());

  Map<String, dynamic> toJson() {
    return {
      'ProductName': ProductName,
      'Productcode': Productcode,
      'SaleRate': SaleRate,
      'GST': GST,
      'Qty': Qty,
      'Amount': Amount,
    };
  }

  ProductViewModel.Empty()
      : ProductName = '',
        Productcode = '',
        SaleRate = 0.0,
        GST = 0.0,
        Qty = 0,
        Amount = 0.0;
}
class TruckDetailsModel {
  int Id;
  int flag;
  String ExpDate;
  String ExpApadBonam;
  String FromDate;
  int CompanyRefId;
  String CNumberDisplay;
  int CNumber;
  String TruckName;
  String TruckNumber;
  String TruckNumber1;
  String TruckType;
  String Latitude;
  String longitude;
  int Active;
  String Created_Date;
  String Modified_Date;
  String Modified_By;
  String RotexMyExp;
  String RotexSGExp;
  String PuspacomExp;
  String RotexMyExp1;
  String RotexSGExp1;
  String PuspacomExp1;
  String InsuratnceExp;
  String BonamExp;
  String ApadExp;
  String ServiceExp;
  String AlignmentExp;
  String GreeceExp;
  String AlignmentLast;
  String GreeceLast;
  String GearOilLast;
  String ServiceLast;
  String GearOilExp;
  String PTPStickerExp;
  String SIDExp;

  TruckDetailsModel(
      this.Id,
      this.flag,
      this.ExpDate,
      this.ExpApadBonam,
      this.FromDate,
      this.CompanyRefId,
      this.CNumberDisplay,
      this.CNumber,
      this.TruckName,
      this.TruckNumber,
      this.TruckNumber1,
      this.TruckType,
      this.Latitude,
      this.longitude,
      this.Active,
      this.Created_Date,
      this.Modified_Date,
      this.Modified_By,
      this.RotexMyExp,
      this.RotexSGExp,
      this.PuspacomExp,
      this.RotexMyExp1,
      this.RotexSGExp1,
      this.PuspacomExp1,
      this.InsuratnceExp,
      this.BonamExp,
      this.ApadExp,
      this.ServiceExp,
      this.AlignmentExp,
      this.GreeceExp,
      this.AlignmentLast,
      this.GreeceLast,
      this.GearOilLast,
      this.ServiceLast,
      this.GearOilExp,
      this.PTPStickerExp,
      this.SIDExp
      );

  TruckDetailsModel.fromJson(Map<String, dynamic> json)
      : Id = int.parse(json['Id'].toString()),
        flag = json['flag'] == null ? 0 :int.parse(json['flag'].toString()),
        ExpDate = json['ExpDate']== null ? "" :json['ExpDate'].toString(),
        ExpApadBonam = json['ExpApadBonam']== null ? "" :json['ExpApadBonam'].toString(),
        FromDate = json['FromDate'] == null ? "" : json['FromDate'].toString(),
        CompanyRefId = int.parse(json['CompanyRefId'].toString()),
        CNumberDisplay = json['CNumberDisplay'].toString(),
        CNumber = json['CNumber'] == null ? 0 : int.parse(json['CNumber'].toString()),
        TruckName = json['TruckName'] == null ? "" : json['TruckName'].toString(),
        TruckNumber = json['TruckNumber'].toString(),
        TruckNumber1 = json['TruckNumber1'].toString(),
        TruckType = json['TruckType'] == null ? "" : json['TruckType'].toString(),
        Latitude = json['Latitude'] == null ? "" : json['Latitude'].toString(),
        longitude = json['longitude'] == null ? "" : json['longitude'].toString(),
        Active = int.parse(json['Active'].toString()),
        Created_Date = json['Created_Date'].toString(),
        Modified_Date = json['Modified_Date'].toString(),
        Modified_By = json['Modified_By'] == null ? "" : json['Modified_By'].toString(),
        RotexMyExp = json['RotexMyExp'].toString(),
        RotexSGExp = json['RotexSGExp'].toString(),
        PuspacomExp = json['PuspacomExp'].toString(),
        RotexMyExp1 = json['RotexMyExp1'].toString(),
        RotexSGExp1 = json['RotexSGExp1'].toString(),
        PuspacomExp1 = json['PuspacomExp1'].toString(),
        InsuratnceExp = json['InsuratnceExp'].toString(),
        BonamExp = json['BonamExp'].toString(),
        ApadExp = json['ApadExp'].toString(),
        ServiceExp = json['ServiceExp'].toString(),
        AlignmentExp = json['AlignmentExp'].toString(),
        GreeceExp = json['GreeceExp'].toString(),
        AlignmentLast = json['AlignmentLast'].toString() ,
        GreeceLast = json['GreeceLast'].toString() ,
        GearOilLast = json['GearOilLast'].toString() ,
        ServiceLast = json['ServiceLast'].toString() ,
        GearOilExp = json['GearOilExp'].toString() ,
        PTPStickerExp = json['PTPStickerExp'].toString() ,
  SIDExp = json['SIDExp'].toString() ;


  Map<String, dynamic> toJson() {
    return {
      'Id': Id,
      'flag': flag,
      'ExpDate': ExpDate,
      'CNumber': CNumber,
      'ExpApadBonam': ExpApadBonam,
      'FromDate': FromDate,
      'CompanyRefId': CompanyRefId,
      'CNumberDisplay': CNumberDisplay,
      'CNumber': CNumber,
      'TruckName': TruckName,
      'TruckNumber': TruckNumber,
      'TruckNumber1': TruckNumber1,
      'TruckType': TruckType,
      'Latitude': Latitude,
      'longitude': longitude,
      'Active': Active,
      'Created_Date': Created_Date,
      'Modified_Date': Modified_Date,
      'Modified_By': Modified_By,
      'RotexMyExp': RotexMyExp,
      'RotexSGExp': RotexSGExp,
      'PuspacomExp': PuspacomExp,
      'RotexMyExp1': RotexMyExp1,
      'RotexSGExp1': RotexSGExp1,
      'PuspacomExp1': PuspacomExp1,
      'InsuratnceExp': InsuratnceExp,
      'BonamExp': BonamExp,
      'ApadExp': ApadExp,
      'ServiceExp': ServiceExp,
      'AlignmentExp': AlignmentExp,
      'GreeceExp': GreeceExp,
      'AlignmentLast': AlignmentLast,
      'GreeceLast': GreeceLast,
      'GearOilLast': GearOilLast,
      'ServiceLast': ServiceLast,
      'GearOilExp': GearOilExp,
      'PTPStickerExp': PTPStickerExp,
      'SIDExp': SIDExp,

    };
  }

  TruckDetailsModel.Empty()
      : Id = 0,
        flag = 0,
        ExpDate = '',
        ExpApadBonam = '',
        FromDate = '',
        CompanyRefId = 0,
        CNumberDisplay = '',
        CNumber = 0,
        TruckName = '',
        TruckNumber = '',
        TruckNumber1 = '',
        TruckType = '',
        Latitude = '',
        longitude = '',
        Active = 0,
        Created_Date = '',
        Modified_Date = '',
        Modified_By = '',
        RotexMyExp = '',
        RotexSGExp = '',
        PuspacomExp = '',
        RotexMyExp1 = '',
        RotexSGExp1 = '',
        PuspacomExp1 = '',
        InsuratnceExp = '',
        BonamExp = '',
        ApadExp = '',
        ServiceExp = '',
        AlignmentExp = '',
        GreeceExp = '',
        AlignmentLast = '',
        GreeceLast = '',
        GearOilLast = '',
        ServiceLast = '',
        GearOilExp = '',
        PTPStickerExp = '',
  SIDExp = '';
}
class PaymentPendingModel {
  final String? SubExpenseName;
  final String? ExpenseName;
  final String? InnerExpense;
  final String? DueDate;
  final String? Paiddate;
  final double Amount;
  final String Paiddamount;
  final double InnerAmount;
  final String? BankName;
  final int id;
  final int? ExpenceDueDate;

  PaymentPendingModel({
    this.SubExpenseName,
    this.ExpenseName,
    this.InnerExpense,
    this.DueDate,
    this.Paiddate,
    required this.Amount,
    required this.Paiddamount,
    required this.InnerAmount,
    this.BankName,
    required this.id,
    this.ExpenceDueDate,
  });

  factory PaymentPendingModel.fromJson(Map<String, dynamic> json) {
    return PaymentPendingModel(
      // ✅ SAFE double parse
      Amount: (json['Amount'] as num?)?.toDouble() ?? 0,
      InnerAmount: (json['InnerAmount'] as num?)?.toDouble() ?? 0,

      // ✅ ALWAYS string (even if null)
      Paiddamount: json['Paiddamount']?.toString() ?? "0",

      ExpenseName: json['ExpenseName']?.toString(),
      SubExpenseName: json['SubExpenseName']?.toString(),
      InnerExpense: json['InnerExpense']?.toString(),
      Paiddate: json['Paiddate']?.toString(),
      BankName: json['BankName']?.toString(),
      DueDate: json['DueDate']?.toString(),

      id: (json['Id'] as num?)?.toInt() ?? 0,
      ExpenceDueDate: (json['ExpenceDueDate'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Amount': Amount,
      'Paiddamount': Paiddamount,
      'InnerAmount': InnerAmount,
      'ExpenseName': ExpenseName,
      'SubExpenseName': SubExpenseName,
      'InnerExpense': InnerExpense,
      'BankName': BankName,
      'DueDate': DueDate,
      'Paiddate': Paiddate,
      'Id': id,
      'ExpenceDueDate': ExpenceDueDate,
    };
  }
}
class InventoryModel {
  final String? jobType;
  final String? offVesselName;
  final String? customerName;
  final String? loadingVesselName;
  final String? jobStatus;
  final String? cargoQTY;
  final String? cargoWeight;
  final String? employeeName;
  final String? eta;
  final String? remarks;
  final String? CNumberDisplay;
  final String? awbNo;
  final String? sourceTable;
  final String? oiDateIn;
  final String? odiDateOut;
  final int id;

  InventoryModel({
    this.jobType,
    this.offVesselName,
    this.customerName,
    this.loadingVesselName,
    this.jobStatus,
    this.cargoQTY,
    this.cargoWeight,
    this.employeeName,
    this.eta,
    this.CNumberDisplay,
    this.remarks,
    this.awbNo,
    this.sourceTable,
    this.oiDateIn,
    this.odiDateOut,
    required this.id,
  });

  factory InventoryModel.fromJson(Map<String, dynamic> json) {
    return InventoryModel(
      jobType: json['JobType']?.toString(),
      offVesselName: json['OffVesselName']?.toString(),
      customerName: json['CustomerName']?.toString(),
      loadingVesselName: json['LoadingVesselName']?.toString(),
      jobStatus: json['Jobstatus']?.toString(),
      cargoQTY: json['CargoQTY']?.toString(),
      cargoWeight: json['Cargoweight']?.toString(),
      employeeName: json['EmployeeName']?.toString(),
      CNumberDisplay: json['CNumberDisplay']?.toString(),
      eta: json['ETA']?.toString(),
      remarks: json['Remarks']?.toString(),
      awbNo: json['AWBNo']?.toString(),
      sourceTable: json['SourceTable']?.toString(),
      oiDateIn: json['OIDateIn']?.toString(),
      odiDateOut: json['ODIDateOut']?.toString(),
      id: (json['Id'] ?? 0).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'JobType': jobType,
      'OffVesselName': offVesselName,
      'CustomerName': customerName,
      'LoadingVesselName': loadingVesselName,
      'Jobstatus': jobStatus,
      'CargoQTY': cargoQTY,
      'Cargoweight': cargoWeight,
      'EmployeeName': employeeName,
      'CNumberDisplay': CNumberDisplay,
      'ETA': eta,
      'Remarks': remarks,
      'AWBNo': awbNo,
      'SourceTable': sourceTable,
      'OIDateIn': oiDateIn,
      'ODIDateOut': odiDateOut,
      'Id': id,
    };
  }
}
class ReviewModel {
  String ShopName;
  String ShopNumper;
  String EngRemarks;
  String Remarks;
  String Issue;
  int TicketNo;
  String Support_Date;
  String ReviewRemarks;
  int Id;

  ReviewModel(
      this.ShopName,
      this.ReviewRemarks,
      this.ShopNumper,
      this.EngRemarks,
      this.Remarks,
      this.Issue,
      this.TicketNo,
      this.Support_Date,
      this.Id);

  ReviewModel.fromJson(Map<String, dynamic> json)
      : TicketNo = int.parse(json['TicketNo'].toString()),
        ShopName = json['ShopName'].toString(),
        ShopNumper = json['ShopNumper'].toString(),
        EngRemarks = json['EngRemarks'].toString(),
        Remarks = json['Remarks'].toString(),
        ReviewRemarks = json['Remarks'].toString(),
        Issue = json['Issue'].toString(),
        Id = int.parse(json['Id'].toString()),
        Support_Date = json['Support_Date'].toString();
  Map<String, dynamic> toJson() {
    return {
      'TicketNo': TicketNo,
      'ShopName': ShopName,
      'ShopNumper': ShopNumper,
      'EngRemarks': EngRemarks,
      'Remarks': Remarks,
      'ReviewRemarks': ReviewRemarks,
      'Issue': Issue,
      'Id': Id,
      'Support_Date': Support_Date,
    };
  }
}
class ResponseViewModel {
  bool IsSuccess;
  int StatusCode;
  String Message;
  dynamic data1;
  dynamic data2;
  dynamic data3;
  dynamic data4;
  dynamic data5;
  dynamic data6;
  dynamic data7;
  dynamic data8;
  dynamic data9;
  dynamic data10;
  dynamic data11;
  ResponseViewModel(
      this.IsSuccess,
      this.StatusCode,
      this.Message,
      this.data1,
      this.data2,
      this.data3,
      this.data4,
      this.data5,
      this.data6,
      this.data7,
      this.data8,
      this.data9,
      this.data10,
      this.data11);
  ResponseViewModel.fromJson(Map<String, dynamic> json)
      : IsSuccess = json['IsSuccess'] ?? false,
        StatusCode = int.parse(json['StatusCode'].toString()),
        Message = json['Message'].toString(),
        data1 = _parseData(json['Data1']),
        data2 = _parseData(json['Data2']),
        data3 = _parseData(json['Data3']),
        data4 = _parseData(json['Data4']),
        data5 = _parseData(json['Data5']),
        data6 = _parseData(json['Data6']),
        data7 = _parseData(json['Data7']),
        data8 = _parseData(json['Data8']),
        data9 = _parseData(json['Data9']),
        data10 = _parseData(json['Data10']),
        data11 = _parseData(json['Data11']);

  static dynamic _parseData(dynamic data) {
    if (data is List) {
      return List<dynamic>.from(data);
    }
    return data;
  }
}
class AppuserModel {
  String Username;
  int Id;
  int CompanyRefid;
  String Priv;
  String Password;

  AppuserModel(
      this.Id, this.CompanyRefid, this.Username, this.Password, this.Priv);
  AppuserModel.fromJson(Map<String, dynamic> json)
      : Id = int.parse(json['Id'].toString()),
        CompanyRefid = int.parse(json['CompanyRefid'].toString()),
        Priv = json['Priv'] ?? '',
        Username = json['Username'] ?? '',
        Password = json['Password'] ?? '';
  // method
  Map<String, dynamic> toJson() {
    return {
      'Id': Id,
      'CompanyRefid': CompanyRefid,
      'Username': Username,
      'Password': Password,
      'Priv': Priv,
    };
  }
}
class MainsettingModel {
  String VariableName;
  int Id;
  int CompanyRefid;

  int Status;

  String SValue;

  MainsettingModel(
      this.Id, this.CompanyRefid, this.VariableName, this.SValue, this.Status);
  MainsettingModel.fromJson(Map<String, dynamic> json)
      : Id = int.parse(json['Id'].toString()),
        CompanyRefid = int.parse(json['CompanyRefid'].toString()),
        Status = (json['Status'].toString() == "1" ||
                json['Status'].toString() == "true")
            ? 1
            : 0,
        VariableName = json['VariableName'] ?? '',
        SValue = json['SValue'] ?? '';
  // method
  Map<String, dynamic> toJson() {
    return {
      'Id': Id,
      'CompanyRefid': CompanyRefid,
      'VariableName': VariableName,
      'SValue': SValue,
      'Status': Status,
    };
  }
}
class MenuMasterModel {
  String FormText;
  int Id;
  int CompanyRefid;
  int ParentId;
  int PageAdd;
  int PageEdit;
  int PageDelete;
  int PageView;

  MenuMasterModel(this.FormText, this.Id, this.CompanyRefid, this.ParentId,
      this.PageAdd, this.PageEdit, this.PageDelete, this.PageView);

  MenuMasterModel.fromJson(Map<String, dynamic> json)
      : FormText = json['FormText'] ?? '',
        Id = int.parse(json['Id'].toString()),
        CompanyRefid = int.parse(json['CompanyRefid'].toString()),
        ParentId = int.parse(json['ParentId'].toString()),
        PageAdd = int.parse(json['PageAdd'].toString()),
        PageEdit = int.parse(json['PageEdit'].toString()),
        PageDelete = int.parse(json['PageDelete'].toString()),
        PageView = int.parse(json['PageView'].toString());

  // method
  Map<String, dynamic> toJson() {
    return {
      'FormText': FormText,
      'ParentId': ParentId,
      'Id': Id,
      'CompanyRefid': CompanyRefid,
      'PageAdd': PageAdd,
      'PageEdit': PageEdit,
      'PageDelete': PageDelete,
      'PageView': PageView,
    };
  }

  MenuMasterModel.Empty()
      : FormText = '',
        Id = 0,
        CompanyRefid = 0,
        ParentId = 0,
        PageAdd = 0,
        PageEdit = 0,
        PageDelete = 0,
        PageView = 0;
}
class CompanyModel {
  int Id;
  int ParentId;
  int CCode;
  String CompanyName;
  int CStatus;
  int Active;
  String Address1;
  String Address2;
  String City;
  String Pincode;
  String MobileNo;
  String GSTinNo;
  String Email;
  String Website;
  String Landmark;
  String FooterMsg1;
  String FooterMsg2;
  String TopSolgan1;
  String TopSolgan2;
  String TaxType;
  String BillNoType;
  String BillPerfix;
  String TCompanyName;
  String TAddress1;
  String TAddress2;
  String TCity;
  int productauto;
  String screentype;

  CompanyModel(
      this.Id,
      this.ParentId,
      this.CCode,
      this.CompanyName,
      this.CStatus,
      this.Active,
      this.Address1,
      this.Address2,
      this.City,
      this.Pincode,
      this.MobileNo,
      this.GSTinNo,
      this.Email,
      this.Website,
      this.Landmark,
      this.FooterMsg1,
      this.FooterMsg2,
      this.TopSolgan1,
      this.TopSolgan2,
      this.TaxType,
      this.BillNoType,
      this.BillPerfix,
      this.TCompanyName,
      this.TAddress1,
      this.TAddress2,
      this.TCity,
      this.productauto,
      this.screentype);

  CompanyModel.fromJson(Map<String, dynamic> json)
      : Id = int.parse(json['Id'].toString()),
        ParentId = int.parse(json['ParentId'].toString() == 'null'
            ? '0'
            : json['ParentId'].toString()),
        CCode = int.parse(json['CCode'].toString()),
        CompanyName = json['CompanyName'] ?? '',
        CStatus = (json['CStatus'].toString() == "1" ||
                json['CStatus'].toString() == "true")
            ? 1
            : 0,
        Active = int.parse(json['Active'].toString()),
        Address1 = json['Address1'] ?? '',
        Address2 = json['Address2'] ?? '',
        City = json['City'] ?? '',
        Pincode = json['Pincode'] ?? '',
        MobileNo = json['MobileNo'] ?? '',
        GSTinNo = json['GSTinNo'] ?? '',
        Email = json['Email'] ?? '',
        Website = json['Website'] ?? '',
        Landmark = json['Landmark'] ?? '',
        FooterMsg1 = json['FooterMsg1'] ?? '',
        FooterMsg2 = json['FooterMsg2'] ?? '',
        TopSolgan1 = json['TopSolgan1'] ?? '',
        TopSolgan2 = json['TopSolgan2'] ?? '',
        TaxType = json['TaxType'] ?? '',
        BillNoType = json['BillNoType'],
        BillPerfix = json['BillPerfix'] ?? '',
        TCompanyName = json['TCompanyName'] ?? '',
        TAddress1 = json['TAddress1'] ?? '',
        TAddress2 = json['TAddress2'] ?? '',
        TCity = json['TCity'] ?? '',
        productauto = int.parse(json['productauto'].toString()),
        screentype = json['screentype'] ?? '';
  // method
  Map<String, dynamic> toJson() {
    return {
      'Id': Id,
      'ParentId': ParentId,
      'CCode': CCode,
      'CompanyName': CompanyName,
      'CStatus': CStatus,
      'Active': Active,
      'Address1': Address1,
      'Address2': Address2,
      'City': City,
      'Pincode': Pincode,
      'MobileNo': MobileNo,
      'GSTinNo': GSTinNo,
      'Email': Email,
      'Website': Website,
      'Landmark': Landmark,
      'FooterMsg1': FooterMsg2,
      'FooterMsg2': FooterMsg2,
      'TopSolgan1': TopSolgan1,
      'TopSolgan2': TopSolgan2,
      'TaxType': TaxType,
      'BillNoType': BillNoType,
      'BillPerfix': BillPerfix,
      'TCompanyName': TCompanyName,
      'TAddress1': TAddress1,
      'TAddress2': TAddress2,
      'TCity': TCity,
      'productauto': productauto,
      'screentype': screentype,
    };
  }
}
class BluetoothModel {
  int Id;
  String name;
  String devicename;
  String address;
  String name1;
  String address1;
  String printmodel;
  int type;
  bool connected;

  BluetoothModel(this.Id, this.name, this.address, this.type, this.connected,
      this.devicename, this.printmodel, this.name1, this.address1);

  BluetoothModel.fromJson(Map<String, dynamic> json)
      : Id = int.parse(json['Id'].toString()),
        name = json['name'].toString(),
        address = json['address'].toString(),
        type = int.parse(json['type'].toString()),
        connected = (json['connected'].toString() == '1' ||
            json['connected'].toString() == 'true')
            ? true
            : false,
        devicename = json['devicename'].toString(),
        printmodel = json['printmodel'],
        name1 = json['name1'].toString(),
        address1 = json['address1'].toString();

  // method
  Map<String, dynamic> toJson() {
    return {
      'Id': Id,
      'name': name,
      'address': address,
      'type': type,
      'connected': connected,
      'devicename': devicename,
      'printmodel': printmodel,
      'name1': name1,
      'address1': address1,
    };
  }

  BluetoothModel.Empty()
      : Id = 0,
        name = "",
        address = "",
        type = 0,
        connected =false,
        devicename="",
        printmodel="",
        name1="",
        address1="";


}
class DashboardModel {
  int TodaySales;
  double TodayAmount;
  int YesterdaySales;
  double YesterdayAmount;
  int WeekSales;
  double WeekAmount;
  int MonthSales;
  double MonthAmount;
  DashboardModel(
      this.TodaySales,
      this.TodayAmount,
      this.YesterdaySales,
      this.YesterdayAmount,
      this.WeekSales,
      this.WeekAmount,
      this.MonthSales,
      this.MonthAmount,);
  DashboardModel.fromJson(Map<String, dynamic> json)
      : TodaySales = int.parse(json['TodaySales'].toString()),
        TodayAmount = double.parse(json['TodayAmount'].toString()),
        YesterdaySales = int.parse(json['YesterdaySales'].toString()),
        YesterdayAmount = double.parse(json['YesterdayAmount'].toString()),
        WeekSales = int.parse(json['WeekSales'].toString()),
        WeekAmount = double.parse(json['WeekAmount'].toString()),
        MonthSales = int.parse(json['MonthSales'].toString()),
        MonthAmount = double.parse(json['MonthAmount'].toString());
}
class SaleOrderModel {
  List<SaleOrderMasterModel> SM;
  List<SaleOrderDetailModel> SD;
  SaleOrderModel(this.SM, this.SD);
  SaleOrderModel.fromJson(Map<String, dynamic> json)
      : SM = json['SM'],
        SD = json['SD'];
  // method
  Map<String, dynamic> toJson() {
    return {
      'SM': SM,
      'SD': SD,
    };
  }

  SaleOrderModel.Empty()
      : SM = <SaleOrderMasterModel>[SaleOrderMasterModel.Empty()],
        SD = <SaleOrderDetailModel>[SaleOrderDetailModel.Empty()];
}
class SaleOrderMasterModel {
  int Id;
  int CompanyRefId;
  String BillNoDisplay;
  String JobStatus;
  int BillNo;
  String BillDate;
  String BillTime;
  String SaleType;
  String CustomerName;
  String EmployeeName;
  String CashierName;
  String Remarks;
  String Origin;
  String Destination;
  String SPickupDate;
  String ETA;
  String SETA;
  String SETB;
  String SOETA;
  String SOETB;
  String SPort;
  String FlighTime;
  String Offvesselname;
  String Loadingvesselname;
  int JobMasterRefId;
  bool isETASelected;
  double NetAmt;

  SaleOrderMasterModel(
    this.Id,
    this.CompanyRefId,
    this.BillNoDisplay,
    this.JobStatus,
    this.BillNo,
    this.BillDate,
    this.BillTime,
    this.SaleType,
    this.CustomerName,
    this.EmployeeName,
    this.CashierName,
    this.Remarks,
    this.Origin,
    this.Destination,
    this.SPickupDate,
    this.ETA,
    this.SETA,
    this.SETB,
    this.SOETA,
    this.SOETB,
    this.SPort,
    this.FlighTime,
    this.Offvesselname,
    this.Loadingvesselname,
    this.JobMasterRefId,
    this.NetAmt,
  {this.isETASelected = false}
  );

  SaleOrderMasterModel.fromJson(Map<String, dynamic> json)
      : Id = int.parse(json['Id'].toString()),
        CompanyRefId = int.parse(json['CompanyRefId'].toString()),
        BillNoDisplay = json['BillNoDisplay'] ?? '',
        JobStatus = json['JobStatus'] ?? '',
        BillNo = int.parse(json['BillNo'].toString()),
        BillDate = json['BillDate'] ?? '',
        BillTime = json['BillTime'] ?? '',
        SaleType = json['SaleType'] ?? '',
        CustomerName = json['CustomerName'] ?? '',
        EmployeeName = json['EmployeeName'] ?? '',
        CashierName = json['CashierName'] ?? '',
        Remarks = json['Remarks'] ?? '',
        Origin = json['Origin'] ?? '',
        Destination = json['Destination'] ?? '',
        SPickupDate = json['SPickupDate'] ?? '',
        ETA = json['ETA'] ?? '',
        SETA = json['SETA'] ?? '',
        SETB = json['SETB'] ?? '',
        SOETA = json['SOETA'] ?? '',
        SOETB = json['SOETB'] ?? '',
        SPort = json['SPort'] ?? '',
        FlighTime = json['FlighTime'] ?? '',
        Offvesselname = json['Offvesselname'] ?? '',
        Loadingvesselname = json['Loadingvesselname'] ?? '',
        JobMasterRefId = int.parse(json['JobMasterRefId'].toString()),
       isETASelected = false,
      NetAmt = double.parse(json['NetAmt'].toString());
  // method
  Map<String, dynamic> toJson() {
    return {
      'Id': Id,
      'CompanyRefId' : CompanyRefId,
      'BillNoDisplay': BillNoDisplay,
      'JobStatus': JobStatus,
      'BillNo': BillNo,
      'BillDate': BillDate,
      'BillTime': BillTime,
      'SaleType': SaleType,
      'CustomerName': CustomerName,
      'EmployeeName': EmployeeName,
      'CashierName': CashierName,
      'Remarks': Remarks,
      'Origin': Origin,
      'Destination': Destination,
      'SPickupDate': SPickupDate,
      'ETA': ETA,
      'SETA': SETA,
      'SETB': SETB,
      'SOETA': SOETA,
      'SOETB': SOETB,
      'SPort': SPort,
      'FlighTime': FlighTime,
      'Offvesselname': Offvesselname,
      'Loadingvesselname': Loadingvesselname,
      'JobMasterRefId': JobMasterRefId,
      'NetAmt': NetAmt,
    };
  }

  SaleOrderMasterModel.Empty()
      : Id = 0,
        CompanyRefId = 0,
        BillNoDisplay = '',
        JobStatus = '',
        BillNo = 0,
        BillDate = '',
        BillTime = '',
        SaleType = '',
        CustomerName = '',
        EmployeeName = '',
        CashierName = '',
        Remarks = '',
        Origin = '',
        Destination = '',
        SPickupDate = '',
        ETA = '',
        isETASelected = false,
        SETA = '',
        SETB = '',
        SOETA = '',
        SOETB = '',
        SPort = '',
        FlighTime = '',
        Offvesselname = '',
        Loadingvesselname = '',
        JobMasterRefId = 0,
        NetAmt = 0.0;
}
class SaleOrderDetailModel {
  int Id;
  int SaleRefId;
  String ProductCode;
  String ProductName;
  double MRP;
  double SaleRate;
  double TaxPercent;
  double TaxAmt;
  double DiscountPercent;
  double DiscountAmt;
  double ItemQty;
  double SAmount;
  SaleOrderDetailModel(
      this.Id,
      this.SaleRefId,
      this.ProductCode,
      this.ProductName,
      this.MRP,
      this.SaleRate,
      this.TaxPercent,
      this.TaxAmt,
      this.DiscountPercent,
      this.DiscountAmt,
      this.ItemQty,
      this.SAmount);

  SaleOrderDetailModel.fromJson(Map<String, dynamic> json)
      : Id = int.parse(json['Id'].toString()),
        SaleRefId = int.parse(json['SaleRefId'].toString()),
        ProductCode = json['ProductCode'] ?? '',
        ProductName = json['ProductName'] ?? '',
        MRP = double.parse(json['MRP'].toString()),
        SaleRate = double.parse(json['SaleRate'].toString()),
        TaxPercent = double.parse(json['TaxPercent'].toString()),
        TaxAmt = double.parse(json['TaxAmt'].toString()),
        DiscountPercent = double.parse(json['DiscountPercent'].toString()),
        DiscountAmt = double.parse(json['DiscountAmt'].toString()),
        ItemQty = double.parse(json['ItemQty'].toString()),
        SAmount = double.parse(json['SAmount'].toString());

  // method
  Map<String, dynamic> toJson() {
    return {
      'Id': Id,
      'SaleRefId': SaleRefId,
      'ProductCode': ProductCode,
      'ProductName': ProductName,
      'MRP': MRP,
      'SaleRate': SaleRate,
      'TaxPercent': TaxPercent,
      'TaxAmt': TaxAmt,
      'DiscountPercent': DiscountPercent,
      'DiscountAmt': DiscountAmt,
      'ItemQty': ItemQty,
      'SAmount': SAmount,
    };
  }

  SaleOrderDetailModel.Empty()
      : Id = 0,
        SaleRefId = 0,
        ProductCode = '',
        ProductName = '',
        MRP = 0.0,
        SaleRate = 0.0,
        TaxPercent = 0.0,
        TaxAmt = 0.0,
        DiscountPercent = 0.0,
        DiscountAmt = 0.0,
        ItemQty = 0.0,
        SAmount = 0.0;
}
class PlanningMasterModel {
  int Id;
  int PLANINGNo;
  String PLANINGNoDisplay;
  String PLANINGDate;
  String Remarks;
  PlanningMasterModel(
      this.Id,
      this.PLANINGNo,
      this.PLANINGNoDisplay,
      this.PLANINGDate,
      this.Remarks,
      );
  PlanningMasterModel.fromJson(Map<String, dynamic> json)
      : Id = int.parse(json['Id'].toString()),
        PLANINGNo = int.parse(json['PLANINGNo'].toString()),
        PLANINGNoDisplay = json['PLANINGNoDisplay'] ?? '',
        PLANINGDate = json['PLANINGDate'] ?? '',
        Remarks = json['Remarks'] ?? '';
  // method
  Map<String, dynamic> toJson() {
    return {
      'Id': Id,
      'PLANINGNo': PLANINGNo,
      'PLANINGNoDisplay': PLANINGNoDisplay,
      'PLANINGDate': PLANINGDate,
      'Remarks': Remarks,
    };
  }

  PlanningMasterModel.Empty()
      : Id = 0,
        PLANINGNo = 0,
        PLANINGNoDisplay = '',
        PLANINGDate = '',
        Remarks = '';
}
class VesselPlanningMasterModel {
  int Id;
  int VESSELPLANINGNo;
  String VESSELPLANINGNoDisplay;
  String VESSELPLANINGDate;
  String Remarks;
  VesselPlanningMasterModel(
      this.Id,
      this.VESSELPLANINGNo,
      this.VESSELPLANINGNoDisplay,
      this.VESSELPLANINGDate,
      this.Remarks,
      );
  VesselPlanningMasterModel.fromJson(Map<String, dynamic> json)
      : Id = int.parse(json['Id'].toString()),
        VESSELPLANINGNo = int.parse(json['VESSELPLANINGNo'].toString()),
        VESSELPLANINGNoDisplay = json['VESSELPLANINGNoDisplay'] ?? '',
        VESSELPLANINGDate = json['VESSELPLANINGDate'] ?? '',
        Remarks = json['Remarks'] ?? '';
  // method
  Map<String, dynamic> toJson() {
    return {
      'Id': Id,
      'VESSELPLANINGNo': VESSELPLANINGNo,
      'VESSELPLANINGNoDisplay': VESSELPLANINGNoDisplay,
      'VESSELPLANINGDate': VESSELPLANINGDate,
      'Remarks': Remarks,
    };
  }

  VesselPlanningMasterModel.Empty()
      : Id = 0,
        VESSELPLANINGNo = 0,
        VESSELPLANINGNoDisplay = '',
        VESSELPLANINGDate = '',
        Remarks = '';
}
class SaleEditDetailModel {
  int Id;
  int SDId;
  int SaleOrderMasterRefId;
  int ItemMasterRefId;
  double MRP;
  double PurchaseRate;
  double ItemQty;
  double DiscPer;
  double DiscAmount;
  double LandingCost;
  double TaxPercent;
  double TaxAmount;
  double SalesRate;
  double NetSalesRate;
  double Amount;
  String ProductCode;
  String ProductName;
  String UOM;
  double ActualAmount;
  double CurrencyValue;

  SaleEditDetailModel(
      this.Id,
      this.SDId,
      this.SaleOrderMasterRefId,
      this.ItemMasterRefId,
      this.MRP,
      this.PurchaseRate,
      this.ItemQty,
      this.DiscPer,
      this.DiscAmount,
      this.LandingCost,
      this.TaxPercent,
      this.TaxAmount,
      this.SalesRate,
      this.NetSalesRate,
      this.Amount,
      this.ProductCode,
      this.ProductName,
      this.UOM,
      this.ActualAmount,
      this.CurrencyValue);

  SaleEditDetailModel.fromJson(Map<String, dynamic> json)
      : Id = int.parse(json['Id'].toString()),
        SDId = int.parse(json['SDId'].toString()),
        SaleOrderMasterRefId =
            int.parse(json['SaleOrderMasterRefId'].toString()),
        ItemMasterRefId = int.parse(json['ItemMasterRefId'].toString()),
        MRP = double.parse(json['MRP'].toString()),
        PurchaseRate = double.parse(json['PurchaseRate'].toString()),
        ItemQty = double.parse(json['ItemQty'].toString()),
        DiscPer = double.parse(json['DiscPer'].toString()),
        DiscAmount = double.parse(json['DiscAmount'].toString()),
        LandingCost = double.parse(json['LandingCost'].toString()),
        TaxPercent = double.parse(json['TaxPercent'].toString()),
        TaxAmount = double.parse(json['TaxAmount'].toString()),
        SalesRate = double.parse(json['SalesRate'].toString()),
        NetSalesRate = double.parse(json['NetSalesRate'].toString()),
        Amount = double.parse(json['Amount'].toString()),
        ProductCode = json['ProductCode'] ?? '',
        ProductName = json['ProductName'] ?? '',
        UOM = json['UOM'] ?? '',
        ActualAmount = double.parse(json['ActualAmount'].toString()),
        CurrencyValue = double.parse(json['CurrencyValue'].toString());

  // method
  Map<String, dynamic> toJson() {
    return {
      'Id': Id,
      'SDId': SDId,
      'SaleOrderMasterRefId': SaleOrderMasterRefId,
      'ItemMasterRefId': ItemMasterRefId,
      'MRP': MRP,
      'PurchaseRate': PurchaseRate,
      'ItemQty': ItemQty,
      'DiscPer': DiscPer,
      'DiscAmount': DiscAmount,
      'LandingCost': LandingCost,
      'TaxPercent': TaxPercent,
      'TaxAmount': TaxAmount,
      'SalesRate': SalesRate,
      'NetSalesRate': NetSalesRate,
      'Amount': Amount,
      'ProductCode': ProductCode,
      'ProductName': ProductName,
      'UOM': UOM,
      'ActualAmount': ActualAmount,
      'CurrencyValue': CurrencyValue,
    };
  }

  SaleEditDetailModel.Empty()
      : Id = 0,
        SDId = 0,
        SaleOrderMasterRefId = 0,
        ItemMasterRefId = 0,
        MRP = 0.0,
        PurchaseRate = 0.0,
        ItemQty = 0.0,
        DiscPer = 0.0,
        DiscAmount = 0.0,
        LandingCost = 0.0,
        TaxPercent = 0.0,
        TaxAmount = 0.0,
        SalesRate = 0.0,
        NetSalesRate = 0.0,
        Amount = 0.0,
        ProductCode = '',
        ProductName = '',
        UOM = '',
        ActualAmount = 0.0,
        CurrencyValue = 0.0;
}
class AddressDetailsModel {
  int Id;
  String Name;
  String Address;
  String Phone;
  int Active;

  AddressDetailsModel(
      this.Id, this.Name, this.Address, this.Phone, this.Active);

  AddressDetailsModel.fromJson(Map<String, dynamic> json)
      : Id = int.parse(json['Id'].toString()),
        Name = json['Name'] ?? '',
        Address = json['Address'] ?? '',
        Phone = json['Phone'] ?? '',
        Active = int.parse(json['Active'].toString());
  // method
  Map<String, dynamic> toJson() {
    return {
      'Id': Id,
      'Name': Name,
      'Address': Address,
      'Phone': Phone,
      'Active': Active
    };
  }

  AddressDetailsModel.Empty()
      : Id = 0,
        Name = '',
        Address = '',
        Phone = '',
        Active = 0;
}
class RTIMasterViewModel {
  int Id;
  int RTINo;
  int TruckMasterRefId;
  String RTIDate;
  String RTINoDisplay;
  String DriverName;
  String TruckName;
  String Remarks;
  double Amount;

  RTIMasterViewModel(
      this.Id, this.RTINo,this.TruckMasterRefId,this.RTINoDisplay, this.RTIDate, this.DriverName, this.TruckName, this.Remarks, this.Amount);

  RTIMasterViewModel.fromJson(Map<String, dynamic> json)
      : Id = int.parse(json['Id'].toString()),
        RTINo = int.parse(json['RTINo'].toString()),
        TruckMasterRefId = int.parse(json['TruckMasterRefId'].toString()),
        RTINoDisplay = json['RTINoDisplay'] ?? '',
        RTIDate = json['RTIDate'] ?? '',
        DriverName = json['DriverName'] ?? '',
        TruckName = json['TruckName'] ?? '',
        Remarks = json['Remarks'] ?? '',
        Amount = double.parse(json['Amount'].toString());
  // method
  Map<String, dynamic> toJson() {
    return {
      'Id': Id,
      'RTINo': RTINo,
      'TruckMasterRefId': TruckMasterRefId,
      'RTINoDisplay': RTINoDisplay,
      'RTIDate': RTIDate,
      'DriverName': DriverName,
      'TruckName': TruckName,
      'Remarks': Remarks,
      'Amount': Amount
    };
  }

  RTIMasterViewModel.Empty()
      : Id = 0,
        RTINo = 0,
        TruckMasterRefId = 0,
        RTINoDisplay = '',
        RTIDate = '',
        DriverName = '',
        TruckName = '',
        Remarks = '',
        Amount = 0.0;
}
class RTIDetailsViewModel {
  int Id;
  int SDId;
  int RTIMasterRefId;
  int StatusId;
  int SaleOrderMasterRefId;
  int CustomerMasterRefId;
  String JobNo;
  String JobDate;
  String CustomerName;
  double Salary;
  String PPIC;
  String DPIC;
  int PWDType;
  int Active;
  int Verify;
  bool isChecked;
  bool isVerified;
  String? imagePath;
  XFile? imageFile;


  RTIDetailsViewModel(
      this.Id, this.SDId,this.RTIMasterRefId,this.StatusId, this.SaleOrderMasterRefId,this.CustomerMasterRefId, this.JobNo, this.JobDate, this.CustomerName, this.Salary, this.PPIC, this.DPIC, this.PWDType,this.Active, this.Verify,this.imagePath,this.imageFile,{ this.isChecked = false , this.isVerified = false});

  RTIDetailsViewModel.fromJson(Map<String, dynamic> json)
      : Id = int.parse(json['Id'].toString()),
        SDId = int.parse(json['SDId'].toString()),
        RTIMasterRefId = int.parse(json['RTIMasterRefId'].toString()),
        StatusId = int.parse(json['StatusId'].toString()),
        SaleOrderMasterRefId = int.parse(json['SaleOrderMasterRefId'].toString()),
        CustomerMasterRefId = int.parse(json['CustomerMasterRefId'].toString()),
        JobNo = json['JobNo'] ?? '',
        JobDate = json['JobDate'] ?? '',
        CustomerName = json['CustomerName'] ?? '',
        Salary = double.parse(json['Salary'].toString()),
        PPIC = json['PPIC'] ?? '',
        DPIC = json['DPIC'] ?? '',
        PWDType = int.parse(json['PWDType'].toString()),
        Active = int.parse(json['Active'].toString()),
        Verify = int.tryParse(json['Verify']?.toString() ?? '') ?? 0,
        imagePath = json['ImagePath'] ?? '',
        isChecked = int.parse(json['Active'].toString()) == 1,
        isVerified =
            (int.tryParse(json['Verify']?.toString() ?? '') ?? 0) == 1;
  // method
  Map<String, dynamic> toJson() {
    return {
      'Id': Id,
      'SDId': SDId,
      'RTIMasterRefId': RTIMasterRefId,
      'StatusId': StatusId,
      'SaleOrderMasterRefId': SaleOrderMasterRefId,
      'CustomerMasterRefId': CustomerMasterRefId,
      'JobNo': JobNo,
      'JobDate': JobDate,
      'CustomerName': CustomerName,
      'Salary': Salary,
      'PPIC': PPIC,
      'DPIC': DPIC,
      'PWDType': PWDType,
      'imagePath': imagePath,
      'Active': Active,
      'Verify': Verify

    };
  }

  RTIDetailsViewModel.Empty()
      : Id = 0,
        SDId = 0,
        RTIMasterRefId = 0,
        StatusId = 0,
        SaleOrderMasterRefId = 0,
        CustomerMasterRefId = 0,
        JobNo = '',
        JobDate = '',
        CustomerName = '',
        Salary = 0.0,
        PPIC = '',
        DPIC = '',
        PWDType = 0,
        isChecked = false,
        isVerified = false,
        imagePath = '',
        Active = 0,
        Verify = 0;

  RTIDetailsViewModel copyWith({
    int? Id,
    int? SDId,
    int? RTIMasterRefId,
    int? StatusId,
    int? SaleOrderMasterRefId,
    int? CustomerMasterRefId,
    String? JobNo,
    String? JobDate,
    String? CustomerName,
    double? Salary,
    String? PPIC,
    String? DPIC,
    int? PWDType,
    int? Active,
    int? Verify,
    bool? isChecked,
    bool? isVerified,
    String? imagePath,
    XFile? imageFile,
  }) {
    return RTIDetailsViewModel(
      Id ?? this.Id,
      SDId ?? this.SDId,
      RTIMasterRefId ?? this.RTIMasterRefId,
      StatusId ?? this.StatusId,
      SaleOrderMasterRefId ?? this.SaleOrderMasterRefId,
      CustomerMasterRefId ?? this.CustomerMasterRefId,
      JobNo ?? this.JobNo,
      JobDate ?? this.JobDate,
      CustomerName ?? this.CustomerName,
      Salary ?? this.Salary,
      PPIC ?? this.PPIC,
      DPIC ?? this.DPIC,
      PWDType ?? this.PWDType,
      Active ?? this.Active,
      Verify ?? this.Verify,
      imagePath ?? this.imagePath,
      imageFile ?? this.imageFile,
      isChecked: isChecked ?? this.isChecked,
      isVerified: isVerified ?? this.isVerified,
    );
  }


}
class FuelEntryModel {
  int Id;
  int CompanyRefId;
  double Aliter;
  double AAmount;
  String SSaleDate;


  FuelEntryModel(this.Id,
      this.CompanyRefId,
      this.Aliter,
      this.AAmount,
      this.SSaleDate,);

  FuelEntryModel.fromJson(Map<String, dynamic> json)
      : Id = int.parse(json['Id'].toString()),
        CompanyRefId = int.parse(json['CompanyRefId'].toString()),
        AAmount = double.parse(json['AAmount'].toString()),
        Aliter = double.parse(json['Aliter'].toString()),
        SSaleDate=json['SSaleDate'].toString();

  // method
  Map<String, dynamic> toJson() {
    return {
      'Id': Id,
      'CompanyRefId': CompanyRefId,
      'Aliter': Aliter,
      'AAmount': AAmount,
      'SSaleDate':SSaleDate,
    };
  }

  FuelEntryModel.Empty()
      : Id = 0,
        CompanyRefId = 0,
        Aliter = 0,
        AAmount = 0,
        SSaleDate='';
}
class FuelselectModel {
  int? id;
  int? companyRefId;
  int? userRefId;
  int? employeeRefId;
  int? lastEmployeeRefId;
  int? truckRefId;
  int? driverRefId;
  String? saleDate;
  String? sSaleDate;
  String? cNumberDisplay;
  int? cNumber;
  String? remarks;
  int? active;
  int? fStatus;
  double? aliter;
  double? aAmount;
  double? pliter;
  double? pRate;
  double? pAmount;
  double? gliter;
  double? gAmount;
  double? dPliter;
  double? dPAmount;
  double? dGliter;
  double? dGAmount;
  String? filePath;
  String? createdDate;
  String? createdBy;
  String? modifiedDate;
  String? modifiedBy;
  String? driverName;
  String? truckName;

  FuelselectModel({
    this.id,
    this.companyRefId,
    this.userRefId,
    this.employeeRefId,
    this.lastEmployeeRefId,
    this.truckRefId,
    this.driverRefId,
    this.saleDate,
    this.sSaleDate,
    this.cNumberDisplay,
    this.cNumber,
    this.remarks,
    this.active,
    this.fStatus,
    this.aliter,
    this.aAmount,
    this.pliter,
    this.pRate,
    this.pAmount,
    this.gliter,
    this.gAmount,
    this.dPliter,
    this.dPAmount,
    this.dGliter,
    this.dGAmount,
    this.filePath,
    this.createdDate,
    this.createdBy,
    this.modifiedDate,
    this.modifiedBy,
    this.driverName,
    this.truckName,
  });

  factory FuelselectModel.fromJson(Map<String, dynamic> json) {
    return FuelselectModel(
      id: json['Id'] ?? 0,
      companyRefId: json['CompanyRefId'] ?? 0,
      userRefId: json['UserRefId'] ?? 0,
      employeeRefId: json['EmployeeRefId'] ?? 0,
      lastEmployeeRefId: json['LastEmployeeRefId'] ?? 0,
      truckRefId: json['TruckRefid'] ?? 0,
      driverRefId: json['DriverRefId'] ?? 0,
      saleDate: json['SaleDate'] ?? '',
      sSaleDate: json['SSaleDate'] ?? '',
      cNumberDisplay: json['CNumberDisplay'] ?? '',
      cNumber: json['CNumber'] ?? 0,
      remarks: json['Remarks'] ?? '',
      active: json['Active'] ?? 0,
      fStatus: json['FStatus'] ?? 0,
      aliter: (json['Aliter'] ?? 0).toDouble(),
      aAmount: (json['AAmount'] ?? 0).toDouble(),
      pliter: (json['Pliter'] ?? 0).toDouble(),
      pRate: (json['PRate'] ?? 0).toDouble(),
      pAmount: (json['PAmount'] ?? 0).toDouble(),
      gliter: (json['Gliter'] ?? 0).toDouble(),
      gAmount: (json['GAmount'] ?? 0).toDouble(),
      dPliter: (json['DPliter'] ?? 0).toDouble(),
      dPAmount: (json['DPAmount'] ?? 0).toDouble(),
      dGliter: (json['DGliter'] ?? 0).toDouble(),
      dGAmount: (json['DGAmount'] ?? 0).toDouble(),
      filePath: json['FilePath'] ?? '',
      createdDate: json['Created_Date'] ?? '',
      createdBy: json['Created_By'] ?? '',
      modifiedDate: json['Modified_Date'] ?? '',
      modifiedBy: json['Modified_By'] ?? '',
      driverName: json['DriverName'] ?? '',
      truckName: json['TruckName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'CompanyRefId': companyRefId,
      'UserRefId': userRefId,
      'EmployeeRefId': employeeRefId,
      'LastEmployeeRefId': lastEmployeeRefId,
      'TruckRefid': truckRefId,
      'DriverRefId': driverRefId,
      'SaleDate': saleDate,
      'SSaleDate': sSaleDate,
      'CNumberDisplay': cNumberDisplay,
      'CNumber': cNumber,
      'Remarks': remarks,
      'Active': active,
      'FStatus': fStatus,
      'Aliter': aliter,
      'AAmount': aAmount,
      'Pliter': pliter,
      'PRate': pRate,
      'PAmount': pAmount,
      'Gliter': gliter,
      'GAmount': gAmount,
      'DPliter': dPliter,
      'DPAmount': dPAmount,
      'DGliter': dGliter,
      'DGAmount': dGAmount,
      'FilePath': filePath,
      'Created_Date': createdDate,
      'Created_By': createdBy,
      'Modified_Date': modifiedDate,
      'Modified_By': modifiedBy,
      'DriverName': driverName,
      'TruckName': truckName,
    };
  }
}
class DriverViewModel {
  String DriverName;
  String Address1;
  String Address2;
  String City;
  int Active;
  String State;
  String Zipcode;
  String Country;
  String GSTNO;
  String Email;
  String MobileNo;
  String UserName;
  String Password;
  String DocumentType;
  String Latitude;
  String Longitude;
  String TokenId;
  String LicenseNo;
  String licenseExp;
  String GDLNo;
  String GDLExp;
  String KuantanPort;
  String NorthportPort;
  String PkfzPort;
  String KliaPort;
  String PguPort;
  String TanjungPort;
  String PenangPort;
  String PtpPort;
  String WestportPort;
  String JoiningDate;
  String LeavingDate;
  String TinNo;
  String SSTNo;
  String MsicCode;
  String ServiceTaxType;
  String KuantanPortStatus;
  String NorthportPortStatus;
  String PkfzPortStatus;
  String KliaPortStatus;
  String PguPortStatus;
  String TanjungPortStatus;
  String PenangPortStatus;
  String PtpPortStatus;
  String WestportPortStatus;

  DriverViewModel(
      this.DriverName,
      this.Address1,
      this.Address2,
      this.City,
      this.Active,
      this.State,
      this.Zipcode,
      this.Country,
      this.GSTNO,
      this.Email,
      this.MobileNo,
      this.UserName,
      this.Password,
      this.DocumentType,
      this.Latitude,
      this.Longitude,
      this.TokenId,
      this.LicenseNo,
      this.licenseExp,
      this.GDLNo,
      this.GDLExp,
      this.KuantanPort,
      this.NorthportPort,
      this.PkfzPort,
      this.KliaPort,
      this.PguPort,
      this.TanjungPort,
      this.PenangPort,
      this.PtpPort,
      this.WestportPort,
      this.JoiningDate,
      this.LeavingDate,
      this.TinNo,
      this.SSTNo,
      this.MsicCode,
      this.ServiceTaxType,
      this.KuantanPortStatus,
      this.NorthportPortStatus,
      this.PkfzPortStatus,
      this.KliaPortStatus,
      this.PguPortStatus,
      this.TanjungPortStatus,
      this.PenangPortStatus,
      this.PtpPortStatus,
      this.WestportPortStatus,
      );

  DriverViewModel.fromJson(Map<String, dynamic> json)
      : DriverName = json['DriverName'] ?? "",
        Address1 = json['Address1'] ?? "",
        Address2 = json['Address2'] ?? "",
        City = json['City'] ?? "",
        Active = json['Active'] ?? 0,
        State = json['State'] ?? "",
        Zipcode = json['Zipcode'] ?? "",
        Country = json['Country'] ?? "",
        GSTNO = json['GSTNO'] ?? "",
        Email = json['Email'] ?? "",
        MobileNo = json['MobileNo'] ?? "",
        UserName = json['UserName'] ?? "",
        Password = json['Password'] ?? "",
        DocumentType = json['DocumentType'] ?? "",
        Latitude = json['Latitude'] ?? "",
        Longitude = json['Longitude'] ?? "",
        TokenId = json['TokenId'] ?? "",
        LicenseNo = json['LicenseNo'] ?? "",
        licenseExp = json['licenseExp'] ?? "",
        GDLNo = json['GDLNo'] ?? "",
        GDLExp = json['GDLExp'] ?? "",
        KuantanPort = json['KuantanPort'] ?? "",
        NorthportPort = json['NorthportPort'] ?? "",
        PkfzPort = json['PkfzPort'] ?? "",
        KliaPort = json['KliaPort'] ?? "",
        PguPort = json['PguPort'] ?? "",
        TanjungPort = json['TanjungPort'] ?? "",
        PenangPort = json['PenangPort'] ?? "",
        PtpPort = json['PtpPort'] ?? "",
        WestportPort = json['WestportPort'] ?? "",
        JoiningDate = json['JoiningDate'] ?? "",
        LeavingDate = json['LeavingDate'] ?? "",
        TinNo = json['TinNo'] ?? "",
        SSTNo = json['SSTNo'] ?? "",
        MsicCode = json['MsicCode'] ?? "",
        ServiceTaxType = json['ServiceTaxType'] ?? "",
        KuantanPortStatus = json['KuantanPortStatus'] ?? "",
        NorthportPortStatus = json['NorthportPortStatus'] ?? "",
        PkfzPortStatus = json['PkfzPortStatus'] ?? "",
        KliaPortStatus = json['KliaPortStatus'] ?? "",
        PguPortStatus = json['PguPortStatus'] ?? "",
        TanjungPortStatus = json['TanjungPortStatus'] ?? "",
        PenangPortStatus = json['PenangPortStatus'] ?? "",
        PtpPortStatus = json['PtpPortStatus'] ?? "",
        WestportPortStatus = json['WestportPortStatus'] ?? "";

  Map<String, dynamic> toJson() {
    return {
      'DriverName': DriverName,
      'Address1': Address1,
      'Address2': Address2,
      'City': City,
      'State': State,
      'Active': Active,
      'Zipcode': Zipcode,
      'Country': Country,
      'GSTNO': GSTNO,
      'Email': Email,
      'MobileNo': MobileNo,
      'UserName': UserName,
      'Password': Password,
      'DocumentType': DocumentType,
      'Latitude': Latitude,
      'Longitude': Longitude,
      'TokenId': TokenId,
      'LicenseNo': LicenseNo,
      'licenseExp': licenseExp,
      'GDLNo': GDLNo,
      'GDLExp': GDLExp,
      'KuantanPort': KuantanPort,
      'NorthportPort': NorthportPort,
      'PkfzPort': PkfzPort,
      'KliaPort': KliaPort,
      'PguPort': PguPort,
      'TanjungPort': TanjungPort,
      'PenangPort': PenangPort,
      'PtpPort': PtpPort,
      'WestportPort': WestportPort,
      'JoiningDate': JoiningDate,
      'LeavingDate': LeavingDate,
      'TinNo': TinNo,
      'SSTNo': SSTNo,
      'MsicCode': MsicCode,
      'ServiceTaxType': ServiceTaxType,
      'KuantanPortStatus': KuantanPortStatus,
      'NorthportPortStatus': NorthportPortStatus,
      'PkfzPortStatus': PkfzPortStatus,
      'KliaPortStatus': KliaPortStatus,
      'PguPortStatus': PguPortStatus,
      'TanjungPortStatus': TanjungPortStatus,
      'PenangPortStatus': PenangPortStatus,
      'PtpPortStatus': PtpPortStatus,
      'WestportPortStatus': WestportPortStatus,
    };
  }

  DriverViewModel.Empty()
      : DriverName = "",
        Address1 = "",
        Address2 = "",
        City = "",
        State = "",
        Active = 0,
        Zipcode = "",
        Country = "",
        GSTNO = "",
        Email = "",
        MobileNo = "",
        UserName = "",
        Password = "",
        DocumentType = "",
        Latitude = "",
        Longitude = "",
        TokenId = "",
        LicenseNo = "",
        licenseExp = "",
        GDLNo = "",
        GDLExp = "",
        KuantanPort = "",
        NorthportPort = "",
        PkfzPort = "",
        KliaPort = "",
        PguPort = "",
        TanjungPort = "",
        PenangPort = "",
        PtpPort = "",
        WestportPort = "",
        JoiningDate = "",
        LeavingDate = "",
        TinNo = "",
        SSTNo = "",
        MsicCode = "",
        ServiceTaxType = "",
        KuantanPortStatus = "",
        NorthportPortStatus = "",
        PkfzPortStatus = "",
        KliaPortStatus = "",
        PguPortStatus = "",
        TanjungPortStatus = "",
        PenangPortStatus = "",
        PtpPortStatus = "",
        WestportPortStatus = "";
}
class BillViewModel {
  int Id;
  String BillNoDisplay;
  String BillNoDisplay1;
  int BillNo;
  int PStatus;
  int Fileupload;
  String BillDate;
  String InvoiceNo;
  String InvoiceDate;
  String BillTime;
  String SaleType;
  String SupplierName;
  String EmployeeName;
  String? CashierName;
  String TruckName;
  String DriverName;
  String? BillStatus;
  String? Description;
  String? Remarks;
  double NetAmt;

  BillViewModel({
    required this.Id,
    required this.BillNoDisplay,
    required this.BillNoDisplay1,
    required this.BillNo,
    required this.PStatus,
    required this.Fileupload,
    required this.BillDate,
    required this.InvoiceNo,
    required this.InvoiceDate,
    required this.BillTime,
    required this.SaleType,
    required this.SupplierName,
    required this.EmployeeName,
    this.CashierName,
    required this.TruckName,
    required this.DriverName,
    this.BillStatus,
    this.Description,
    this.Remarks,
    required this.NetAmt,
  });

  /// ✅ Create from JSON
  factory BillViewModel.fromJson(Map<String, dynamic> json) {
    return BillViewModel(
      Id: json['Id'] ?? 0,
      BillNoDisplay: json['BillNoDisplay'] ?? "",
      BillNoDisplay1: json['BillNoDisplay1'] ?? "",
      BillNo: json['BillNo'] ?? 0,
      PStatus: json['PStatus'] ?? 0,
      Fileupload: json['Fileupload'] ?? 0,
      BillDate: json['BillDate'] ?? "",
      InvoiceNo: json['InvoiceNo'] ?? "",
      InvoiceDate: json['InvoiceDate'] ?? "",
      BillTime: json['BillTime'] ?? "",
      SaleType: json['SaleType'] ?? "",
      SupplierName: json['SupplierName'] ?? "",
      EmployeeName: json['EmployeeName'] ?? "",
      CashierName: json['CashierName'],
      TruckName: json['TruckName'] ?? "",
      DriverName: json['DriverName'] ?? "",
      BillStatus: json['BillStatus'],
      Description: json['Description'],
      Remarks: json['Remarks'],
      NetAmt: (json['NetAmt'] ?? 0).toDouble(),
    );
  }

  /// ✅ Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'Id': Id,
      'BillNoDisplay': BillNoDisplay,
      'BillNoDisplay1': BillNoDisplay1,
      'BillNo': BillNo,
      'PStatus': PStatus,
      'Fileupload': Fileupload,
      'BillDate': BillDate,
      'InvoiceNo': InvoiceNo,
      'InvoiceDate': InvoiceDate,
      'BillTime': BillTime,
      'SaleType': SaleType,
      'SupplierName': SupplierName,
      'EmployeeName': EmployeeName,
      'CashierName': CashierName,
      'TruckName': TruckName,
      'DriverName': DriverName,
      'BillStatus': BillStatus,
      'Description': Description,
      'Remarks': Remarks,
      'NetAmt': NetAmt,
    };
  }

  /// ✅ Empty constructor (optional)
  BillViewModel.Empty()
      : Id = 0,
        BillNoDisplay = "",
        BillNoDisplay1 = "",
        BillNo = 0,
        PStatus = 0,
        Fileupload = 0,
        BillDate = "",
        InvoiceNo = "",
        InvoiceDate = "",
        BillTime = "",
        SaleType = "",
        SupplierName = "",
        EmployeeName = "",
        CashierName = null,
        TruckName = "",
        DriverName = "",
        BillStatus = null,
        Description = null,
        Remarks = null,
        NetAmt = 0.0;
}
class LicenseViewModel {
  String LicenseName;
  String Category;
  String ExpiryDate;
  String LDate;
  int Active;

  // ✅ Constructor
  LicenseViewModel(
      this.LicenseName,
      this.Category,
      this.ExpiryDate,
      this.LDate,
      this.Active,
      );

  // ✅ fromJson factory constructor
  factory LicenseViewModel.fromJson(Map<String, dynamic> json) {
    return LicenseViewModel(
      json['LicenseName'] ?? "",
      json['Category'] ?? "",
      json['ExpiryDate'] ?? "",
      json['LDate'] ?? "",
      json['Active'] ?? 0,
    );
  }

  // ✅ toJson method
  Map<String, dynamic> toJson() {
    return {
      'LicenseName': LicenseName,
      'Category': Category,
      'ExpiryDate': ExpiryDate,
      'LDate': LDate,
      'Active': Active,
    };
  }

  // ✅ Empty constructor for default initialization
  LicenseViewModel.Empty()
      : LicenseName = "",
        Category = "",
        ExpiryDate = "",
        LDate = "",
        Active = 0;
}
class BarcodePrintModel {
  String CompanyName_Data;
  String ShipName_Data;
  String ShipName_Data2;
  String Barcode_Data;
  String Date_Data;
  String Port_Data ;
  String JobNo_Data;
  String Pkg_Data ;


  BarcodePrintModel(this.CompanyName_Data,
      this.ShipName_Data,
      this.ShipName_Data2,
      this.Barcode_Data,
      this.Date_Data,
      this.Port_Data ,
      this.JobNo_Data,
      this.Pkg_Data ,
      );

  BarcodePrintModel.fromJson(Map<String, dynamic> json)
      :
        CompanyName_Data=json['CompanyName_Data'].toString(),
        ShipName_Data=json['ShipName_Data'].toString(),
        ShipName_Data2=json['ShipName_Data2'].toString(),
        Barcode_Data=json['Barcode_Data'].toString(),
        Date_Data=json['Date_Data'].toString(),
        Port_Data=json['Port_Data'].toString(),
        JobNo_Data=json['JobNo_Data'].toString(),
        Pkg_Data=json['Pkg_Data'].toString();


  // method
  Map<String, dynamic> toJson() {
    return {
      'CompanyName_Data': CompanyName_Data,
      'ShipName_Data': ShipName_Data,
      'ShipName_Data2': ShipName_Data2,
      'Barcode_Data': Barcode_Data,
      'Date_Data': Date_Data,
      'Port_Data ':Port_Data ,
      'JobNo_Data': JobNo_Data,
      'Pkg_Data ':Pkg_Data ,
    };
  }

  BarcodePrintModel.Empty()
      : CompanyName_Data = "",
        ShipName_Data = "",
        ShipName_Data2 = "",
        Barcode_Data = "",
        Date_Data = "",
        Port_Data ="",
        JobNo_Data = "",
        Pkg_Data ="";
}
class PettyCashMasterModel {
  int Id;
  int CompanyRefId;
  int EmployeeRefId;
  String CNumberDisplay;
  String EmployeeName;
  String PettyCashDate;
  String PaymentStatus;
  int CNumber;
  int Status;
  String Amount;

  PettyCashMasterModel({
    required this.Id,
    required this.CompanyRefId,
    required this.EmployeeRefId,
    required this.CNumberDisplay,
    required this.EmployeeName,
    required this.PettyCashDate,
    required this.PaymentStatus,
    required this.CNumber,
    required this.Status,
    required this.Amount,
  });

  factory PettyCashMasterModel.fromJson(Map<String, dynamic> json) {
    return PettyCashMasterModel(
      Id: json['Id'] ?? 0,
      CompanyRefId: json['CompanyRefId'] ?? 0,
      EmployeeRefId: json['EmployeeRefId'] ?? 0,
      CNumberDisplay: json['CNumberDisplay'] ?? '',
      EmployeeName: json['EmployeeName'] ?? '',
      PettyCashDate: json['PettyCashDate'] ?? '',
      PaymentStatus: json['PaymentStatus'] ?? '',
      CNumber: json['CNumber'] ?? 0,
      Status: json['Status'] ?? 0,
      Amount: json['Amount'] ?? '0.00',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': Id,
      'CompanyRefId': CompanyRefId,
      'EmployeeRefId': EmployeeRefId,
      'CNumberDisplay': CNumberDisplay,
      'EmployeeName': EmployeeName,
      'PettyCashDate': PettyCashDate,
      'PaymentStatus': PaymentStatus,
      'CNumber': CNumber,
      'Status': Status,
      'Amount': Amount,
    };
  }

  PettyCashMasterModel.Empty()
      : Id = 0,
        CompanyRefId = 0,
        EmployeeRefId = 0,
        CNumberDisplay = '',
        EmployeeName = '',
        PettyCashDate = '',
        PaymentStatus = '',
        CNumber = 0,
        Status = 0,
        Amount = '0.00';
}
class PettyCashDetailsModel {
  int Id;
  int SDId;
  int PettyCashMasterRefId;
  String Notes;
  String Items;
  String Amount;

  PettyCashDetailsModel({
    required this.Id,
    required this.SDId,
    required this.PettyCashMasterRefId,
    required this.Notes,
    required this.Items,
    required this.Amount,
  });

  factory PettyCashDetailsModel.fromJson(Map<String, dynamic> json) {
    return PettyCashDetailsModel(
      Id: json['Id'] ?? 0,
      SDId: json['SDId'] ?? 0,
      PettyCashMasterRefId: json['PettyCashMasterRefId'] ?? 0,
      Notes: json['Notes'] ?? '',
      Items: json['Items'] ?? '',
      Amount: json['Amount'] ?? '0.00',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': Id,
      'SDId': SDId,
      'PettyCashMasterRefId': PettyCashMasterRefId,
      'Notes': Notes,
      'Items': Items,
      'Amount': Amount,
    };
  }

  PettyCashDetailsModel.Empty()
      : Id = 0,
        SDId = 0,
        PettyCashMasterRefId = 0,
        Notes = '',
        Items = '',
        Amount = '0.00';
}

