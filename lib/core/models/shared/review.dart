import 'package:maleva/core/utils/json_read.dart';


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

  /// A review of the shared Java list (`/api/google-reviews`).
  Review.fromJava(Map<String, dynamic> j)
      : id = JsonRead.integer(j['id']),
        shopName = JsonRead.string(j['shopName']),
        mobileNo = JsonRead.stringOrNull(j['mobileNo']),
        googleReview = j['googleReview']?.toString(),
        googleMsg = JsonRead.stringOrNull(j['googleMsg']),
        supportDate = JsonRead.date(j['refDate']) ?? DateTime.now(),
        empReffid = JsonRead.integer(j['employeeRefId']),
        employeeName = JsonRead.stringOrNull(j['employeeName']);

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