import 'package:maleva/core/enquiry/enquiry_api.dart';
import 'package:maleva/core/network/api_failure.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/utils/app_globals.dart';
import 'enquiryadd_event.dart';
import 'enquiryadd_state.dart';
import 'package:maleva/core/di/injection.dart';



class AddEnquiryBloc extends Bloc<AddEnquiryEvent, AddEnquiryState> {
  AddEnquiryBloc() : super(AddEnquiryState.initial()) {
    on<InitAddEnquiryEvent>(_onInit);
    on<CustomerSelectedEvent>(_onCustomerSelected);
    on<CustomerClearedEvent>(_onCustomerCleared);
    on<JobTypeSelectedEvent>(_onJobTypeSelected);
    on<JobTypeClearedEvent>(_onJobTypeCleared);
    on<LPortSelectedEvent>(_onLPortSelected);
    on<LPortClearedEvent>(_onLPortCleared);
    on<OPortSelectedEvent>(_onOPortSelected);
    on<OPortClearedEvent>(_onOPortCleared);
    on<LVesselChangedEvent>(_onLVesselChanged);
    on<OVesselChangedEvent>(_onOVesselChanged);
    on<NotifyDateChangedEvent>(_onNotifyDateChanged);
    on<CollectionCheckboxChangedEvent>(_onCollectionCheckbox);
    on<CollectionDateChangedEvent>(_onCollectionDate);
    on<LETACheckboxChangedEvent>(_onLETACheckbox);
    on<LETADateChangedEvent>(_onLETADate);
    on<OETACheckboxChangedEvent>(_onOETACheckbox);
    on<OETADateChangedEvent>(_onOETADate);
    on<SaveEnquiryEvent>(_onSave);
  }

  static String _fmt(DateTime dt) =>
      DateFormat('yyyy-MM-dd HH:mm:ss').format(dt);

  static DateTime _combine(DateTime date, TimeOfDay time) => DateTime(
      date.year, date.month, date.day, time.hour, time.minute);

  // ── Init ──
  void _onInit(InitAddEnquiryEvent event, Emitter<AddEnquiryState> emit) {
    final m = event.saleMaster;
    if (m == null || m.isEmpty) return;

    final notifyDate = m['forwardingDate'] != null
        ? _fmt(DateTime.parse(m['forwardingDate'].toString()))
        : AddEnquiryState.now();

    String lETADate = AddEnquiryState.now();
    bool checkLETA = false;
    if (m['eta'] != null) {
      checkLETA = true;
      lETADate = _fmt(DateTime.parse(m['eta'].toString()));
    }

    String oETADate = AddEnquiryState.now();
    bool checkOETA = false;
    if (m['oeta'] != null) {
      checkOETA = true;
      oETADate = _fmt(DateTime.parse(m['oeta'].toString()));
    }

    String collectionDate = AddEnquiryState.now();
    bool checkCollection = false;
    if (m['pickupDate'] != null) {
      checkCollection = true;
      collectionDate = _fmt(DateTime.parse(m['pickupDate'].toString()));
    }

    emit(state.copyWith(
      // a Java enquiry row (`/api/enquiry-masters/search`)
      editId: m['id'] ?? 0,
      custId: m['customerRefId'] ?? 0,
      customerName: m['customerName'] ?? '',
      jobTypeId: m['jobMasterRefId'] ?? 0,
      jobTypeName: m['jobType'] ?? '',
      lVessel: m['loadingvesselname'] ?? '',
      oVessel: m['offvesselname'] ?? '',
      lPort: m['sport'] ?? '',
      oPort: m['oport'] ?? '',
      notifyDate: notifyDate,
      collectionDate: collectionDate,
      lETADate: lETADate,
      oETADate: oETADate,
      checkCollection: checkCollection,
      checkLETA: checkLETA,
      checkOETA: checkOETA,
    ));
  }

  // ── Customer ──
  void _onCustomerSelected(
      CustomerSelectedEvent event, Emitter<AddEnquiryState> emit) {
    emit(state.copyWith(customerName: event.name, custId: event.id));
  }

  void _onCustomerCleared(
      CustomerClearedEvent event, Emitter<AddEnquiryState> emit) {
    emit(state.copyWith(customerName: '', custId: 0));
  }

  // ── Job Type ──
  void _onJobTypeSelected(
      JobTypeSelectedEvent event, Emitter<AddEnquiryState> emit) {
    emit(state.copyWith(jobTypeName: event.name, jobTypeId: event.id));
  }

