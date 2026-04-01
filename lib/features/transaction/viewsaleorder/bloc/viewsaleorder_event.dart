

abstract class GetJobNoEvent {}

// Startup — load job list
class GetJobNoStarted extends GetJobNoEvent {}

// BillType radio changed (MY=0, TR=1)
class GetJobNoBillTypeChanged extends GetJobNoEvent {
  final String billType;
  GetJobNoBillTypeChanged(this.billType);
}

// Job No text field changed — triggers autocomplete
class GetJobNoTextChanged extends GetJobNoEvent {
  final String text;
  GetJobNoTextChanged(this.text);
}

// User tapped a suggestion from autocomplete
class GetJobNoSuggestionSelected extends GetJobNoEvent {
  final int saleOrderId;
  final String jobNo;
  GetJobNoSuggestionSelected({required this.saleOrderId, required this.jobNo});
}

// Overlay / suggestion list dismissed
class GetJobNoOverlayDismissed extends GetJobNoEvent {}

// View button pressed
class GetJobNoViewRequested extends GetJobNoEvent {}