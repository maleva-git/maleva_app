import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/features/dashboard/admin_dashboard/tabs/rtistatus/bloc/rtistatus_event.dart';
import 'package:maleva/features/dashboard/admin_dashboard/tabs/rtistatus/bloc/rtistatus_state.dart';


class RTIStatusBloc extends Bloc<RTIStatusEvent, RTIStatusState> {
  RTIStatusBloc() : super(RTIStatusState.initial()) {
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

  Future<void> _onInitialized(
      RTIStatusInitialized event,
      Emitter<RTIStatusState> emit,
      ) async {
    final details = event.rtiDetails;
    final saleOrderId = int.tryParse(details[0]['JobId'].toString()) ?? 0;
    final rtiId = details[0]['RtiId'] as int? ?? 0;
    final jobNo = details[0]['JobNo']?.toString() ?? '';
    final rtiNo = details[0]['RTINo']?.toString() ?? '';

    emit(state.copyWith(
      status: RTIStatusStatus.loading,
      saleOrderId: saleOrderId,
      rtiId: rtiId,
      jobNo: jobNo,
      rtiNo: rtiNo,
      driverStatus: 'PickUp',
      driverFolder: 'DriverPickup',
    ));

    await _fetchImages(emit, saleOrderId, 'DriverPickup');
  }

  // ─── Driver status changed ─────────────────────────────────────────────────

  Future<void> _onDriverStatusChanged(
      RTIStatusDriverStatusChanged event,
      Emitter<RTIStatusState> emit,
      ) async {
    final folder =
    event.status == 'PickUp' ? 'DriverPickup' : 'DriverDelivery';

    emit(state.copyWith(
      driverStatus: event.status,
      driverFolder: folder,
      imageNetwork: [],
      status: RTIStatusStatus.loading,
    ));

    await _fetchImages(emit, state.saleOrderId, folder);
  }

  // ─── Load images from server ───────────────────────────────────────────────

  Future<void> _fetchImages(
      Emitter<RTIStatusState> emit,
      int saleOrderId,
      String folder,
      ) async {
    try {
      final imageDir =
          '/Upload/${objfun.Comid}/SalesOrder/$saleOrderId/$folder/';

      final result = await objfun.apiAllinoneSelectArray(
        '${objfun.apiGetimage}$imageDir',
        null,
        {'Content-Type': 'application/json; charset=UTF-8'},
        null,
      );

      final List<String> images = [];
      if (result is List && result.isNotEmpty) {
        for (var item in result) {
          images.add(item.toString());
        }
      }

      emit(state.copyWith(
        status: RTIStatusStatus.success,
        imageNetwork: images,
      ));
    } catch (_) {
      // silently fail on image load — original code suppresses this error too
      emit(state.copyWith(status: RTIStatusStatus.success));
    }
  }

  // ─── Image upload checkbox ─────────────────────────────────────────────────

  void _onImageUploadToggled(
      RTIStatusImageUploadToggled event,
      Emitter<RTIStatusState> emit,
      ) {
    emit(state.copyWith(checkBoxImageUpload: event.value));
  }

  // ─── Pick image ────────────────────────────────────────────────────────────

  Future<void> _onImagePickRequested(
      RTIStatusImagePickRequested event,
      Emitter<RTIStatusState> emit,
      ) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: event.fromCamera ? ImageSource.camera : ImageSource.gallery,
    );

    if (pickedFile == null) return;

    emit(state.copyWith(status: RTIStatusStatus.loading));

    try {
      final imageName = await objfun.upload(
        File(pickedFile.path),
        objfun.apiPostimage,
        state.saleOrderId,
        'SalesOrder',
        state.driverFolder,
      );

      final updated = List<String>.from(state.imageNetwork)..add(imageName);
      emit(state.copyWith(
        status: RTIStatusStatus.success,
        imageNetwork: updated,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: RTIStatusStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  // ─── Delete image ──────────────────────────────────────────────────────────

  Future<void> _onImageDeleteRequested(
      RTIStatusImageDeleteRequested event,
      Emitter<RTIStatusState> emit,
      ) async {
    emit(state.copyWith(status: RTIStatusStatus.loading));

    try {
      final filePath =
          '/Upload/${objfun.Comid}/SalesOrder/${state.saleOrderId}/${state.driverFolder}/${state.imageNetwork[event.index]}';

      final result = await objfun.apiAllinoneSelectArray(
        objfun.apiDeleteimage,
        null,
        {
          'Content-Type': 'application/json; charset=UTF-8',
          'Comid': objfun.Comid.toString(),
          'Id': state.saleOrderId.toString(),
          'FolderName': 'SalesOrder',
          'FileName': filePath,
          'SubFolderName': state.driverFolder,
        },
        null,
      );

      final value = ResponseViewModel.fromJson(result);
      if (value.IsSuccess == true) {
        final updated = List<String>.from(state.imageNetwork)
          ..removeAt(event.index);
        emit(state.copyWith(
          status: RTIStatusStatus.success,
          imageNetwork: updated,
          successMessage: 'Deleted Successfully',
        ));
      } else {
        emit(state.copyWith(
          status: RTIStatusStatus.failure,
          errorMessage: value.Message,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: RTIStatusStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  // ─── Preview image ─────────────────────────────────────────────────────────

  void _onImagePreviewRequested(
      RTIStatusImagePreviewRequested event,
      Emitter<RTIStatusState> emit,
      ) {
    emit(state.copyWith(previewImageIndex: event.index));
  }

  // ─── Update / Send Mail ────────────────────────────────────────────────────

  Future<void> _onUpdateRequested(
      RTIStatusUpdateRequested event,
      Emitter<RTIStatusState> emit,
      ) async {
    if (state.imageNetwork.isEmpty) {
      emit(state.copyWith(
        status: RTIStatusStatus.failure,
        errorMessage: 'Select Images',
      ));
      return;
    }

    emit(state.copyWith(
        status: RTIStatusStatus.loading, clearError: true));

    try {
      final imageUrls = state.imageNetwork
          .map((img) =>
      '${objfun.imagepath}SalesOrder/${state.saleOrderId}/${state.driverFolder}/$img')
          .toList();

      final master = {
        'CompanyRefId': objfun.Comid,
        'RTIId': state.rtiId,
        'RTINo': state.rtiNo,
        'JobId': state.saleOrderId,
        'JobNo': state.jobNo,
        'StatusId': 0,
        'StatusName': '${state.driverStatus} Done',
        'ImageURL': imageUrls,
      };

      final result = await objfun.apiAllinoneSelectArray(
        objfun.apiRTIMail,
        master,
        {'Content-Type': 'application/json; charset=UTF-8'},
        null,
      );

      if (result != '') {
        final value = ResponseViewModel.fromJson(result);
        if (value.IsSuccess == true) {
          emit(state.copyWith(
            status: RTIStatusStatus.success,
            successMessage: 'Updated Successfully',
          ));
          add(const RTIStatusClearRequested());
        } else {
          emit(state.copyWith(
            status: RTIStatusStatus.failure,
            errorMessage: value.Message,
          ));
        }
      }
    } catch (e) {
      emit(state.copyWith(
        status: RTIStatusStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  // ─── Clear ─────────────────────────────────────────────────────────────────

  void _onClearRequested(
      RTIStatusClearRequested event,
      Emitter<RTIStatusState> emit,
      ) {
    emit(RTIStatusState.initial().copyWith(
      status: RTIStatusStatus.success,
    ));
  }
}