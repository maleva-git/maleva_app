abstract class PDOViewEvent {
  const PDOViewEvent();
}

// ── Initial load ──────────────────────────────────────────────────────────────
class LoadPDOViewEvent extends PDOViewEvent {
  const LoadPDOViewEvent();
}

// ── Search bar ────────────────────────────────────────────────────────────────
class SearchPDOEvent extends PDOViewEvent {
  final String query;
  const SearchPDOEvent(this.query);
}

// ── Verify checkbox per detail row ────────────────────────────────────────────
class TogglePDOVerifyEvent extends PDOViewEvent {
  final int detailId;
  final bool value;
  const TogglePDOVerifyEvent({required this.detailId, required this.value});
}

// ── Save (Verify button tap) ──────────────────────────────────────────────────
class SavePDOEvent extends PDOViewEvent {
  final int masterId;
  const SavePDOEvent(this.masterId);
}

// ── Reset save status after dialog shown ─────────────────────────────────────
class ResetPDOSaveStatusEvent extends PDOViewEvent {
  const ResetPDOSaveStatusEvent();
}