abstract class RTIDetailsEvent {
  const RTIDetailsEvent();
}


class LoadRTIDetailsEvent extends RTIDetailsEvent {
  const LoadRTIDetailsEvent();
}


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

class RTIViewEvent extends RTIDetailsEvent {
  final int id;
  final String rtiNo;

  const RTIViewEvent({
    required this.id,
    required this.rtiNo,
  });
}