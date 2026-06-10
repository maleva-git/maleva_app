import 'package:flutter/Material.dart';

abstract class FWUpdateEvent {}
class FWUpdateStarted extends FWUpdateEvent {}
class FWUpdateTabChanged extends FWUpdateEvent { final int tabIndex; FWUpdateTabChanged(this.tabIndex); }
class FWUpdateSmkTextChanged extends FWUpdateEvent { final int type; final String text; FWUpdateSmkTextChanged({required this.type, required this.text}); }
class FWUpdateSmkSuggestionSelected extends FWUpdateEvent {
  final BuildContext context; // Context added here!
  final int type;
  final int saleOrderId;
  final String smkText;

  FWUpdateSmkSuggestionSelected({
    required this.context,
    required this.type,
    required this.saleOrderId,
    required this.smkText,
  });
}
class FWUpdateOverlayDismissed extends FWUpdateEvent {}
class FWUpdateSealEmpChanged extends FWUpdateEvent { final int type, empId; final String empName; FWUpdateSealEmpChanged({required this.type, required this.empId, required this.empName}); }
class FWUpdateSealEmpCleared extends FWUpdateEvent { final int type; FWUpdateSealEmpCleared(this.type); }
class FWUpdateBreakEmpChanged extends FWUpdateEvent { final int type, empId; final String empName; FWUpdateBreakEmpChanged({required this.type, required this.empId, required this.empName}); }
class FWUpdateBreakEmpCleared extends FWUpdateEvent { final int type; FWUpdateBreakEmpCleared(this.type); }
class FWUpdateEnRefChanged extends FWUpdateEvent { final int type; final String value; FWUpdateEnRefChanged({required this.type, required this.value}); }
class FWUpdateExRefChanged extends FWUpdateEvent { final int type; final String value; FWUpdateExRefChanged({required this.type, required this.value}); }
class FWUpdateImageUploadToggled extends FWUpdateEvent { final int type; final bool value; FWUpdateImageUploadToggled({required this.type, required this.value}); }
class FWUpdateImagePicked extends FWUpdateEvent { final int type; final String imageUrl; FWUpdateImagePicked({required this.type, required this.imageUrl}); }
class FWUpdateImageDeleted extends FWUpdateEvent { final int type, index; FWUpdateImageDeleted({required this.type, required this.index}); }
class FWUpdateSaveRequested extends FWUpdateEvent {}