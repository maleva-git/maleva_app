import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/network/OnlineApi.dart' as OnlineApi;
import 'package:maleva/core/models/model.dart';

import 'airfreight_event.dart';
import 'airfreight_state.dart';


class AirFreightBloc
    extends Bloc<AirFreightEvent, AirFreightState> {
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

  // ── Startup ─────────────────────────────────────────────────────────────────
  Future<void> _onStarted(
      AirFreightStarted event,
      Emitter<AirFreightState> emit) async {
    emit(AirFreightLoading());
    try {
      await OnlineApi.GetJobNoForwarding(null, 0);

      // Pre-fill from dashboard
      if (event.jobId != null && event.jobNo != null) {
        final shortNo = event.jobNo!.length >= 4
            ? event.jobNo!.substring(4)
            : event.jobNo!;

        final loaded = await _loadJobData(
            saleOrderId: event.jobId!, jobNo: shortNo, emit: emit);
        if (loaded != null) {
          emit(loaded.copyWith(imageUploadEnabled: true));
        } else {
          emit(AirFreightLoaded.empty());
        }
      } else {
        emit(AirFreightLoaded.empty());
      }
    } catch (e) {
      emit(AirFreightError(e.toString()));
    }
  }

  // ── BillType ─────────────────────────────────────────────────────────────────
  Future<void> _onBillTypeChanged(
      AirFreightBillTypeChanged event,
      Emitter<AirFreightState> emit) async {
    if (state is! AirFreightLoaded) return;
    final s = state as AirFreightLoaded;
    try {
      await OnlineApi.GetJobNoForwarding(
          null, int.parse(event.billType));
    } catch (_) {}
    emit(s.copyWith(
      billType:         event.billType,
      jobNoText:        '',
      saleOrderId:      0,
      jobNoSuggestions: [],
    ));
  }

  // ── Job No typed ─────────────────────────────────────────────────────────────
  void _onJobNoTextChanged(
      AirFreightJobNoTextChanged event,
      Emitter<AirFreightState> emit) {
    if (state is! AirFreightLoaded) return;
    final s = state as AirFreightLoaded;
    final q = event.text.trim();
    List<dynamic> filtered = [];
    if (q.isNotEmpty) {
      filtered = objfun.JobNoList
          .where((e) => e['CNumber'].toString().contains(q))
          .toList();
    }
    emit(s.copyWith(
      jobNoText:        q,
      jobNoSuggestions: filtered,
      saleOrderId:      0,
    ));
  }

  // ── Job No selected ───────────────────────────────────────────────────────────
  Future<void> _onJobNoSelected(
      AirFreightJobNoSelected event,
      Emitter<AirFreightState> emit) async {
    if (state is! AirFreightLoaded) return;
    emit(AirFreightLoading());
    final loaded = await _loadJobData(
        saleOrderId: event.saleOrderId,
        jobNo: event.jobNo,
        emit: emit);
    if (loaded != null) emit(loaded);
  }

  // ── Overlay dismissed ─────────────────────────────────────────────────────────
  void _onOverlayDismissed(
      AirFreightOverlayDismissed event,
      Emitter<AirFreightState> emit) {
    if (state is AirFreightLoaded) {
      emit((state as AirFreightLoaded)
          .copyWith(jobNoSuggestions: []));
    }
  }

  // ── Status ────────────────────────────────────────────────────────────────────
  void _onStatusSelected(
      AirFreightStatusSelected event,
      Emitter<AirFreightState> emit) {
    if (state is AirFreightLoaded) {
      emit((state as AirFreightLoaded).copyWith(
          statusId: event.statusId, statusName: event.statusName));
    }
  }

  void _onStatusCleared(
      AirFreightStatusCleared event,
      Emitter<AirFreightState> emit) {
    if (state is AirFreightLoaded) {
      emit((state as AirFreightLoaded)
          .copyWith(statusId: 0, statusName: ''));
    }
  }

  // ── AWB No ────────────────────────────────────────────────────────────────────
  void _onAwbNoChanged(
      AirFreightAwbNoChanged event,
      Emitter<AirFreightState> emit) {
    if (state is AirFreightLoaded) {
      emit((state as AirFreightLoaded)
          .copyWith(awbNo: event.value));
    }
  }

  // ── Image upload toggle ───────────────────────────────────────────────────────
  void _onImageUploadToggled(
      AirFreightImageUploadToggled event,
      Emitter<AirFreightState> emit) {
    if (state is AirFreightLoaded) {
      emit((state as AirFreightLoaded)
          .copyWith(imageUploadEnabled: event.value));
    }
  }

  // ── Image picked ──────────────────────────────────────────────────────────────
  void _onImagePicked(
      AirFreightImagePicked event,
      Emitter<AirFreightState> emit) {
    if (state is! AirFreightLoaded) return;
    final s = state as AirFreightLoaded;
    final newImages = List<String>.from(s.images)
      ..add(event.imageUrl);
    emit(s.copyWith(images: newImages));
  }

  // ── Image deleted ─────────────────────────────────────────────────────────────
  Future<void> _onImageDeleted(
      AirFreightImageDeleted event,
      Emitter<AirFreightState> emit) async {
    if (state is! AirFreightLoaded) return;
    final s = state as AirFreightLoaded;

    emit(AirFreightLoading());
    try {
      final imageFile = s.images[event.index];
      final header = {
        'Content-Type':  'application/json; charset=UTF-8',
        'Comid':         objfun.Comid.toString(),
        'Id':            s.saleOrderId.toString(),
        'FolderName':    'SalesOrder',
        'FileName':
        '/Upload/${objfun.Comid}/SalesOrder/${s.saleOrderId}/AirFrieght/$imageFile',
        'SubFolderName': 'AirFrieght',
      };

      final result = await objfun.apiAllinoneSelectArray(
          objfun.apiDeleteimage, null, header, null);

      if (result != '') {
        final value = ResponseViewModel.fromJson(result);
        if (value.IsSuccess == true) {
          final newImages = List<String>.from(s.images)
            ..removeAt(event.index);
          emit(s.copyWith(images: newImages));
          return;
        }
      }
      emit(s);
    } catch (e) {
      emit(AirFreightError(e.toString()));
    }
  }

  // ── Save ──────────────────────────────────────────────────────────────────────
  Future<void> _onSaveRequested(
      AirFreightSaveRequested event,
      Emitter<AirFreightState> emit) async {
    if (state is! AirFreightLoaded) return;
    final s = state as AirFreightLoaded;

    emit(AirFreightLoading());
    try {
      final master = {
        'Id':           s.saleOrderId,
        'Comid':        objfun.Comid,
        'Jobid':        s.jobNoText,
        'EmployeeRefId': objfun.EmpRefId == 0 ? null : objfun.EmpRefId,
        'StatusRefId':  s.statusId,
        'AWBNO':        s.awbNo,
      };
      final header = {'Content-Type': 'application/json; charset=UTF-8'};

      final result = await objfun.apiAllinoneSelectArray(
          objfun.apiUpdateAirFrieghtDetails, master, header, null);

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

  // ── Clear ─────────────────────────────────────────────────────────────────────
  void _onClearRequested(
      AirFreightClearRequested event,
      Emitter<AirFreightState> emit) {
    emit(AirFreightLoaded.empty());
  }

  // ── Helper: load job data + images ───────────────────────────────────────────
  Future<AirFreightLoaded?> _loadJobData({
    required int    saleOrderId,
    required String jobNo,
    required Emitter<AirFreightState> emit,
  }) async {
    final prev = state is AirFreightLoaded
        ? state as AirFreightLoaded
        : AirFreightLoaded.empty();
    try {
      await OnlineApi.EditSalesOrder(
          null, saleOrderId, int.tryParse(jobNo) ?? 0);
      await OnlineApi.SelectJobType(null);
      await OnlineApi.SelectAllJobStatus(
          null,
          objfun.SaleEditMasterList[0]['JobMasterRefId']);

      // Validate Air Freight job type
      String jobTypeName = '';
      final jobMasterId =
      objfun.SaleEditMasterList[0]['JobMasterRefId'];
      if (jobMasterId != null && jobMasterId != 0) {
        final matches = objfun.JobTypeList
            .where((j) => j.Id == jobMasterId)
            .toList();
        if (matches.isNotEmpty) {
          final name = matches[0].Name.trim();
          if (name != 'AIR FRIEGHT IMPORT' &&
              name != 'AIR FRIEGHT EXPORT') {
            emit(AirFreightInvalidJobType());
            emit(AirFreightLoaded.empty());
            return null;
          }
          jobTypeName = name;
        }
      }

      // Status
      int    statusId   = 0;
      String statusName = '';
      final jStatus =
      objfun.SaleEditMasterList[0]['JStatus'];
      if (jStatus != null && jStatus != 0) {
        statusId = jStatus;
        final matches = objfun.JobAllStatusList
            .where((s) => s.Status == statusId)
            .toList();
        if (matches.isNotEmpty) {
          statusName = matches[0].StatusName;
        }
      }

      final awbNo =
          objfun.SaleEditMasterList[0]['AWBNo'] ?? '';

      // Images
      final imageDir =
          '/Upload/${objfun.Comid}/SalesOrder/$saleOrderId/AirFrieght/';
      final header = {'Content-Type': 'application/json; charset=UTF-8'};
      final imgResult = await objfun.apiAllinoneSelectArray(
          '${objfun.apiGetimage}$imageDir', null, header, null);

      List<String> images = [];
      if (imgResult != '' && imgResult.length != 0) {
        images = List<String>.from(imgResult as List);
      }

      return prev.copyWith(
        jobNoText:        jobNo,
        saleOrderId:      saleOrderId,
        jobNoSuggestions: [],
        jobType:          jobTypeName,
        statusId:         statusId,
        statusName:       statusName,
        awbNo:            awbNo,
        images:           images,
      );
    } catch (_) {
      return null;
    }
  }
}