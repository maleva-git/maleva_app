import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/utils/app_preferences.dart';
// Note: We only need objfun for the image port domain string now
import 'package:maleva/core/utils/clsfunction.dart' as objfun;

import '../data/job_status_update_repository.dart';
import 'jobstatusupdate_event.dart';
import 'jobstatusupdate_state.dart';

class JobStatusUpdateBloc extends Bloc<JobStatusUpdateEvent, JobStatusUpdateState> {
  final JobStatusUpdateRepository repository;
  List<Map<String, dynamic>> _cachedSuggestions = [];

  JobStatusUpdateBloc({required this.repository})
      : super(JobStatusUpdateState(
    dtpStartTime: DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
    dtpEndTime: DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
    userName: AppPreferences.getUsername(),
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

  Future<void> _onStarted(JobStatusUpdateStarted event, Emitter<JobStatusUpdateState> emit) async {
    emit(state.copyWith(status: JobStatusUpdateStatus.loading));
    await _loadJobNoList(int.parse(state.billType));
    emit(state.copyWith(status: JobStatusUpdateStatus.success));
  }

  Future<void> _onBillTypeChanged(JobStatusUpdateBillTypeChanged event, Emitter<JobStatusUpdateState> emit) async {
    emit(state.copyWith(billType: event.billType, status: JobStatusUpdateStatus.loading));
    await _loadJobNoList(int.parse(event.billType));
    emit(state.copyWith(status: JobStatusUpdateStatus.success));
  }

  Future<void> _loadJobNoList(int type) async {
    try {
      final jobs = await repository.fetchJobs(type);
      _cachedSuggestions = jobs.map((e) => {
        'CNumber': e['CNumber']?.toString() ?? '',
        'Id': e['Id'] ?? 0,
      }).toList();
    } catch (_) {
      _cachedSuggestions = [];
    }
  }

  void _onJobNoChanged(JobStatusUpdateJobNoChanged event, Emitter<JobStatusUpdateState> emit) {
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
        .where((e) => e['CNumber'].toString().toUpperCase().contains(query.toUpperCase()))
        .toList();

    emit(state.copyWith(
      autocompleteSuggestions: filtered,
      showAutocompleteOverlay: filtered.isNotEmpty,
      action: filtered.isNotEmpty ? JobStatusUpdateAction.showAutocomplete : JobStatusUpdateAction.hideAutocomplete,
    ));
  }

  Future<void> _onSuggestionSelected(JobStatusUpdateSuggestionSelected event, Emitter<JobStatusUpdateState> emit) async {
    emit(state.copyWith(
      jobNo: event.jobNo,
      saleOrderId: event.saleOrderId,
      showAutocompleteOverlay: false,
      autocompleteSuggestions: const [],
      action: JobStatusUpdateAction.hideAutocomplete,
      imageNetworkNames: const [],
      status: JobStatusUpdateStatus.loading,
    ));
    await _fetchJobData(emit, saleOrderId: event.saleOrderId, jobNo: event.jobNo);
    emit(state.copyWith(status: JobStatusUpdateStatus.success));
  }

  Future<void> _onLoadData(JobStatusUpdateLoadData event, Emitter<JobStatusUpdateState> emit) async {
    if (state.jobNo.isEmpty) return;
    emit(state.copyWith(status: JobStatusUpdateStatus.loading));
    await _fetchJobData(emit, saleOrderId: state.saleOrderId, jobNo: state.jobNo);
    emit(state.copyWith(status: JobStatusUpdateStatus.success));
  }

  Future<void> _fetchJobData(Emitter<JobStatusUpdateState> emit, {required int saleOrderId, required String jobNo}) async {
    try {
      final cNumber = int.tryParse(jobNo) ?? 0;
      final data = await repository.fetchJobData(saleOrderId, cNumber);

      emit(state.copyWith(
        statusName: data['statusName'] as String,
        statusId: data['statusId'] as int,
        imageNetworkNames: data['images'] as List<String>,
      ));
    } catch (e) {
      emit(state.copyWith(status: JobStatusUpdateStatus.failure, errorMessage: e.toString()));
    }
  }

  void _onStatusSelected(JobStatusUpdateStatusSelected event, Emitter<JobStatusUpdateState> emit) {
    emit(state.copyWith(statusName: event.statusName, statusId: event.statusId, action: JobStatusUpdateAction.none));
  }

  void _onStatusCleared(JobStatusUpdateStatusCleared event, Emitter<JobStatusUpdateState> emit) {
    emit(state.copyWith(statusName: '', statusId: 0));
  }

  void _onStartTimeToggled(JobStatusUpdateStartTimeToggled event, Emitter<JobStatusUpdateState> emit) => emit(state.copyWith(checkBoxStartTime: event.value));
  void _onEndTimeToggled(JobStatusUpdateEndTimeToggled event, Emitter<JobStatusUpdateState> emit) => emit(state.copyWith(checkBoxEndTime: event.value));
  void _onImageUploadToggled(JobStatusUpdateImageUploadToggled event, Emitter<JobStatusUpdateState> emit) => emit(state.copyWith(checkBoxImageUpload: event.value));
  void _onStartTimePicked(JobStatusUpdateStartTimePicked event, Emitter<JobStatusUpdateState> emit) => emit(state.copyWith(dtpStartTime: event.dateTime));
  void _onEndTimePicked(JobStatusUpdateEndTimePicked event, Emitter<JobStatusUpdateState> emit) => emit(state.copyWith(dtpEndTime: event.dateTime));

  void _onImagePicked(JobStatusUpdateImagePicked event, Emitter<JobStatusUpdateState> emit) {
    final updated = List<String>.from(state.imageNetworkNames)..add(event.imageName);
    emit(state.copyWith(imageNetworkNames: updated));
  }

  Future<void> _onImageDeleted(JobStatusUpdateImageDeleted event, Emitter<JobStatusUpdateState> emit) async {
    if (state.jobNo.isEmpty) return;
    emit(state.copyWith(status: JobStatusUpdateStatus.loading));

    final index = event.index;
    final imageName = state.imageNetworkNames[index];

    try {
      final result = await repository.deleteImage(state.saleOrderId, imageName);
      if (result?.IsSuccess == true) {
        final updated = List<String>.from(state.imageNetworkNames)..removeAt(index);
        emit(state.copyWith(imageNetworkNames: updated, status: JobStatusUpdateStatus.success));
      } else {
        emit(state.copyWith(status: JobStatusUpdateStatus.failure, errorMessage: result?.Message ?? 'Failed to delete'));
      }
    } catch (_) {
      emit(state.copyWith(status: JobStatusUpdateStatus.failure, errorMessage: 'Failed to delete image.'));
    }
  }

  Future<void> _onSubmitted(JobStatusUpdateSubmitted event, Emitter<JobStatusUpdateState> emit) async {
    if (!state.isFormReady) {
      emit(state.copyWith(status: JobStatusUpdateStatus.failure, errorMessage: 'Enter Details to update'));
      return;
    }
    if (state.checkBoxImageUpload && state.imageNetworkNames.isEmpty) {
      emit(state.copyWith(status: JobStatusUpdateStatus.failure, errorMessage: 'Select Images !!'));
      return;
    }

    emit(state.copyWith(status: JobStatusUpdateStatus.loading));

    try {
      final empRefId = AppPreferences.getEmpRefId();
      final master = {
        'Id': state.saleOrderId,
        'Comid': AppPreferences.getComid(),
        'Jobid': state.jobNo,
        'EmployeeRefId': empRefId == 0 ? null : empRefId,
        'StatusRefId': state.statusId,
        'BoardingStartTime': state.checkBoxStartTime ? DateTime.parse(state.dtpStartTime).toIso8601String() : null,
        'BoardingEndTime': state.checkBoxEndTime ? DateTime.parse(state.dtpEndTime).toIso8601String() : null,
      };

      final result = await repository.updateBoardingDetails(master);

      if (result?.IsSuccess == true) {
        add(const JobStatusUpdateMailSent());
      } else {
        emit(state.copyWith(status: JobStatusUpdateStatus.failure, errorMessage: result?.Message ?? 'Update failed'));
      }
    } catch (_) {
      emit(state.copyWith(status: JobStatusUpdateStatus.failure, errorMessage: 'Update failed. Please try again.'));
    }
  }

  Future<void> _onMailSent(JobStatusUpdateMailSent event, Emitter<JobStatusUpdateState> emit) async {
    if (state.imageNetworkNames.isEmpty) {
      emit(state.copyWith(status: JobStatusUpdateStatus.failure, errorMessage: 'Select Images'));
      return;
    }

    try {
      // NOTE: Using objfun.imagepath just for the domain construct
      final imageUrls = state.imageNetworkNames
          .map((name) => '${objfun.imagepath}SalesOrder/${state.saleOrderId}/Boarding/$name')
          .toList();

      final master = {
        'CompanyRefId': AppPreferences.getComid(),
        'RTIId': 0,
        'RTINo': '',
        'JobId': state.saleOrderId,
        'JobNo': state.jobNo,
        'StatusId': state.statusId,
        'StatusName': '${state.statusName} Done',
        'ImageURL': imageUrls,
      };

      await repository.sendBoardingMail(master);
      // We emit success regardless of mail failure to allow the UI to reset gracefully
      emit(state.copyWith(status: JobStatusUpdateStatus.success, action: JobStatusUpdateAction.resetAndReload));
    } catch (_) {
      emit(state.copyWith(status: JobStatusUpdateStatus.success, action: JobStatusUpdateAction.resetAndReload));
    }
  }

  void _onFormCleared(JobStatusUpdateFormCleared event, Emitter<JobStatusUpdateState> emit) {
    emit(JobStatusUpdateState(
      dtpStartTime: DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
      dtpEndTime: DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
      userName: state.userName,
      billType: state.billType,
      autocompleteSuggestions: _cachedSuggestions,
      status: JobStatusUpdateStatus.success,
      action: JobStatusUpdateAction.none,
    ));
  }

  void _onOverlayCleared(JobStatusUpdateOverlayCleared event, Emitter<JobStatusUpdateState> emit) {
    emit(state.copyWith(
      showAutocompleteOverlay: false,
      autocompleteSuggestions: const [],
      action: JobStatusUpdateAction.hideAutocomplete,
    ));
  }
}