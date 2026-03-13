import 'package:maleva/core/models/model.dart';

abstract class PDOViewState {
  const PDOViewState();
}

// ── Loading ───────────────────────────────────────────────────────────────────
class PDOViewLoading extends PDOViewState {
  const PDOViewLoading();
}

// ── Loaded ────────────────────────────────────────────────────────────────────
class PDOViewLoaded extends PDOViewState {
  final List<RTIMasterViewModel> allMasters;
  final List<RTIMasterViewModel> filteredMasters;
  final List<RTIDetailsViewModel> details; // all details (mutable copies)
  final String searchQuery;
  final bool isSaving;
  final int? saveSuccessMasterId; // non-null → show success dialog
  final String? saveError;        // non-null → show error dialog

  const PDOViewLoaded({
    required this.allMasters,
    required this.filteredMasters,
    required this.details,
    this.searchQuery = '',
    this.isSaving = false,
    this.saveSuccessMasterId,
    this.saveError,
  });

  // ── Helper: details that belong to a master ───────────────────────────────
  List<RTIDetailsViewModel> detailsFor(int masterId) =>
      details.where((d) => d.RTIMasterRefId == masterId).toList();

  // ── Helper: only rows that have an image (for card display) ───────────────
  List<RTIDetailsViewModel> detailsWithImageFor(int masterId) =>
      details
          .where((d) =>
      d.RTIMasterRefId == masterId &&
          (d.imagePath ?? '').isNotEmpty)
          .toList();

  PDOViewLoaded copyWith({
    List<RTIMasterViewModel>? allMasters,
    List<RTIMasterViewModel>? filteredMasters,
    List<RTIDetailsViewModel>? details,
    String? searchQuery,
    bool? isSaving,
    int? saveSuccessMasterId,
    String? saveError,
    bool clearSuccess = false,
    bool clearError = false,
  }) {
    return PDOViewLoaded(
      allMasters:          allMasters          ?? this.allMasters,
      filteredMasters:     filteredMasters      ?? this.filteredMasters,
      details:             details              ?? this.details,
      searchQuery:         searchQuery          ?? this.searchQuery,
      isSaving:            isSaving             ?? this.isSaving,
      saveSuccessMasterId: clearSuccess
          ? null
          : (saveSuccessMasterId ?? this.saveSuccessMasterId),
      saveError:           clearError
          ? null
          : (saveError ?? this.saveError),
    );
  }
}

// ── Error ─────────────────────────────────────────────────────────────────────
class PDOViewError extends PDOViewState {
  final String message;
  const PDOViewError(this.message);
}