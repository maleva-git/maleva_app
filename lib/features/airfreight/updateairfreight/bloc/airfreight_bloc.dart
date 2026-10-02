import 'package:maleva/core/network/legacy_api_repository.dart';
import 'package:maleva/core/di/injection.dart';
import 'package:maleva/core/files/attachments_api.dart';
import 'package:maleva/core/sale_order/sale_order_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/utils/app_globals.dart';
import 'airfreight_event.dart';
import 'airfreight_state.dart';

/// Air freight status and AWB number of a job, on the shared Java sale order API
/// (`/api/sale-orders/job-numbers`, `/edit`, `PUT /{id}/air-freight`).
class AirFreightBloc extends Bloc<AirFreightEvent, AirFreightState> {
  final SaleOrderApi _saleOrders;
  List<Map<String, dynamic>> _jobs = const [];

  AirFreightLoaded _empty() => AirFreightLoaded.empty().copyWith(jobs: _jobs);

  AirFreightBloc({SaleOrderApi? saleOrders})
      : _saleOrders = saleOrders ?? sl<SaleOrderApi>(),
        super(AirFreightInitial()) {
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
      emit(_empty().copyWith(jobNoText: shortNo, saleOrderId: event.jobId!));
    } else {
      emit(_empty());
    }

    // 2. Fetch data in the background
    try {
      _jobs = await _saleOrders.jobNumbers(0);
      if (state is AirFreightLoaded) emit((state as AirFreightLoaded).copyWith(jobs: _jobs));

      if (event.jobId != null && event.jobNo != null) {
        final shortNo = event.jobNo!.length >= 4 ? event.jobNo!.substring(4) : event.jobNo!;
        if (!event.context.mounted) return;
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
      _jobs = await _saleOrders.jobNumbers(int.parse(event.billType));
    } catch (e, stack) { debugPrint("Error caught globally: $e\n$stack"); }
    emit(s.copyWith(billType: event.billType, jobNoText: '', saleOrderId: 0, jobNoSuggestions: [], jobs: _jobs));
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
      // the shared Java DELETE /api/attachments
      await sl<AttachmentsApi>().delete([imageFile], folder: 'SalesOrder', recordId: s.saleOrderId, subFolder: 'AirFrieght');
      final newImages = List<String>.from(s.images)..removeAt(event.index);
      emit(s.copyWith(images: newImages));
    } catch (e) {
      emit(AirFreightError(e.toString()));
    }
  }

  Future<void> _onSaveRequested(AirFreightSaveRequested event, Emitter<AirFreightState> emit) async {
    if (state is! AirFreightLoaded) return;
    final s = state as AirFreightLoaded;

    emit(AirFreightLoading());
    try {
      await _saleOrders.updateAirFreight(s.saleOrderId, statusId: s.statusId, awbNo: s.awbNo);
      emit(AirFreightSaveSuccess());
      emit(_empty());
    } catch (e) {
      emit(AirFreightError(e.toString()));
    }
  }

  void _onClearRequested(AirFreightClearRequested event, Emitter<AirFreightState> emit) {
    emit(_empty());
  }

  // ── Helper: load job data + images ───────────────────────────────────────────
  Future<AirFreightLoaded?> _loadJobData({
    required int saleOrderId,
    required String jobNo,
    required BuildContext context,
    required Emitter<AirFreightState> emit,
  }) async {
    final prev = state is AirFreightLoaded ? state as AirFreightLoaded : _empty();
    try {
      final master = (await _saleOrders.edit(id: saleOrderId, saleOrderNo: int.tryParse(jobNo) ?? 0)).master;
      await sl<LegacyApiRepository>().SelectJobType(null);
      await sl<LegacyApiRepository>().SelectAllJobStatus(null, master['jobMasterRefId']);

      String jobTypeName = '';
      final jobMasterId = master['jobMasterRefId'];
      if (jobMasterId != null && jobMasterId != 0) {
        final matches = AppGlobals.JobTypeList.where((j) => j.Id == jobMasterId).toList();
        if (matches.isNotEmpty) {
          final name = matches[0].Name.trim();
          if (name != 'AIR FRIEGHT IMPORT' && name != 'AIR FRIEGHT EXPORT') {
            emit(AirFreightInvalidJobType());
            emit(_empty());
            return null;
          }
          jobTypeName = name;
        }
      }

      int statusId = 0;
      String statusName = '';
      final jStatus = master['jStatus'];
      if (jStatus != null && jStatus != 0) {
        statusId = jStatus;
        final matches = AppGlobals.JobAllStatusList.where((s) => s.Status == statusId).toList();
        if (matches.isNotEmpty) statusName = matches[0].StatusName;
      }

      final String awbNo = master['awbNo'] ?? '';

      // the shared Java GET /api/attachments: the job's AirFrieght photos
      final images = await sl<AttachmentsApi>()
          .imageNames(folder: 'SalesOrder', recordId: saleOrderId, subFolder: 'AirFrieght');

      return prev.copyWith(
        jobNoText: jobNo,
        saleOrderId: saleOrderId,
        jobNoSuggestions: [],
        jobType: jobTypeName,
        jobMasterId: jobMasterId as int? ?? 0,
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