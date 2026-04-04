import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/network/OnlineApi.dart' as OnlineApi;
import 'package:maleva/core/models/model.dart';
import 'package:maleva/features/boarding/updateboardingdetails/bloc/updateboardingdetails_event.dart';
import 'package:maleva/features/boarding/updateboardingdetails/bloc/updateboardingdetails_state.dart';


class BoardingStatusBloc
    extends Bloc<BoardingStatusEvent, BoardingStatusState> {
  BoardingStatusBloc() : super(BoardingStatusInitial()) {
    on<BoardingStatusStarted>(_onStarted);
    on<BoardingStatusBillTypeChanged>(_onBillTypeChanged);
    on<BoardingStatusJobNoTextChanged>(_onJobNoTextChanged);
    on<BoardingStatusJobNoSelected>(_onJobNoSelected);
    on<BoardingStatusOverlayDismissed>(_onOverlayDismissed);
    on<BoardingStatusStatusSelected>(_onStatusSelected);
    on<BoardingStatusStatusCleared>(_onStatusCleared);
    on<BoardingStatusStartTimeChanged>(_onStartTimeChanged);
    on<BoardingStatusStartTimeCheckboxChanged>(_onStartTimeCheckbox);
    on<BoardingStatusEndTimeChanged>(_onEndTimeChanged);
    on<BoardingStatusEndTimeCheckboxChanged>(_onEndTimeCheckbox);
    on<BoardingStatusImageUploadToggled>(_onImageUploadToggled);
    on<BoardingStatusImagePicked>(_onImagePicked);
    on<BoardingStatusImageDeleted>(_onImageDeleted);
    on<BoardingStatusSaveRequested>(_onSaveRequested);
    on<BoardingStatusResetRequested>(_onResetRequested);
  }

  // ── Startup ─────────────────────────────────────────────────────────────────
  Future<void> _onStarted(
      BoardingStatusStarted event,
      Emitter<BoardingStatusState> emit) async {
    emit(BoardingStatusLoading());
    try {
      await OnlineApi.GetJobNoForwarding(null, 0);

      // Pre-fill when coming from dashboard with JobNo + JobId
      if (event.jobId != null && event.jobNo != null) {
        final shortNo = event.jobNo!.length >= 4
            ? event.jobNo!.substring(4)
            : event.jobNo!;

        // Load data for the pre-filled job
        final loaded = await _loadJobData(
          saleOrderId:  event.jobId!,
          jobNo:        shortNo,
          autoPickImage: true,
          emit:         emit,
        );
        if (loaded != null) {
          emit(loaded.copyWith(imageUploadEnabled: true));
        }
      } else {
        emit(BoardingStatusLoaded.empty());
      }
    } catch (e) {
      emit(BoardingStatusError(e.toString()));
    }
  }

  // ── Helper: fetch job details + images ─────────────────────────────────────
  Future<BoardingStatusLoaded?> _loadJobData({
    required int  saleOrderId,
    required String jobNo,
    bool autoPickImage = false,
    required Emitter<BoardingStatusState> emit,
  }) async {
    try {
      await OnlineApi.EditSalesOrder(null, saleOrderId, int.tryParse(jobNo) ?? 0);
      await OnlineApi.SelectAllJobStatus(
          null, objfun.SaleEditMasterList[0]['JobMasterRefId']);

      int    statusId   = 0;
      String statusName = '';
      final jStatus = objfun.SaleEditMasterList[0]['JStatus'];
      if (jStatus != null && jStatus != 0) {
        statusId = jStatus;
        final match = objfun.JobAllStatusList
            .where((s) => s.Status == statusId)
            .toList();
        if (match.isNotEmpty) statusName = match[0].StatusName;
      }

      // Load images
      final imageDir =
          '/Upload/${objfun.Comid}/SalesOrder/$saleOrderId/Boarding/';
      final header = {'Content-Type': 'application/json; charset=UTF-8'};
      final imgResult = await objfun.apiAllinoneSelectArray(
          '${objfun.apiGetimage}$imageDir', null, header, null);

      List<String> images = [];
      if (imgResult != '' && imgResult.length != 0) {
        images = List<String>.from(imgResult as List);
      }

      final prev = state is BoardingStatusLoaded
          ? state as BoardingStatusLoaded
          : BoardingStatusLoaded.empty();

      return prev.copyWith(
        jobNoText:        jobNo,
        saleOrderId:      saleOrderId,
        jobNoSuggestions: [],
        statusId:         statusId,
        statusName:       statusName,
        images:           images,
      );
    } catch (_) {
      return null;
    }
  }

  // ── BillType ─────────────────────────────────────────────────────────────────
  Future<void> _onBillTypeChanged(
      BoardingStatusBillTypeChanged event,
      Emitter<BoardingStatusState> emit) async {
    if (state is! BoardingStatusLoaded) return;
    final s = state as BoardingStatusLoaded;
    try {
      await OnlineApi.GetJobNoForwarding(null, int.parse(event.billType));
    } catch (_) {}
    emit(s.copyWith(
      billType:         event.billType,
      jobNoText:        '',
      saleOrderId:      0,
      jobNoSuggestions: [],
    ));
  }

  // ── Job No text typed ─────────────────────────────────────────────────────────
  void _onJobNoTextChanged(
      BoardingStatusJobNoTextChanged event,
      Emitter<BoardingStatusState> emit) {
    if (state is! BoardingStatusLoaded) return;
    final s = state as BoardingStatusLoaded;
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

  // ── Job No selected from autocomplete ─────────────────────────────────────────
  Future<void> _onJobNoSelected(
      BoardingStatusJobNoSelected event,
      Emitter<BoardingStatusState> emit) async {
    if (state is! BoardingStatusLoaded) return;
    emit(BoardingStatusLoading());
    final loaded = await _loadJobData(
      saleOrderId: event.saleOrderId,
      jobNo:       event.jobNo,
      emit:        emit,
    );
    if (loaded != null) emit(loaded);
  }

  // ── Overlay dismissed ─────────────────────────────────────────────────────────
  void _onOverlayDismissed(
      BoardingStatusOverlayDismissed event,
      Emitter<BoardingStatusState> emit) {
    if (state is BoardingStatusLoaded) {
      emit((state as BoardingStatusLoaded)
          .copyWith(jobNoSuggestions: []));
    }
  }

  // ── Status selected / cleared ─────────────────────────────────────────────────
  void _onStatusSelected(
      BoardingStatusStatusSelected event,
      Emitter<BoardingStatusState> emit) {
    if (state is BoardingStatusLoaded) {
      emit((state as BoardingStatusLoaded).copyWith(
          statusId: event.statusId, statusName: event.statusName));
    }
  }

  void _onStatusCleared(
      BoardingStatusStatusCleared event,
      Emitter<BoardingStatusState> emit) {
    if (state is BoardingStatusLoaded) {
      emit((state as BoardingStatusLoaded)
          .copyWith(statusId: 0, statusName: ''));
    }
  }

  // ── Start time ────────────────────────────────────────────────────────────────
  void _onStartTimeChanged(
      BoardingStatusStartTimeChanged event,
      Emitter<BoardingStatusState> emit) {
    if (state is BoardingStatusLoaded) {
      emit((state as BoardingStatusLoaded)
          .copyWith(startTime: event.dateTime));
    }
  }

  void _onStartTimeCheckbox(
      BoardingStatusStartTimeCheckboxChanged event,
      Emitter<BoardingStatusState> emit) {
    if (state is! BoardingStatusLoaded) return;
    final s = state as BoardingStatusLoaded;
    emit(s.copyWith(
      startTimeEnabled: event.value,
      startTime: event.value
          ? s.startTime
          : DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
    ));
  }

  // ── End time ──────────────────────────────────────────────────────────────────
  void _onEndTimeChanged(
      BoardingStatusEndTimeChanged event,
      Emitter<BoardingStatusState> emit) {
    if (state is BoardingStatusLoaded) {
      emit((state as BoardingStatusLoaded)
          .copyWith(endTime: event.dateTime));
    }
  }

  void _onEndTimeCheckbox(
      BoardingStatusEndTimeCheckboxChanged event,
      Emitter<BoardingStatusState> emit) {
    if (state is! BoardingStatusLoaded) return;
    final s = state as BoardingStatusLoaded;
    emit(s.copyWith(
      endTimeEnabled: event.value,
      endTime: event.value
          ? s.endTime
          : DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
    ));
  }

  // ── Image upload toggle ───────────────────────────────────────────────────────
  void _onImageUploadToggled(
      BoardingStatusImageUploadToggled event,
      Emitter<BoardingStatusState> emit) {
    if (state is BoardingStatusLoaded) {
      emit((state as BoardingStatusLoaded)
          .copyWith(imageUploadEnabled: event.value));
    }
  }

  // ── Image picked ──────────────────────────────────────────────────────────────
  void _onImagePicked(
      BoardingStatusImagePicked event,
      Emitter<BoardingStatusState> emit) {
    if (state is! BoardingStatusLoaded) return;
    final s = state as BoardingStatusLoaded;
    final newImages = List<String>.from(s.images)..add(event.imageUrl);
    emit(s.copyWith(images: newImages));
  }

  // ── Image deleted ─────────────────────────────────────────────────────────────
  Future<void> _onImageDeleted(
      BoardingStatusImageDeleted event,
      Emitter<BoardingStatusState> emit) async {
    if (state is! BoardingStatusLoaded) return;
    final s = state as BoardingStatusLoaded;

    emit(BoardingStatusLoading());
    try {
      final imageFile = s.images[event.index];
      final header = {
        'Content-Type':  'application/json; charset=UTF-8',
        'Comid':         objfun.Comid.toString(),
        'Id':            s.saleOrderId.toString(),
        'FolderName':    'SalesOrder',
        'FileName':
        '/Upload/${objfun.Comid}/SalesOrder/${s.saleOrderId}/Boarding/$imageFile',
        'SubFolderName': 'Boarding',
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
      emit(s); // revert on failure
    } catch (e) {
      emit(BoardingStatusError(e.toString()));
    }
  }

  // ── Save / Update boarding details ────────────────────────────────────────────
  Future<void> _onSaveRequested(
      BoardingStatusSaveRequested event,
      Emitter<BoardingStatusState> emit) async {
    if (state is! BoardingStatusLoaded) return;
    final s = state as BoardingStatusLoaded;

    emit(BoardingStatusLoading());
    try {
      bool success = false;

      // ── Step 1: Update status + times ────────────────────────────────────
      if (s.statusName.isNotEmpty || s.startTimeEnabled || s.endTimeEnabled) {
        final master = {
          'Id':               s.saleOrderId,
          'Comid':            objfun.Comid,
          'Jobid':            s.jobNoText,
          'EmployeeRefId':    objfun.EmpRefId == 0 ? null : objfun.EmpRefId,
          'StatusRefId':      s.statusId,
          'BoardingStartTime': s.startTimeEnabled
              ? DateTime.parse(s.startTime).toIso8601String()
              : null,
          'BoardingEndTime':   s.endTimeEnabled
              ? DateTime.parse(s.endTime).toIso8601String()
              : null,
        };
        final header = {'Content-Type': 'application/json; charset=UTF-8'};

        final result = await objfun.apiAllinoneSelectArray(
            objfun.apiUpdateBoardingDetails, master, header, null);

        if (result != '') {
          final value = ResponseViewModel.fromJson(result);
          if (value.IsSuccess == true) {
            // ── Step 2: Send mail ──────────────────────────────────────────
            await _sendStatusMail(s);
            success = true;
          }
        }
      }

      if (success) {
        emit(BoardingStatusSaveSuccess());
        emit(BoardingStatusLoaded.empty());
      } else {
        emit(s);
      }
    } catch (e) {
      emit(BoardingStatusError(e.toString()));
    }
  }

  // ── Send mail helper ──────────────────────────────────────────────────────────
  Future<void> _sendStatusMail(BoardingStatusLoaded s) async {
    if (s.images.isEmpty) return;
    final imageUrls = s.images
        .map((img) =>
    '${objfun.imagepath}SalesOrder/${s.saleOrderId}/Boarding/$img')
        .toList();

    final master = {
      'CompanyRefId': objfun.Comid,
      'RTIId':        0,
      'RTINo':        '',
      'JobId':        s.saleOrderId,
      'JobNo':        s.jobNoText,
      'StatusId':     s.statusId,
      'StatusName':   '${s.statusName} Done',
      'ImageURL':     imageUrls,
    };
    final header = {'Content-Type': 'application/json; charset=UTF-8'};
    await objfun.apiAllinoneSelectArray(
        objfun.apiBoardingMail, master, header, null);
  }

  // ── Reset ─────────────────────────────────────────────────────────────────────
  void _onResetRequested(
      BoardingStatusResetRequested event,
      Emitter<BoardingStatusState> emit) {
    emit(BoardingStatusLoaded.empty());
  }
}