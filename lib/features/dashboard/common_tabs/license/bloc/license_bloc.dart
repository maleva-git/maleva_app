import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/license_repository.dart'; // Adjust this path if needed
import 'license_event.dart';
import 'license_state.dart';
import 'package:maleva/core/models/shared/license_view_model.dart';

class LicenseBloc extends Bloc<LicenseEvent, LicenseState> {
  final LicenseRepository repository;

  // Constructor now requires the repository instead of BuildContext
  LicenseBloc({required this.repository}) : super(const LicenseInitial()) {
    on<LoadLicenseEvent>(_onLoad);
    on<SearchLicenseEvent>(_onSearch);
  }

  // ── Load Records ────────────────────────────────────────────────────────────
  Future<void> _onLoad(
      LoadLicenseEvent event,
      Emitter<LicenseState> emit,
      ) async {
    emit(const LicenseLoading());

    try {
      // Ask the repository to fetch the data
      final records = await repository.fetchLicenseRecords();

      emit(LicenseLoaded(
        allRecords: records,
        filteredRecords: records,
        searchQuery: '',
      ));
    } catch (e) {
      // Catch network or parsing errors from the repository
      emit(LicenseError(errorMessage: e.toString()));
    }
  }

  // ── Search Filter ────────────────────────────────────────────────────────────
  void _onSearch(
      SearchLicenseEvent event,
      Emitter<LicenseState> emit,
      ) {
    final currentState = state;
    if (currentState is! LicenseLoaded) return;

    final query = event.query.toLowerCase().trim();

    final filtered = query.isEmpty
        ? List<LicenseViewModel>.from(currentState.allRecords)
        : currentState.allRecords
        .where((license) =>
    (license.DriverName ?? '').toLowerCase().contains(query) ||
        (license.licenseNo ?? '').toLowerCase().contains(query) ||
        (license.AccountCode ?? '').toLowerCase().contains(query))
        .toList();

    emit(currentState.copyWith(
      filteredRecords: filtered,
      searchQuery: event.query,
    ));
  }
}