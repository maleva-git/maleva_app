import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'enquiryadd_event.dart';
import 'enquiryadd_state.dart';



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

    final notifyDate = m['ForwardingDate'] != null
        ? _fmt(DateTime.parse(m['ForwardingDate'].toString()))
        : AddEnquiryState.now();

    String lETADate = AddEnquiryState.now();
    bool checkLETA = false;
    if (m['ETA'] != null) {
      checkLETA = true;
      lETADate = _fmt(DateTime.parse(m['ETA'].toString()));
    }

    String oETADate = AddEnquiryState.now();
    bool checkOETA = false;
    if (m['OETA'] != null) {
      checkOETA = true;
      oETADate = _fmt(DateTime.parse(m['OETA'].toString()));
    }

    String collectionDate = AddEnquiryState.now();
    bool checkCollection = false;
    if (m['PickupDate'] != null) {
      checkCollection = true;
      collectionDate = _fmt(DateTime.parse(m['PickupDate'].toString()));
    }

    emit(state.copyWith(
      editId: m['Id'] ?? 0,
      custId: m['CustomerRefId'] ?? 0,
      customerName: m['CustomerName'] ?? '',
      jobTypeId: m['JobMasterRefId'] ?? 0,
      jobTypeName: m['JobType'] ?? '',
      lVessel: m['Loadingvesselname'] ?? '',
      oVessel: m['Offvesselname'] ?? '',
      lPort: m['SPort'] ?? '',
      oPort: m['OPort'] ?? '',
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

    final Map<String, String> header = {
      'Content-Type': 'application/json; charset=UTF-8',
    };

    final List<dynamic> master = [
      {
        'Id': state.editId,
        'CompanyRefId': objfun.Comid,
        'UserRefId': null,
        'EmployeeRefId': objfun.EmpRefId == 0 ? null : objfun.EmpRefId,
        'AgentCompanyRefId': null,
        'AgentMasterRefId': null,
        'OAgentCompanyRefId': null,
        'OAgentMasterRefId': null,
        'CustomerRefId': state.custId,
        'JobMasterRefId': state.jobTypeId,
        'SaleType': '',
        'CNumberDisplay': '',
        'CNumber': 0,
        'Coinage': 0,
        'GrossAmount': 0,
        'TaxAmount': 0,
        'DiscountAmount': 0,
        'Remarks': '',
        'PlusAmount': 0,
        'MinusAmount': 0,
        'DODescription': '',
        'Amount': 0,
        'Offvesselname': state.oVessel,
        'Loadingvesselname': state.lVessel,
        'BillType': 'MY',
        'SPort': state.lPort,
        'OPort': state.oPort,
        'Vessel': '',
        'OVessel': '',
        'Commodity': '',
        'Cargo': '',
        'ETA': state.checkLETA
            ? DateTime.parse(state.lETADate).toIso8601String()
            : null,
        'ETB': null,
        'ETD': null,
        'OETA': state.checkOETA
            ? DateTime.parse(state.oETADate).toIso8601String()
            : null,
        'OETB': null,
        'OETD': null,
        'DOCNo': null,
        'InvoiceNo': null,
        'TruckRefid': null,
        'DriverRefid': null,
        'AWBNo': '',
        'BLCopy': '',
        'Quantity': '',
        'TotalWeight': '',
        'TruckSize': '',
        'JStatus': null,
        'OStatus': 0,
        'ForkliftbyRefid': null,
        'SealbyRefid': null,
        'SealbreakbyRefid': null,
        'SealbyRefid2': null,
        'SealbreakbyRefid2': null,
        'SealbyRefid3': null,
        'SealbreakbyRefid3': null,
        'BoardingOfficerRefid': null,
        'BoardingOfficer1Refid': null,
        'BoardingAmount': 0,
        'BoardingAmount1': 0,
        'ForwardingEnterRef': '',
        'ForwardingExitRef': '',
        'ForwardingEnterRef2': '',
        'ForwardingExitRef2': '',
        'ForwardingEnterRef3': '',
        'ForwardingExitRef3': '',
        'ForwardingSMKNo': '',
        'ForwardingSMKNo2': '',
        'ForwardingSMKNo3': '',
        'PortChargesRef': '',
        'PortCharges': 0,
        'SealAmount': 0,
        'BreakSealAmount': 0,
        'SealAmount2': 0,
        'BreakSealAmount2': 0,
        'SealAmount3': 0,
        'BreakSealAmount3': 0,
        'PickupDate': state.checkCollection
            ? DateTime.parse(state.collectionDate).toIso8601String()
            : null,
        'DeliveryDate': null,
        'WareHouseEnterDate': null,
        'WareHouseExitDate': null,
        'WareHouseAddress': '',
        'PickupAddress': '',
        'DeliveryAddress': '',
        'Forwarding': '',
        'Forwarding2': '',
        'Forwarding3': '',
        'Origin': '',
        'Destination': '',
        'SCN': '',
        'LSCN': '',
        'Zb': '',
        'PTW': '',
        'Zb2': '',
        'ZbRef': '',
        'ZbRef2': '',
        'Forwarding1S1': '',
        'Forwarding1S2': '',
        'Forwarding2S1': '',
        'Forwarding2S2': '',
        'Forwarding3S1': '',
        'Forwarding3S2': '',
        'CurrencyValue': 0,
        'ActualNetAmount': 0,
        'ForwardingDate': DateTime.parse(state.notifyDate).toIso8601String(),
        'Forwarding2Date': null,
        'Forwarding3Date': null,
      }
    ];

    try {
      final resultData = await objfun.apiAllinoneSelectArray(
        '${objfun.apiInsertEnquiry}?Comid=${objfun.Comid}',
        master,
        header,
        null,
      );

      if (resultData != '') {
        final ResponseViewModel value =
        ResponseViewModel.fromJson(resultData);
        if (value.IsSuccess == true) {
          emit(state.copyWith(
            status: AddEnquiryStatus.success,
            successMessage: 'Created Successfully',
          ));
        } else {
          emit(state.copyWith(
            status: AddEnquiryStatus.error,
            errorMessage: value.Message,
          ));
        }
      }
    } catch (error) {
      emit(state.copyWith(
        status: AddEnquiryStatus.error,
        errorMessage: error.toString(),
      ));
    }
  }

}
