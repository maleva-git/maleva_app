import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/utils/json_read.dart';

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

  /// One job of an RTI in the shared Java list (`jobs` of
  /// `/api/rti-masters/with-jobs`), with its latest RTI status (`statusId`,
  /// `active`, `verify`, `imagePath`; .NET SelectRTIView), so PDO and
  /// TransportDB update that status instead of adding another.
  RTIDetailsViewModel.fromJava(Map<String, dynamic> json)
      : Id = JsonRead.integer(json['id']),
        SDId = 0,
        RTIMasterRefId = JsonRead.integer(json['rtiMasterRefId']),
        StatusId = JsonRead.integer(json['statusId']),
        SaleOrderMasterRefId = JsonRead.integer(json['saleOrderMasterRefId']),
        CustomerMasterRefId = JsonRead.integer(json['customerMasterRefId']),
        JobNo = JsonRead.string(json['jobNo']),
        JobDate = _dmy(json['jobDate']),
        CustomerName = JsonRead.string(json['customerName']),
        Salary = JsonRead.number(json['salary']),
        PPIC = JsonRead.string(json['ppic']),
        DPIC = JsonRead.string(json['dpic']),
        PWDType = 0,
        Active = JsonRead.integer(json['active']),
        Verify = JsonRead.integer(json['verify']),
        imagePath = JsonRead.string(json['imagePath']),
        isChecked = JsonRead.integer(json['active']) == 1,
        isVerified = JsonRead.integer(json['verify']) == 1;

  static String _dmy(dynamic value) {
    final d = JsonRead.date(value);
    return d == null ? '' : DateFormat('dd/MM/yyyy').format(d);
  }

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