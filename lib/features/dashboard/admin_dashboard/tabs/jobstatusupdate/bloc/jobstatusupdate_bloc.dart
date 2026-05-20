import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/network/OnlineApi.dart' as OnlineApi;
import 'package:maleva/core/utils/clsfunction.dart' as objfun;

import 'jobstatusupdate_event.dart';
import 'jobstatusupdate_state.dart';



class JobStatusUpdateBloc
    extends Bloc<JobStatusUpdateEvent, JobStatusUpdateState> {
  JobStatusUpdateBloc()
      : super(JobStatusUpdateState(
    dtpStartTime:
    DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
    dtpEndTime:
    DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
    userName: objfun.storagenew.getString('Username') ?? '',
  )) {
    on<JobStatusUpdateStarted>(_onStarted);
    on<JobStatusUpdateBillTypeChanged>(_onBillTypeChanged);
    on<JobStatusUpdateJobNoChanged>(_onJobNoChanged);
    on<JobStatusUpdateSuggestionSelected>(_onSuggestionSelected);
    on<JobStatusUpdateLoadData>(_onLoadData);
    on<JobStatusUpdateStatusSelected>(_onStatusSelected);
    on<JobStatusUpdateStatusCleared>(_onStatusCleared);
    on<JobStatusUpdateStartTimeToggled>(_onStartTimeToggled);
    on<JobStatusUpdateEndTimeToggled>(_onEndTimeToggled);
    on<JobStatusUpdateImageUploadToggled>(_onImageUploadToggled);
    on<JobStatusUpdateStartTimePicked>(_onStartTimePicked);
    on<JobStatusUpdateEndTimePicked>(_onEndTimePicked);
    on<JobStatusUpdateImagePicked>(_onImagePicked);
    on<JobStatusUpdateImageDeleted>(_onImageDeleted);
    on<JobStatusUpdateSubmitted>(_onSubmitted);
    on<JobStatusUpdateMailSent>(_onMailSent);
    on<JobStatusUpdateFormCleared>(_onFormCleared);
    on<JobStatusUpdateOverlayCleared>(_onOverlayCleared);
  }

  // ─── Startup ───────────────────────────────────────────────────────────────

  Future<void> _onStarted(
      JobStatusUpdateStarted event, Emitter<JobStatusUpdateState> emit) async {
    emit(state.copyWith(status: JobStatusUpdateStatus.loading));
    await _loadJobNoList(billType: state.billType);
    emit(state.copyWith(status: JobStatusUpdateStatus.success));
  }

  // ─── Bill type changed ─────────────────────────────────────────────────────

  Future<void> _onBillTypeChanged(
      JobStatusUpdateBillTypeChanged event,
      Emitter<JobStatusUpdateState> emit) async {
    emit(state.copyWith(
      billType: event.billType,
      status: JobStatusUpdateStatus.loading,
    ));
    await _loadJobNoList(billType: event.billType);
    emit(state.copyWith(status: JobStatusUpdateStatus.success));
  }

  Future<void> _loadJobNoList({required String billType}) async {
    await OnlineApi.GetJobNoForwarding(null, int.parse(billType));
    final suggestions = objfun.JobNoList
        .map<Map<String, dynamic>>((e) => {
      'CNumber': e['CNumber']?.toString() ?? '',
      'Id': e['Id'] ?? 0,
    })
        .toList();
    // We update the bloc's internal suggestion list via a silent state update
    // The emitter may have already closed in callers; store in a field instead.
    _cachedSuggestions = suggestions;
  }

  // ─── Internal suggestion cache (not in state to avoid re-renders) ──────────
  List<Map<String, dynamic>> _cachedSuggestions = [];

  // ─── Job No text changed ───────────────────────────────────────────────────

  Future<void> _onJobNoChanged(
      JobStatusUpdateJobNoChanged event,
      Emitter<JobStatusUpdateState> emit) async {
    final query = event.value.trim();
    emit(state.copyWith(jobNo: query));

    if (query.isEmpty) {
      emit(state.copyWith(
        showAutocompleteOverlay: false,
        autocompleteSuggestions: const [],
        action: JobStatusUpdateAction.hideAutocomplete,
      ));
      return;
    }

    final filtered = _cachedSuggestions
        .where((e) =>
        e['CNumber'].toString().toUpperCase().contains(query.toUpperCase()))
        .toList();

    if (filtered.isEmpty) {
      emit(state.copyWith(
        showAutocompleteOverlay: false,
        autocompleteSuggestions: const [],
        action: JobStatusUpdateAction.hideAutocomplete,
      ));
      return;
    }

    emit(state.copyWith(
      autocompleteSuggestions: filtered,
      showAutocompleteOverlay: true,
      action: JobStatusUpdateAction.showAutocomplete,
    ));
  }

  // ─── Suggestion selected ───────────────────────────────────────────────────

  Future<void> _onSuggestionSelected(
      JobStatusUpdateSuggestionSelected event,
      Emitter<JobStatusUpdateState> emit) async {
    emit(state.copyWith(
      jobNo: event.jobNo,
      saleOrderId: event.saleOrderId,
      showAutocompleteOverlay: false,
      autocompleteSuggestions: const [],
      action: JobStatusUpdateAction.hideAutocomplete,
      imageNetworkNames: const [],
      status: JobStatusUpdateStatus.loading,
    ));
    await _fetchJobData(emit,
        saleOrderId: event.saleOrderId, jobNo: event.jobNo);
    emit(state.copyWith(status: JobStatusUpdateStatus.success));
  }

  // ─── Load data after job selected ─────────────────────────────────────────

  Future<void> _onLoadData(
      JobStatusUpdateLoadData event,
      Emitter<JobStatusUpdateState> emit) async {
    if (state.jobNo.isEmpty) return;
    emit(state.copyWith(status: JobStatusUpdateStatus.loading));
    await _fetchJobData(emit,
        saleOrderId: state.saleOrderId, jobNo: state.jobNo);
    emit(state.copyWith(status: JobStatusUpdateStatus.success));
  }

  Future<void> _fetchJobData(
      Emitter<JobStatusUpdateState> emit,
      {required int saleOrderId, required String jobNo}) async {
    try {
      await OnlineApi.EditSalesOrder(null, saleOrderId, int.tryParse(jobNo) ?? 0);
      await OnlineApi.SelectAllJobStatus(
          null, objfun.SaleEditMasterList[0]['JobMasterRefId'] as int);

      String statusName = '';
      int statusId = 0;

      final jStatus = objfun.SaleEditMasterList[0]['JStatus'];
      if (jStatus != null && jStatus != 0) {
        statusId = jStatus as int;
        final match = objfun.JobAllStatusList
            .where((s) => s.Status == statusId)
            .toList();
        if (match.isNotEmpty) {
          statusName = match[0].StatusName;
        }
      }

      // ── Fetch images ────────────────────────────────────────────────────
      final imageDir =
          '/Upload/${objfun.Comid}/SalesOrder/$saleOrderId/Boarding/';
      final header = {'Content-Type': 'application/json; charset=UTF-8'};

      final imageResult = await _safeApiCall(() =>
          objfun.apiAllinoneSelectArray(
              '${objfun.apiGetimage}$imageDir', null, header, null));

      final images = <String>[];
      if (imageResult is List && imageResult.isNotEmpty) {
        for (var img in imageResult) {
          images.add(img.toString());
        }
      }

      emit(state.copyWith(
        statusName: statusName,
        statusId: statusId,
        imageNetworkNames: images,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: JobStatusUpdateStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  // ─── Status selected / cleared ────────────────────────────────────────────

  void _onStatusSelected(
      JobStatusUpdateStatusSelected event,
      Emitter<JobStatusUpdateState> emit) {
    emit(state.copyWith(
      statusName: event.statusName,
      statusId: event.statusId,
      action: JobStatusUpdateAction.none,
    ));
  }

  void _onStatusCleared(
      JobStatusUpdateStatusCleared event,
      Emitter<JobStatusUpdateState> emit) {
    emit(state.copyWith(
      statusName: '',
      statusId: 0,
    ));
  }

  // ─── Checkboxes ───────────────────────────────────────────────────────────

  void _onStartTimeToggled(
      JobStatusUpdateStartTimeToggled event,
      Emitter<JobStatusUpdateState> emit) {
    emit(state.copyWith(checkBoxStartTime: event.value));
  }

  void _onEndTimeToggled(
      JobStatusUpdateEndTimeToggled event,
      Emitter<JobStatusUpdateState> emit) {
    emit(state.copyWith(checkBoxEndTime: event.value));
  }

  void _onImageUploadToggled(
      JobStatusUpdateImageUploadToggled event,
      Emitter<JobStatusUpdateState> emit) {
    emit(state.copyWith(checkBoxImageUpload: event.value));
  }

  // ─── Date/time pickers ────────────────────────────────────────────────────

  void _onStartTimePicked(
      JobStatusUpdateStartTimePicked event,
      Emitter<JobStatusUpdateState> emit) {
    emit(state.copyWith(dtpStartTime: event.dateTime));
  }

  void _onEndTimePicked(
      JobStatusUpdateEndTimePicked event,
      Emitter<JobStatusUpdateState> emit) {
    emit(state.copyWith(dtpEndTime: event.dateTime));
  }

  // ─── Image picked (after upload) ──────────────────────────────────────────

  void _onImagePicked(
      JobStatusUpdateImagePicked event,
      Emitter<JobStatusUpdateState> emit) {
    final updated = List<String>.from(state.imageNetworkNames)
      ..add(event.imageName);
    emit(state.copyWith(imageNetworkNames: updated));
  }

  // ─── Image deleted ────────────────────────────────────────────────────────

  Future<void> _onImageDeleted(
      JobStatusUpdateImageDeleted event,
      Emitter<JobStatusUpdateState> emit) async {
    if (state.jobNo.isEmpty) return;

    emit(state.copyWith(status: JobStatusUpdateStatus.loading));

    final index = event.index;
    final imageName = state.imageNetworkNames[index];
    final filePath =
        '/Upload/${objfun.Comid}/SalesOrder/${state.saleOrderId}/Boarding/$imageName';

    final header = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Comid': objfun.Comid.toString(),
      'Id': state.saleOrderId.toString(),
      'FolderName': 'SalesOrder',
      'FileName': filePath,
      'SubFolderName': 'Boarding',
    };

    final result = await _safeApiCall(() => objfun.apiAllinoneSelectArray(
        objfun.apiDeleteimage, null, header, null));

    if (result != null) {
      try {
        final value = ResponseViewModel.fromJson(result);
        if (value.IsSuccess == true) {
          final updated = List<String>.from(state.imageNetworkNames)
            ..removeAt(index);
          emit(state.copyWith(
            imageNetworkNames: updated,
            status: JobStatusUpdateStatus.success,
          ));
          return;
        } else {
          emit(state.copyWith(
            status: JobStatusUpdateStatus.failure,
            errorMessage: value.Message,
          ));
          return;
        }
      } catch (_) {}
    }

    emit(state.copyWith(status: JobStatusUpdateStatus.success));
  }

  // ─── Submit boarding details ──────────────────────────────────────────────

  Future<void> _onSubmitted(
      JobStatusUpdateSubmitted event,
      Emitter<JobStatusUpdateState> emit) async {
    // Validation
    if (!state.isFormReady) {
      emit(state.copyWith(
        status: JobStatusUpdateStatus.failure,
        errorMessage: 'Enter Details to update',
      ));
      return;
    }
    if (state.checkBoxImageUpload && state.imageNetworkNames.isEmpty) {
      emit(state.copyWith(
        status: JobStatusUpdateStatus.failure,
        errorMessage: 'Select Images !!',
      ));
      return;
    }

    emit(state.copyWith(status: JobStatusUpdateStatus.loading));

    final header = {'Content-Type': 'application/json; charset=UTF-8'};
    final master = {
      'Id': state.saleOrderId,
      'Comid': objfun.Comid,
      'Jobid': state.jobNo,
      'EmployeeRefId':
      objfun.EmpRefId == 0 ? null : objfun.EmpRefId,
      'StatusRefId': state.statusId,
      'BoardingStartTime': state.checkBoxStartTime
          ? DateTime.parse(state.dtpStartTime).toIso8601String()
          : null,
      'BoardingEndTime': state.checkBoxEndTime
          ? DateTime.parse(state.dtpEndTime).toIso8601String()
          : null,
    };

    final result = await _safeApiCall(() => objfun.apiAllinoneSelectArray(
        objfun.apiUpdateBoardingDetails, master, header, null));

    if (result != null) {
      try {
        final value = ResponseViewModel.fromJson(result);
        if (value.IsSuccess == true) {
          // Trigger mail send
          add(const JobStatusUpdateMailSent());
          return;
        } else {
          emit(state.copyWith(
            status: JobStatusUpdateStatus.failure,
            errorMessage: value.Message,
          ));
          return;
        }
      } catch (_) {}
    }

    emit(state.copyWith(
      status: JobStatusUpdateStatus.failure,
      errorMessage: 'Update failed. Please try again.',
    ));
  }

  // ─── Send status mail ─────────────────────────────────────────────────────

  Future<void> _onMailSent(
      JobStatusUpdateMailSent event,
      Emitter<JobStatusUpdateState> emit) async {
    if (state.imageNetworkNames.isEmpty) {
      emit(state.copyWith(
        status: JobStatusUpdateStatus.failure,
        errorMessage: 'Select Images',
      ));
      return;
    }

    final imageUrls = state.imageNetworkNames
        .map((name) =>
    '${objfun.imagepath}SalesOrder/${state.saleOrderId}/Boarding/$name')
        .toList();

    final header = {'Content-Type': 'application/json; charset=UTF-8'};
    final master = {
      'CompanyRefId': objfun.Comid,
      'RTIId': 0,
      'RTINo': '',
      'JobId': state.saleOrderId,
      'JobNo': state.jobNo,
      'StatusId': state.statusId,
      'StatusName': '${state.statusName} Done',
      'ImageURL': imageUrls,
    };

    final result = await _safeApiCall(() => objfun.apiAllinoneSelectArray(
        objfun.apiBoardingMail, master, header, null));

    if (result != null) {
      try {
        final value = ResponseViewModel.fromJson(result);
        if (value.IsSuccess == true) {
          emit(state.copyWith(
            status: JobStatusUpdateStatus.success,
            action: JobStatusUpdateAction.resetAndReload,
          ));
          return;
        }
      } catch (_) {}
    }

    // Mail may fail gracefully — still mark success so form can reset
    emit(state.copyWith(
      status: JobStatusUpdateStatus.success,
      action: JobStatusUpdateAction.resetAndReload,
    ));
  }

  // ─── Clear form ───────────────────────────────────────────────────────────

  void _onFormCleared(
      JobStatusUpdateFormCleared event,
      Emitter<JobStatusUpdateState> emit) {
    emit(JobStatusUpdateState(
      dtpStartTime:
      DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
      dtpEndTime:
      DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
      userName: state.userName,
      billType: state.billType,
      autocompleteSuggestions: _cachedSuggestions,
      status: JobStatusUpdateStatus.success,
      action: JobStatusUpdateAction.none,
    ));
  }

  // ─── Overlay cleared ──────────────────────────────────────────────────────

  void _onOverlayCleared(
      JobStatusUpdateOverlayCleared event,
      Emitter<JobStatusUpdateState> emit) {
    emit(state.copyWith(
      showAutocompleteOverlay: false,
      autocompleteSuggestions: const [],
      action: JobStatusUpdateAction.hideAutocomplete,
    ));
  }

  // ─── Safe API wrapper ─────────────────────────────────────────────────────

  Future<dynamic> _safeApiCall(Future<dynamic> Function() call) async {
    try {
      return await call();
    } catch (_) {
      return null;
    }
  }
}