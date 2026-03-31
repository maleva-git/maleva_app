

abstract class EnquiryViewState {}

class EnquiryViewInitial extends EnquiryViewState {}

class EnquiryViewLoading extends EnquiryViewState {}

class EnquiryViewLoaded extends EnquiryViewState {
  // Filter values
  final String fromDate;
  final String toDate;
  final int custId;
  final String custName;
  final int jobId;
  final String jobName;
  final int empId;
  final String empName;
  final bool checkLEmp;
  final bool checkEnq;

  // List
  final List<dynamic> masterList;

   EnquiryViewLoaded({
    required this.fromDate,
    required this.toDate,
    required this.custId,
    required this.custName,
    required this.jobId,
    required this.jobName,
    required this.empId,
    required this.empName,
    required this.checkLEmp,
    required this.checkEnq,
    required this.masterList,
  });

  EnquiryViewLoaded copyWith({
    String? fromDate,
    String? toDate,
    int? custId,
    String? custName,
    int? jobId,
    String? jobName,
    int? empId,
    String? empName,
    bool? checkLEmp,
    bool? checkEnq,
    List<dynamic>? masterList,
  }) {
    return EnquiryViewLoaded(
      fromDate:   fromDate   ?? this.fromDate,
      toDate:     toDate     ?? this.toDate,
      custId:     custId     ?? this.custId,
      custName:   custName   ?? this.custName,
      jobId:      jobId      ?? this.jobId,
      jobName:    jobName    ?? this.jobName,
      empId:      empId      ?? this.empId,
      empName:    empName    ?? this.empName,
      checkLEmp:  checkLEmp  ?? this.checkLEmp,
      checkEnq:   checkEnq   ?? this.checkEnq,
      masterList: masterList ?? this.masterList,
    );
  }
}

class EnquiryViewError extends EnquiryViewState {
  final String message;
  EnquiryViewError(this.message);
}

// Navigation states
class EnquiryViewNavigateToEdit extends EnquiryViewState {
  final Map<String, dynamic> item;
  EnquiryViewNavigateToEdit(this.item);
}

class EnquiryViewNavigateToPushSaleOrder extends EnquiryViewState {
  final List<dynamic> enquiryList;
  EnquiryViewNavigateToPushSaleOrder(this.enquiryList);
}

class EnquiryViewShowDetails extends EnquiryViewState {
  final Map<String, dynamic> item;
  EnquiryViewShowDetails(this.item);
}