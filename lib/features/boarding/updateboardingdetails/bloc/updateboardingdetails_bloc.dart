import 'package:flutter/foundation.dart';
import 'package:maleva/core/network/legacy_api_repository.dart';
import 'package:maleva/core/di/injection.dart';
import 'package:maleva/core/files/attachments_api.dart';
import 'package:maleva/core/sale_order/sale_order_api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/utils/app_globals.dart';
import 'package:maleva/features/boarding/updateboardingdetails/bloc/updateboardingdetails_event.dart';
import 'package:maleva/features/boarding/updateboardingdetails/bloc/updateboardingdetails_state.dart';


/// Boarding status of a job, on the shared Java sale order API
/// (`/api/sale-orders/job-numbers`, `/edit`, `PUT /{id}/boarding`, `POST /{id}/boarding-mail`).
class BoardingStatusBloc
    extends Bloc<BoardingStatusEvent, BoardingStatusState> {
  final SaleOrderApi _saleOrders;
  List<Map<String, dynamic>> _jobs = const [];

  BoardingStatusLoaded _empty() => BoardingStatusLoaded.empty().copyWith(jobs: _jobs);

  BoardingStatusBloc({SaleOrderApi? saleOrders})
      : _saleOrders = saleOrders ?? sl<SaleOrderApi>(),
        super(BoardingStatusInitial()) {
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
    // 1. Render UI instantly
    if (event.jobId != null && event.jobNo != null) {
      final shortNo = event.jobNo!.length >= 4 ? event.jobNo!.substring(4) : event.jobNo!;
      emit(_empty().copyWith(jobNoText: shortNo, saleOrderId: event.jobId!));
    } else {
      emit(_empty());
    }

    // 2. Fetch data in the background
    try {
      _jobs = await _saleOrders.jobNumbers(0);
      if (state is BoardingStatusLoaded) emit((state as BoardingStatusLoaded).copyWith(jobs: _jobs));

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
      }
    } catch (e) {
      // Background load failed, ignore
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
      final master = (await _saleOrders.edit(id: saleOrderId, saleOrderNo: int.tryParse(jobNo) ?? 0)).master;
      final int jobMasterId = master['jobMasterRefId'] as int? ?? 0;
      await sl<LegacyApiRepository>().SelectAllJobStatus(null, jobMasterId);

      int    statusId   = 0;
      String statusName = '';
      final jStatus = master['jStatus'];
      if (jStatus != null && jStatus != 0) {
        statusId = jStatus;
        final match = AppGlobals.JobAllStatusList
            .where((s) => s.Status == statusId)
            .toList();
        if (match.isNotEmpty) statusName = match[0].StatusName;
      }

      // Load images
      // the shared Java GET /api/attachments: the job's Boarding photos
      final images = await sl<AttachmentsApi>()
          .imageNames(folder: 'SalesOrder', recordId: saleOrderId, subFolder: 'Boarding');

      final prev = state is BoardingStatusLoaded
          ? state as BoardingStatusLoaded
          : _empty();

      return prev.copyWith(
        jobNoText:        jobNo,
        saleOrderId:      saleOrderId,
        jobNoSuggestions: [],
        statusId:         statusId,
        statusName:       statusName,
        jobMasterId:      jobMasterId,
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
      _jobs = await _saleOrders.jobNumbers(int.parse(event.billType));
    } catch (e, stack) { debugPrint("Error caught globally: $e\n$stack"); }
    emit(s.copyWith(
      billType:         event.billType,
      jobNoText:        '',
      saleOrderId:      0,
      jobNoSuggestions: [],
      jobs:             _jobs,
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
      filtered = s.jobs
          .where((e) => '${e['cNumber'] ?? ''}'.contains(q))
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
      await sl<AttachmentsApi>()
          .delete([imageFile], folder: 'SalesOrder', recordId: s.saleOrderId, subFolder: 'Boarding');
      emit(s.copyWith(images: List<String>.from(s.images)..removeAt(event.index)));
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
      if (s.statusName.isEmpty && !s.startTimeEnabled && !s.endTimeEnabled) {
        emit(s);
        return;
      }
      await _saleOrders.updateBoarding(
        s.saleOrderId,
        statusId: s.statusId,
        start: s.startTimeEnabled ? DateTime.parse(s.startTime) : null,
        end: s.endTimeEnabled ? DateTime.parse(s.endTime) : null,
      );
      await _sendStatusMail(s);
      emit(BoardingStatusSaveSuccess());
      emit(_empty());
    } catch (e) {
      emit(BoardingStatusError(e.toString()));
    }
  }

  // ── Send mail helper (the photos are required, as .NET) ───────────────────────
  Future<void> _sendStatusMail(BoardingStatusLoaded s) async {
    if (s.images.isEmpty) return;
    final imageUrls = s.images
        .map((img) => '${AppGlobals.imagepath}SalesOrder/${s.saleOrderId}/Boarding/$img')
        .toList();
    await _saleOrders.sendBoardingMail(s.saleOrderId, statusName: '${s.statusName} Done', imageUrls: imageUrls);
  }

  // ── Reset ─────────────────────────────────────────────────────────────────────
  void _onResetRequested(
      BoardingStatusResetRequested event,
      Emitter<BoardingStatusState> emit) {
    emit(_empty());
  }
}