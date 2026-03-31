

abstract class EnquiryViewEvent {}

// Startup
class EnquiryViewStarted extends EnquiryViewEvent {}

// Filter fields
class EnquiryViewFromDateChanged extends EnquiryViewEvent {
  final String date;
  EnquiryViewFromDateChanged(this.date);
}

class EnquiryViewToDateChanged extends EnquiryViewEvent {
  final String date;
  EnquiryViewToDateChanged(this.date);
}

class EnquiryViewCustomerChanged extends EnquiryViewEvent {
  final int custId;
  final String custName;
  EnquiryViewCustomerChanged({required this.custId, required this.custName});
}

class EnquiryViewCustomerCleared extends EnquiryViewEvent {}

class EnquiryViewJobTypeChanged extends EnquiryViewEvent {
  final int jobId;
  final String jobName;
  EnquiryViewJobTypeChanged({required this.jobId, required this.jobName});
}

class EnquiryViewJobTypeCleared extends EnquiryViewEvent {}

class EnquiryViewEmployeeChanged extends EnquiryViewEvent {
  final int empId;
  final String empName;
  EnquiryViewEmployeeChanged({required this.empId, required this.empName});
}

class EnquiryViewEmployeeCleared extends EnquiryViewEvent {}

class EnquiryViewCheckboxChanged extends EnquiryViewEvent {
  final String field; // 'lEmp', 'enq'
  final bool value;
  EnquiryViewCheckboxChanged({required this.field, required this.value});
}

// Load data
class EnquiryViewLoadRequested extends EnquiryViewEvent {
  final bool useDate;
  EnquiryViewLoadRequested({this.useDate = false});
}

// Row actions
class EnquiryViewCancelRequested extends EnquiryViewEvent {
  final int id;
  EnquiryViewCancelRequested(this.id);
}

class EnquiryViewPushToSaleOrder extends EnquiryViewEvent {
  final int index;
  EnquiryViewPushToSaleOrder(this.index);
}

class EnquiryViewDetailsRequested extends EnquiryViewEvent {
  final Map<String, dynamic> item;
  EnquiryViewDetailsRequested(this.item);
}

class EnquiryViewEditRequested extends EnquiryViewEvent {
  final Map<String, dynamic> item;
  EnquiryViewEditRequested(this.item);
}

class EnquiryViewShareRequested extends EnquiryViewEvent {
  final int id;
  final String planningNo;
  EnquiryViewShareRequested({required this.id, required this.planningNo});
}