  void _onJobTypeCleared(
      JobTypeClearedEvent event, Emitter<AddEnquiryState> emit) {
    emit(state.copyWith(jobTypeName: '', jobTypeId: 0));
  }

  // ── Ports ──
  void _onLPortSelected(
      LPortSelectedEvent event, Emitter<AddEnquiryState> emit) {
    emit(state.copyWith(lPort: event.name));
  }

  void _onLPortCleared(
      LPortClearedEvent event, Emitter<AddEnquiryState> emit) {
    emit(state.copyWith(lPort: ''));
  }

  void _onOPortSelected(
      OPortSelectedEvent event, Emitter<AddEnquiryState> emit) {
    emit(state.copyWith(oPort: event.name));
  }

  void _onOPortCleared(
      OPortClearedEvent event, Emitter<AddEnquiryState> emit) {
    emit(state.copyWith(oPort: ''));
  }

  // ── Vessels ──
  void _onLVesselChanged(
      LVesselChangedEvent event, Emitter<AddEnquiryState> emit) {
    emit(state.copyWith(lVessel: event.value));
  }

  void _onOVesselChanged(
      OVesselChangedEvent event, Emitter<AddEnquiryState> emit) {
    emit(state.copyWith(oVessel: event.value));
  }

  // ── Notify Date ──
  void _onNotifyDateChanged(
      NotifyDateChangedEvent event, Emitter<AddEnquiryState> emit) {
    emit(state.copyWith(notifyDate: _fmt(event.date)));
  }

  // ── Collection ──
  void _onCollectionCheckbox(
      CollectionCheckboxChangedEvent event, Emitter<AddEnquiryState> emit) {
    emit(state.copyWith(
      checkCollection: event.value,
      collectionDate: event.value ? state.collectionDate : AddEnquiryState.now(),
    ));
  }

  void _onCollectionDate(
      CollectionDateChangedEvent event, Emitter<AddEnquiryState> emit) {
    emit(state.copyWith(
        collectionDate: _fmt(_combine(event.date, event.time))));
  }

  // ── L ETA ──
  void _onLETACheckbox(
      LETACheckboxChangedEvent event, Emitter<AddEnquiryState> emit) {
    emit(state.copyWith(
      checkLETA: event.value,
      lETADate: event.value ? state.lETADate : AddEnquiryState.now(),
    ));
  }

  void _onLETADate(
      LETADateChangedEvent event, Emitter<AddEnquiryState> emit) {
    emit(state.copyWith(lETADate: _fmt(_combine(event.date, event.time))));
  }

  // ── O ETA ──
  void _onOETACheckbox(
      OETACheckboxChangedEvent event, Emitter<AddEnquiryState> emit) {
    emit(state.copyWith(
      checkOETA: event.value,
      oETADate: event.value ? state.oETADate : AddEnquiryState.now(),
    ));
  }

  void _onOETADate(
      OETADateChangedEvent event, Emitter<AddEnquiryState> emit) {
    emit(state.copyWith(oETADate: _fmt(_combine(event.date, event.time))));
  }

  // ── Save ──
  Future<void> _onSave(
      SaveEnquiryEvent event, Emitter<AddEnquiryState> emit) async {
    emit(state.copyWith(status: AddEnquiryStatus.loading));

    try {
      await sl<EnquiryApi>().save(
        id: state.editId,
        billType: 'MY',
        customerId: state.custId,
        jobTypeId: state.jobTypeId,
        employeeId: AppGlobals.EmpRefId,
        forwardingDate: DateTime.parse(state.notifyDate),
        loadingVessel: state.lVessel,
        offVessel: state.oVessel,
        loadingPort: state.lPort,
        offPort: state.oPort,
        eta: state.checkLETA ? DateTime.parse(state.lETADate) : null,
        oeta: state.checkOETA ? DateTime.parse(state.oETADate) : null,
        pickupDate: state.checkCollection ? DateTime.parse(state.collectionDate) : null,
      );
      emit(state.copyWith(
        status: AddEnquiryStatus.success,
        successMessage: 'Created Successfully',
      ));
    } on ApiFailure catch (failure) {
      emit(state.copyWith(
        status: AddEnquiryStatus.error,
        errorMessage: failure.message,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: AddEnquiryStatus.error,
        errorMessage: error.toString(),
      ));
    }
  }

}
