import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:maleva/core/utils/app_preferences.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import '../data/rti_status_repository.dart';
import 'rtistatus_event.dart';
import 'rtistatus_state.dart';

class RTIStatusBloc extends Bloc<RTIStatusEvent, RTIStatusState> {
  final RTIStatusRepository repository;

  RTIStatusBloc({required this.repository}) : super(RTIStatusState.initial()) {
    on<RTIStatusInitialized>(_onInitialized);
    on<RTIStatusDriverStatusChanged>(_onDriverStatusChanged);
    on<RTIStatusImageUploadToggled>(_onImageUploadToggled);
    on<RTIStatusImagePickRequested>(_onImagePickRequested);
    on<RTIStatusImageDeleteRequested>(_onImageDeleteRequested);
    on<RTIStatusImagePreviewRequested>(_onImagePreviewRequested);
    on<RTIStatusUpdateRequested>(_onUpdateRequested);
    on<RTIStatusClearRequested>(_onClearRequested);
  }

  // ─── Init ──────────────────────────────────────────────────────────────────
  Future<void> _onInitialized(RTIStatusInitialized event, Emitter<RTIStatusState> emit) async {
    final details = event.rtiDetails[0];
    emit(state.copyWith(
      status: RTIStatusStatus.loading,
      saleOrderId: int.tryParse(details['JobId'].toString()) ?? 0,
      rtiId: details['RtiId'] as int? ?? 0,
      jobNo: details['JobNo']?.toString() ?? '',
      rtiNo: details['RTINo']?.toString() ?? '',
      driverStatus: 'PickUp',
      driverFolder: 'DriverPickup',
    ));
    await _loadImages(emit);
  }

  // ─── Driver status changed ─────────────────────────────────────────────────
  Future<void> _onDriverStatusChanged(RTIStatusDriverStatusChanged event, Emitter<RTIStatusState> emit) async {
    emit(state.copyWith(
      driverStatus: event.status,
      driverFolder: event.status == 'PickUp' ? 'DriverPickup' : 'DriverDelivery',
      imageNetwork: [],
      status: RTIStatusStatus.loading,
    ));
    await _loadImages(emit);
  }

  Future<void> _loadImages(Emitter<RTIStatusState> emit) async {
    try {
      final images = await repository.fetchImages(state.saleOrderId, state.driverFolder);
      emit(state.copyWith(status: RTIStatusStatus.success, imageNetwork: images));
    } catch (_) {
      emit(state.copyWith(status: RTIStatusStatus.success));
    }
  }

  // ─── Image upload checkbox ─────────────────────────────────────────────────
  void _onImageUploadToggled(RTIStatusImageUploadToggled event, Emitter<RTIStatusState> emit) {
    emit(state.copyWith(checkBoxImageUpload: event.value));
  }

  // ─── Pick image ────────────────────────────────────────────────────────────
  Future<void> _onImagePickRequested(RTIStatusImagePickRequested event, Emitter<RTIStatusState> emit) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: event.fromCamera ? ImageSource.camera : ImageSource.gallery);
    if (pickedFile == null) return;

    emit(state.copyWith(status: RTIStatusStatus.loading));
    try {
      final name = await repository.uploadImage(File(pickedFile.path), state.saleOrderId, state.driverFolder);
      emit(state.copyWith(status: RTIStatusStatus.success, imageNetwork: List.from(state.imageNetwork)..add(name)));
    } catch (e) {
      emit(state.copyWith(status: RTIStatusStatus.failure, errorMessage: e.toString()));
    }
  }

  // ─── Delete image ──────────────────────────────────────────────────────────
  Future<void> _onImageDeleteRequested(RTIStatusImageDeleteRequested event, Emitter<RTIStatusState> emit) async {
    emit(state.copyWith(status: RTIStatusStatus.loading));
    try {
      final result = await repository.deleteImage(state.saleOrderId, state.driverFolder, state.imageNetwork[event.index]);
      if (result?.IsSuccess == true) {
        emit(state.copyWith(
          status: RTIStatusStatus.success,
          imageNetwork: List.from(state.imageNetwork)..removeAt(event.index),
          successMessage: 'Deleted Successfully',
        ));
      } else {
        emit(state.copyWith(status: RTIStatusStatus.failure, errorMessage: result?.Message));
      }
    } catch (e) {
      emit(state.copyWith(status: RTIStatusStatus.failure, errorMessage: e.toString()));
    }
  }

  // ─── Preview image ─────────────────────────────────────────────────────────
  void _onImagePreviewRequested(RTIStatusImagePreviewRequested event, Emitter<RTIStatusState> emit) {
    emit(state.copyWith(previewImageIndex: event.index));
  }

  // ─── Update / Send Mail ────────────────────────────────────────────────────
  Future<void> _onUpdateRequested(RTIStatusUpdateRequested event, Emitter<RTIStatusState> emit) async {
    if (state.imageNetwork.isEmpty) {
      emit(state.copyWith(status: RTIStatusStatus.failure, errorMessage: 'Select Images'));
      return;
    }

    emit(state.copyWith(status: RTIStatusStatus.loading));
    try {
      final master = {
        'CompanyRefId': AppPreferences.getComid(),
        'RTIId': state.rtiId,
        'RTINo': state.rtiNo,
        'JobId': state.saleOrderId,
        'JobNo': state.jobNo,
        'StatusId': 0,
        'StatusName': '${state.driverStatus} Done',
        'ImageURL': state.imageNetwork.map((img) => '${objfun.imagepath}SalesOrder/${state.saleOrderId}/${state.driverFolder}/$img').toList(),
      };

      final result = await repository.sendRtiMail(master);
      if (result?.IsSuccess == true) {
        emit(state.copyWith(status: RTIStatusStatus.success, successMessage: 'Updated Successfully'));
        add(const RTIStatusClearRequested());
      } else {
        emit(state.copyWith(status: RTIStatusStatus.failure, errorMessage: result?.Message));
      }
    } catch (e) {
      emit(state.copyWith(status: RTIStatusStatus.failure, errorMessage: e.toString()));
    }
  }

  // ─── Clear ─────────────────────────────────────────────────────────────────
  void _onClearRequested(RTIStatusClearRequested event, Emitter<RTIStatusState> emit) {
    emit(RTIStatusState.initial().copyWith(status: RTIStatusStatus.success));
  }
}