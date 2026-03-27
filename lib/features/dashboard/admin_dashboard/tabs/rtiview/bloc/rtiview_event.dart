abstract class RTIDetailsEvent {
  const RTIDetailsEvent();
}

// ── Initial load ──────────────────────────────────────────────────────────────
class LoadRTIDetailsEvent extends RTIDetailsEvent {
  const LoadRTIDetailsEvent();
}

// ── Date pickers ──────────────────────────────────────────────────────────────
class SelectRTIDetailsFromDateEvent extends RTIDetailsEvent {
  final DateTime date;
  const SelectRTIDetailsFromDateEvent(this.date);
}

class SelectRTIDetailsToDateEvent extends RTIDetailsEvent {
  final DateTime date;
  const SelectRTIDetailsToDateEvent(this.date);
}

// ── Search button ─────────────────────────────────────────────────────────────
class SearchRTIDetailsEvent extends RTIDetailsEvent {
  const SearchRTIDetailsEvent();
}