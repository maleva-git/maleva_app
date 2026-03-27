

abstract class TransportState  {
  const TransportState();

  @override
  List<Object?> get props => [];
}

// ── Initial ────────────────────────────────────────────────────────────────────
class TransportInitial extends TransportState {
  const TransportInitial();
}

// ── Loading ────────────────────────────────────────────────────────────────────
class TransportLoadingState extends TransportState {
  const TransportLoadingState();
}

// ── Loaded — carries the list + toggle state ───────────────────────────────────
class TransportLoadedState extends TransportState {
  final List<Map<String, dynamic>> transportList;
  final bool isPlanToday;

  const TransportLoadedState({
    required this.transportList,
    required this.isPlanToday,
  });

  @override
  List<Object?> get props => [transportList, isPlanToday];
}

// ── Error ──────────────────────────────────────────────────────────────────────
class TransportErrorState extends TransportState {
  final String errorMessage;
  const TransportErrorState({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}

// ── Navigate to edit screen (carries fetched sale data) ───────────────────────
class TransportNavigateToEditState extends TransportState {
  const TransportNavigateToEditState();
}