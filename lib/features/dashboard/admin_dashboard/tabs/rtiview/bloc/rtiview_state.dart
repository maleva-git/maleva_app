import 'package:maleva/core/models/model.dart';

abstract class RTIDetailsState {
  const RTIDetailsState();
}

// ── Loaded (single state — copyWith pattern) ──────────────────────────────────
class RTIDetailsLoaded extends RTIDetailsState {
  final DateTime fromDate;
  final DateTime toDate;
  final List<RTIMasterViewModel> masters;
  final List<RTIDetailsViewModel> details;
  final bool isLoading;

  const RTIDetailsLoaded({
    required this.fromDate,
    required this.toDate,
    this.masters  = const [],
    this.details  = const [],
    this.isLoading = false,
  });

  // ── Helper: details for a specific master ─────────────────────────────────
  List<RTIDetailsViewModel> detailsFor(int masterId) =>
      details.where((d) => d.RTIMasterRefId == masterId).toList();

  RTIDetailsLoaded copyWith({
    DateTime? fromDate,
    DateTime? toDate,
    List<RTIMasterViewModel>? masters,
    List<RTIDetailsViewModel>? details,
    bool? isLoading,
  }) {
    return RTIDetailsLoaded(
      fromDate:  fromDate  ?? this.fromDate,
      toDate:    toDate    ?? this.toDate,
      masters:   masters   ?? this.masters,
      details:   details   ?? this.details,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// ── Error ─────────────────────────────────────────────────────────────────────
class RTIDetailsError extends RTIDetailsState {
  final String message;
  final DateTime fromDate;
  final DateTime toDate;

  const RTIDetailsError({
    required this.message,
    required this.fromDate,
    required this.toDate,
  });
}

class RTIPdfState  extends RTIDetailsState {
  final bool isLoading;
  const RTIPdfState({this.isLoading = false});

  RTIPdfState copywith({bool? isLoading}) {
    return RTIPdfState(
      isLoading: isLoading ?? this.isLoading,
    );
  }
}