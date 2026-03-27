
abstract class TransportEvent  {
  const TransportEvent();

  @override
  List<Object?> get props => [];
}

// ── Load today / tomorrow data ─────────────────────────────────────────────────
class LoadTransportDataEvent extends TransportEvent {
  final int type; // 0 = today, 1 = tomorrow
  const LoadTransportDataEvent({required this.type});

  @override
  List<Object?> get props => [type];
}

// ── Tap on a card → show detail dialog ────────────────────────────────────────
class TapTransportItemEvent extends TransportEvent {
  final Map<String, dynamic> item;
  const TapTransportItemEvent({required this.item});

  @override
  List<Object?> get props => [item];
}

// ── Long press → open edit screen ─────────────────────────────────────────────
class LongPressTransportItemEvent extends TransportEvent {
  final int id;
  const LongPressTransportItemEvent({required this.id});

  @override
  List<Object?> get props => [id];
}