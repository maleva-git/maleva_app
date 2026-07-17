import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

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
      : Id = int.tryParse(json['Id']?.toString() ?? '') ?? 0,
        SDId = int.tryParse(json['SDId']?.toString() ?? '') ?? 0,
        RTIMasterRefId = int.tryParse(json['RTIMasterRefId']?.toString() ?? '') ?? 0,
        StatusId = int.tryParse(json['StatusId']?.toString() ?? '') ?? 0,
        SaleOrderMasterRefId = int.tryParse(json['SaleOrderMasterRefId']?.toString() ?? '') ?? 0,
        CustomerMasterRefId = int.tryParse(json['CustomerMasterRefId']?.toString() ?? '') ?? 0,
        JobNo = json['JobNo'] ?? '',
        JobDate = json['JobDate'] ?? '',
        CustomerName = json['CustomerName'] ?? '',
        Salary = double.parse(json['Salary'].toString()),
        PPIC = json['PPIC'] ?? '',
        DPIC = json['DPIC'] ?? '',
        PWDType = int.tryParse(json['PWDType']?.toString() ?? '') ?? 0,
        Active = int.tryParse(json['Active']?.toString() ?? '') ?? 0,
        Verify = int.tryParse(json['Verify']?.toString() ?? '') ?? 0,
        imagePath = json['ImagePath'] ?? '',
        isChecked = (int.tryParse(json['Active']?.toString() ?? '') ?? 0) == 1,
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