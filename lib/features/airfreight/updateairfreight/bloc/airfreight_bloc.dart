import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/network/OnlineApi.dart' as OnlineApi;
import 'package:maleva/core/models/model.dart';

import 'airfreight_event.dart';
import 'airfreight_state.dart';

class AirFreightBloc extends Bloc<AirFreightEvent, AirFreightState> {
  AirFreightBloc() : super(AirFreightInitial()) {
    on<AirFreightStarted>(_onStarted);
    on<AirFreightBillTypeChanged>(_onBillTypeChanged);
    on<AirFreightJobNoTextChanged>(_onJobNoTextChanged);
    on<AirFreightJobNoSelected>(_onJobNoSelected);
    on<AirFreightOverlayDismissed>(_onOverlayDismissed);
    on<AirFreightStatusSelected>(_onStatusSelected);
    on<AirFreightStatusCleared>(_onStatusCleared);
    on<AirFreightAwbNoChanged>(_onAwbNoChanged);
    on<AirFreightImageUploadToggled>(_onImageUploadToggled);
    on<AirFreightImagePicked>(_onImagePicked);
    on<AirFreightImageDeleted>(_onImageDeleted);
    on<AirFreightSaveRequested>(_onSaveRequested);
    on<AirFreightClearRequested>(_onClearRequested);
  }

  Future<void> _onStarted(AirFreightStarted event, Emitter<AirFreightState> emit) async {
    // 1. Render UI instantly
    if (event.jobId != null && event.jobNo != null) {
      final shortNo = event.jobNo!.length >= 4 ? event.jobNo!.substring(4) : event.jobNo!;
      emit(AirFreightLoaded.empty().copyWith(jobNoText: shortNo, saleOrderId: event.jobId!));
    } else {
      emit(AirFreightLoaded.empty());
    }

    // 2. Fetch data in the background
    try {
      // 🔥 Fixed: Removed context, passed null
      await OnlineApi.GetJobNoForwarding(null, 0);

      if (event.jobId != null && event.jobNo != null) {
        final shortNo = event.jobNo!.length >= 4 ? event.jobNo!.substring(4) : event.jobNo!;
        final loaded = await _loadJobData(saleOrderId: event.jobId!, jobNo: shortNo, context: event.context, emit: emit);
        if (loaded != null) {
          emit(loaded.copyWith(imageUploadEnabled: true));
        }
      }
    } catch (e) {
      // Background load failed, ignore
    }
  }

  Future<void> _onBillTypeChanged(AirFreightBillTypeChanged event, Emitter<AirFreightState> emit) async {
    if (state is! AirFreightLoaded) return;
    final s = state as AirFreightLoaded;
    try {
      // 🔥 Fixed: Removed context, passed null
      await OnlineApi.GetJobNoForwarding(null, int.parse(event.billType));
    } catch (_) {}
    emit(s.copyWith(billType: event.billType, jobNoText: '', saleOrderId: 0, jobNoSuggestions: []));
  }

  void _onJobNoTextChanged(AirFreightJobNoTextChanged event, Emitter<AirFreightState> emit) {
    if (state is! AirFreightLoaded) return;
    final s = state as AirFreightLoaded;
    emit(s.copyWith(jobNoText: event.text));
  }

  Future<void> _onJobNoSelected(AirFreightJobNoSelected event, Emitter<AirFreightState> emit) async {
    if (state is! AirFreightLoaded) return;
    emit(AirFreightLoading());
    final loaded = await _loadJobData(saleOrderId: event.saleOrderId, jobNo: event.jobNo, context: event.context, emit: emit);
    if (loaded != null) emit(loaded);
  }

  void _onOverlayDismissed(AirFreightOverlayDismissed event, Emitter<AirFreightState> emit) {
    if (state is AirFreightLoaded) emit((state as AirFreightLoaded).copyWith(jobNoSuggestions: []));
  }

  void _onStatusSelected(AirFreightStatusSelected event, Emitter<AirFreightState> emit) {
    if (state is AirFreightLoaded) emit((state as AirFreightLoaded).copyWith(statusId: event.statusId, statusName: event.statusName));
  }

  void _onStatusCleared(AirFreightStatusCleared event, Emitter<AirFreightState> emit) {
    if (state is AirFreightLoaded) emit((state as AirFreightLoaded).copyWith(statusId: 0, statusName: ''));
  }

  void _onAwbNoChanged(AirFreightAwbNoChanged event, Emitter<AirFreightState> emit) {
    if (state is AirFreightLoaded) emit((state as AirFreightLoaded).copyWith(awbNo: event.value));
  }

  void _onImageUploadToggled(AirFreightImageUploadToggled event, Emitter<AirFreightState> emit) {
    if (state is AirFreightLoaded) emit((state as AirFreightLoaded).copyWith(imageUploadEnabled: event.value));
  }

  void _onImagePicked(AirFreightImagePicked event, Emitter<AirFreightState> emit) {
    if (state is! AirFreightLoaded) return;
    final s = state as AirFreightLoaded;
    final newImages = List<String>.from(s.images)..add(event.imageUrl);
    emit(s.copyWith(images: newImages));
  }

