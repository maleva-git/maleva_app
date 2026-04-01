
abstract class FWUpdateEvent {}

// Startup
class FWUpdateStarted extends FWUpdateEvent {}

// Tab change
class FWUpdateTabChanged extends FWUpdateEvent {
  final int tabIndex;
  FWUpdateTabChanged(this.tabIndex);
}

// SMK autocomplete text changed (type: 1,2,3)
class FWUpdateSmkTextChanged extends FWUpdateEvent {
  final int type;
  final String text;
  FWUpdateSmkTextChanged({required this.type, required this.text});
}

// Suggestion selected from autocomplete
class FWUpdateSmkSuggestionSelected extends FWUpdateEvent {
  final int type;
  final int saleOrderId;
  final String smkText;
  FWUpdateSmkSuggestionSelected({
    required this.type,
    required this.saleOrderId,
    required this.smkText,
  });
}

// Autocomplete overlay dismissed
class FWUpdateOverlayDismissed extends FWUpdateEvent {}

// Employee (Seal By) changed
class FWUpdateSealEmpChanged extends FWUpdateEvent {
  final int type; // 1,2,3
  final int empId;
  final String empName;
  FWUpdateSealEmpChanged(
      {required this.type, required this.empId, required this.empName});
}

class FWUpdateSealEmpCleared extends FWUpdateEvent {
  final int type;
  FWUpdateSealEmpCleared(this.type);
}

// Employee (Break Seal By) changed
class FWUpdateBreakEmpChanged extends FWUpdateEvent {
  final int type;
  final int empId;
  final String empName;
  FWUpdateBreakEmpChanged(
      {required this.type, required this.empId, required this.empName});
}

class FWUpdateBreakEmpCleared extends FWUpdateEvent {
  final int type;
  FWUpdateBreakEmpCleared(this.type);
}

// EX Ref text changed
class FWUpdateExRefChanged extends FWUpdateEvent {
  final int type;
  final String value;
  FWUpdateExRefChanged({required this.type, required this.value});
}

// Image upload checkbox toggle
class FWUpdateImageUploadToggled extends FWUpdateEvent {
  final int type;
  final bool value;
  FWUpdateImageUploadToggled({required this.type, required this.value});
}

// Image picked (from gallery or camera)
class FWUpdateImagePicked extends FWUpdateEvent {
  final int type;
  final String imageUrl; // returned from objfun.upload
  FWUpdateImagePicked({required this.type, required this.imageUrl});
}

// Image deleted
class FWUpdateImageDeleted extends FWUpdateEvent {
  final int type;
  final int index;
  FWUpdateImageDeleted({required this.type, required this.index});
}

// Save / Update forwarding
class FWUpdateSaveRequested extends FWUpdateEvent {}