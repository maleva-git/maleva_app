// license_bloc.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/models/model.dart'; // Update path
import 'package:maleva/core/utils/clsfunction.dart' as objfun;

import 'license_event.dart';
import 'license_state.dart';

class LicenseBloc extends Bloc<LicenseEvent, LicenseState> {
  final BuildContext context;

  LicenseBloc(this.context) : super(const LicenseInitial()) {
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
      final comid = objfun.storagenew.getInt('Comid') ?? 0;
      const keyword = '';

      final Map<String, String> header = {
        'Content-Type': 'application/json; charset=UTF-8',
      };

      final apiUrl =
          "${objfun.apiDriverViewRecords}$comid&Startindex=0&PageCount=100&keyword=$keyword&Column=";

      final resultData = await objfun.apiAllinoneSelectArray(
        apiUrl,
        '',
        header,
        context,
      );

      if (resultData != null && resultData is Map<String, dynamic>) {
        final dataList = resultData['Data1'];

        if (dataList != null && dataList is List && dataList.isNotEmpty) {
          final List<LicenseViewModel> records = dataList
              .map((item) =>
              LicenseViewModel.fromJson(item as Map<String, dynamic>))
              .toList();

          emit(LicenseLoaded(
            allRecords: records,
            filteredRecords: records,
            searchQuery: '',
          ));
          return;
        }
      }

      emit(const LicenseLoaded(
        allRecords: [],
        filteredRecords: [],
      ));
    } catch (e) {
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
    (license.DriverName ?? '')
        .toLowerCase()
        .contains(query) ||
        (license.licenseNo ?? '')
            .toLowerCase()
            .contains(query) ||
        (license.AccountCode ?? '')
            .toLowerCase()
            .contains(query))
        .toList();

    emit(currentState.copyWith(
      filteredRecords: filtered,
      searchQuery: event.query,
    ));
  }
}