import 'package:maleva/core/models/model.dart';

abstract class RTIDetailsState {
  const RTIDetailsState();
}

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

class RTIDetailsError extends RTIDetailsState {
  final String message;
  final DateTime? fromDate;
  final DateTime? toDate;

  const RTIDetailsError({required this.message, this.fromDate, this.toDate});
}

// ✅ NEW: Tells UI to open the browser
class RTIPdfLaunchSuccess extends RTIDetailsState {
  final String url;
  const RTIPdfLaunchSuccess(this.url);
}

// ✅ NEW: Tells UI a specific action failed (like PDF fetch)
class RTIActionError extends RTIDetailsState {
  final String message;
  const RTIActionError(this.message);
}