  Future<void> _onImageDeleted(AirFreightImageDeleted event, Emitter<AirFreightState> emit) async {
    if (state is! AirFreightLoaded) return;
    final s = state as AirFreightLoaded;

    try {
      final imageFile = s.images[event.index];
      final header = {
        'Content-Type': 'application/json; charset=UTF-8',
        'Comid': objfun.Comid.toString(),
        'Id': s.saleOrderId.toString(),
        'FolderName': 'SalesOrder',
        'FileName': '/Upload/${objfun.Comid}/SalesOrder/${s.saleOrderId}/AirFrieght/$imageFile',
        'SubFolderName': 'AirFrieght',
      };

      // 🔥 Fixed: Passed null for context
      final result = await objfun.apiAllinoneSelectArray(objfun.apiDeleteimage, null, header, null);
      if (result != '') {
        final value = ResponseViewModel.fromJson(result);
        if (value.IsSuccess == true) {
          final newImages = List<String>.from(s.images)..removeAt(event.index);
          emit(s.copyWith(images: newImages));
          return;
        }
      }
    } catch (e) {
      emit(AirFreightError(e.toString()));
    }
  }

  Future<void> _onSaveRequested(AirFreightSaveRequested event, Emitter<AirFreightState> emit) async {
    if (state is! AirFreightLoaded) return;
    final s = state as AirFreightLoaded;

    emit(AirFreightLoading());
    try {
      final master = {
        'Id': s.saleOrderId,
        'Comid': objfun.Comid,
        'Jobid': s.jobNoText,
        'EmployeeRefId': objfun.EmpRefId == 0 ? null : objfun.EmpRefId,
        'StatusRefId': s.statusId,
        'AWBNO': s.awbNo,
      };
      final header = {'Content-Type': 'application/json; charset=UTF-8'};

      // 🔥 Fixed: Passed null for context
      final result = await objfun.apiAllinoneSelectArray(objfun.apiUpdateAirFrieghtDetails, master, header, null);

      if (result != '') {
        final value = ResponseViewModel.fromJson(result);
        if (value.IsSuccess == true) {
          emit(AirFreightSaveSuccess());
          emit(AirFreightLoaded.empty());
          return;
        }
      }
      emit(s);
    } catch (e) {
      emit(AirFreightError(e.toString()));
    }
  }

  void _onClearRequested(AirFreightClearRequested event, Emitter<AirFreightState> emit) {
    emit(AirFreightLoaded.empty());
  }

  // ── Helper: load job data + images ───────────────────────────────────────────
  Future<AirFreightLoaded?> _loadJobData({
    required int saleOrderId,
    required String jobNo,
    required BuildContext context,
    required Emitter<AirFreightState> emit,
  }) async {
    final prev = state is AirFreightLoaded ? state as AirFreightLoaded : AirFreightLoaded.empty();
    try {
      // 🔥 Fixed: Removed context, passed only ID and JobNo
      await OnlineApi.EditSalesOrder(saleOrderId, int.tryParse(jobNo) ?? 0);
      await OnlineApi.SelectJobType(null);
      await OnlineApi.SelectAllJobStatus(null, objfun.SaleEditMasterList[0]['JobMasterRefId']);

      String jobTypeName = '';
      final jobMasterId = objfun.SaleEditMasterList[0]['JobMasterRefId'];
      if (jobMasterId != null && jobMasterId != 0) {
        final matches = objfun.JobTypeList.where((j) => j.Id == jobMasterId).toList();
        if (matches.isNotEmpty) {
          final name = matches[0].Name.trim();
          if (name != 'AIR FRIEGHT IMPORT' && name != 'AIR FRIEGHT EXPORT') {
            emit(AirFreightInvalidJobType());
            emit(AirFreightLoaded.empty());
            return null;
          }
          jobTypeName = name;
        }
      }

      int statusId = 0;
      String statusName = '';
      final jStatus = objfun.SaleEditMasterList[0]['JStatus'];
      if (jStatus != null && jStatus != 0) {
        statusId = jStatus;
        final matches = objfun.JobAllStatusList.where((s) => s.Status == statusId).toList();
        if (matches.isNotEmpty) statusName = matches[0].StatusName;
      }

      final awbNo = objfun.SaleEditMasterList[0]['AWBNo'] ?? '';

      final imageDir = '/Upload/${objfun.Comid}/SalesOrder/$saleOrderId/AirFrieght/';
      final header = {'Content-Type': 'application/json; charset=UTF-8'};

      // 🔥 Fixed: Passed null for context
      final imgResult = await objfun.apiAllinoneSelectArray('${objfun.apiGetimage}$imageDir', null, header, null);

      List<String> images = [];
      if (imgResult != '' && imgResult.length != 0) {
        images = List<String>.from(imgResult as List);
      }

      return prev.copyWith(
        jobNoText: jobNo,
        saleOrderId: saleOrderId,
        jobNoSuggestions: [],
        jobType: jobTypeName,
        statusId: statusId,
        statusName: statusName,
        awbNo: awbNo,
        images: images,
      );
    } catch (_) {
      return null;
    }
  }
}