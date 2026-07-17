import '../../../../../core/models/model.dart';
import 'package:maleva/features/transaction/enquirytrmaster/models/enquiry_master_model.dart';

abstract class EnquiryAddEvent {}

// Startup — pass existing SaleMaster for edit mode
class EnquiryAddStarted extends EnquiryAddEvent {
  final EnquiryMasterModel? saleMaster;
  EnquiryAddStarted({this.saleMaster});
}

// Field changes
class EnquiryAddCustomerChanged extends EnquiryAddEvent {
  final int custId;
  final String custName;
  EnquiryAddCustomerChanged({required this.custId, required this.custName});
}

class EnquiryAddCustomerCleared extends EnquiryAddEvent {}

class EnquiryAddJobTypeChanged extends EnquiryAddEvent {
  final int jobTypeId;
  final String jobTypeName;
  EnquiryAddJobTypeChanged({required this.jobTypeId, required this.jobTypeName});
}

class EnquiryAddJobTypeCleared extends EnquiryAddEvent {}

class EnquiryAddOriginChanged extends EnquiryAddEvent {
  final int originId;
  final String originName;
  EnquiryAddOriginChanged({required this.originId, required this.originName});
}

class EnquiryAddOriginCleared extends EnquiryAddEvent {}

class EnquiryAddDestinationChanged extends EnquiryAddEvent {
  final int destinationId;
  final String destinationName;
  EnquiryAddDestinationChanged(
      {required this.destinationId, required this.destinationName});
}

class EnquiryAddDestinationCleared extends EnquiryAddEvent {}

class EnquiryAddNotifyDateChanged extends EnquiryAddEvent {
  final String date;
  EnquiryAddNotifyDateChanged(this.date);
}

class EnquiryAddCollectionDateChanged extends EnquiryAddEvent {
  final String date;
  EnquiryAddCollectionDateChanged(this.date);
}

class EnquiryAddDeliveryDateChanged extends EnquiryAddEvent {
  final String date;
  EnquiryAddDeliveryDateChanged(this.date);
}

class EnquiryAddCheckboxChanged extends EnquiryAddEvent {
  final String field; // 'collection', 'delivery', 'oeta'
  final bool value;
  EnquiryAddCheckboxChanged({required this.field, required this.value});
}

class EnquiryAddTextChanged extends EnquiryAddEvent {
  final String field; // 'quantity', 'weight', 'lPort', 'oPort'
  final String value;
  EnquiryAddTextChanged({required this.field, required this.value});
}

// Save
// Fetch events
class EnquiryAddFetchCurrency extends EnquiryAddEvent {
  final int customerId;
  EnquiryAddFetchCurrency(this.customerId);
}

class EnquiryAddFetchJobStatuses extends EnquiryAddEvent {
  final int jobId;
  EnquiryAddFetchJobStatuses(this.jobId);
}

class EnquiryAddSaveRequested extends EnquiryAddEvent {}

// Clear form
class EnquiryAddClearRequested extends EnquiryAddEvent {}