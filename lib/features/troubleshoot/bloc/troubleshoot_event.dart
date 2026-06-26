abstract class TroubleshootEvent {}

/// User typed an optional note describing the problem.
class TroubleshootNoteChanged extends TroubleshootEvent {
  final String note;
  TroubleshootNoteChanged(this.note);
}

/// User tapped "Send Report".
class TroubleshootSubmitted extends TroubleshootEvent {}

/// Reset the form (e.g. after closing the success dialog).
class TroubleshootReset extends TroubleshootEvent {}
