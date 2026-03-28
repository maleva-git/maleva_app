

abstract class EnquiryEvent {}

class LoadEnquiryEvent extends EnquiryEvent {}

class CancelEnquiryEvent extends EnquiryEvent {
  final int id;
  CancelEnquiryEvent(this.id);
}