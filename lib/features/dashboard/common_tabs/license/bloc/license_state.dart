import 'package:maleva/core/models/shared/license_view_model.dart';
// license_state.dart

 // Update path

abstract class LicenseState {
  const LicenseState();
}

class LicenseInitial extends LicenseState {
  const LicenseInitial();
}

class LicenseLoading extends LicenseState {
  const LicenseLoading();
}

class LicenseLoaded extends LicenseState {
  final List<LicenseViewModel> allRecords;
  final List<LicenseViewModel> filteredRecords;
  final String searchQuery;

  const LicenseLoaded({
    required this.allRecords,
    required this.filteredRecords,
    this.searchQuery = '',
  });

  LicenseLoaded copyWith({
    List<LicenseViewModel>? allRecords,
    List<LicenseViewModel>? filteredRecords,
    String? searchQuery,
  }) {
    return LicenseLoaded(
      allRecords: allRecords ?? this.allRecords,
      filteredRecords: filteredRecords ?? this.filteredRecords,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class LicenseError extends LicenseState {
  final String errorMessage;
  const LicenseError({required this.errorMessage});
}