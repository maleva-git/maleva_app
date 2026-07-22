
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