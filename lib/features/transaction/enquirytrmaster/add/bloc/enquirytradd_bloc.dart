import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/models/model.dart';
import 'enquirytradd_event.dart';
import 'enquirytradd_state.dart';




class EnquiryAddBloc extends Bloc<EnquiryAddEvent, EnquiryAddState> {
  EnquiryAddBloc() : super(EnquiryAddInitial()) {
    on<EnquiryAddStarted>(_onStarted);
    on<EnquiryAddCustomerChanged>(_onCustomerChanged);
    on<EnquiryAddCustomerCleared>(_onCustomerCleared);
    on<EnquiryAddJobTypeChanged>(_onJobTypeChanged);
    on<EnquiryAddJobTypeCleared>(_onJobTypeCleared);
    on<EnquiryAddOriginChanged>(_onOriginChanged);
    on<EnquiryAddOriginCleared>(_onOriginCleared);
    on<EnquiryAddDestinationChanged>(_onDestinationChanged);
    on<EnquiryAddDestinationCleared>(_onDestinationCleared);
    on<EnquiryAddNotifyDateChanged>(_onNotifyDate);
    on<EnquiryAddCollectionDateChanged>(_onCollectionDate);
    on<EnquiryAddDeliveryDateChanged>(_onDeliveryDate);
    on<EnquiryAddCheckboxChanged>(_onCheckboxChanged);
    on<EnquiryAddTextChanged>(_onTextChanged);
    on<EnquiryAddSaveRequested>(_onSaveRequested);
    on<EnquiryAddClearRequested>(_onClearRequested);
  }

  // ── Default empty state ─────────────────────────────────────────────────────
  EnquiryAddLoaded _emptyLoaded() {
    final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    return EnquiryAddLoaded(
      editId:          0,
      custId:          0,
      custName:        '',
      jobTypeId:       0,
      jobTypeName:     '',
      originId:        0,
      originName:      '',
      destinationId:   0,
      destinationName: '',
      quantity:        '',
      weight:          '',
      lPort:           '',
      oPort:           '',
      notifyDate:      now,
      collectionDate:  now,
      deliveryDate:    now,
      oetaDate:        now,
      checkCollection: false,
      checkDelivery:   false,
      checkOeta:       false,
    );
  }

  // ── Startup — pre-fill from SaleMaster if editing ───────────────────────────
  Future<void> _onStarted(
      EnquiryAddStarted event, Emitter<EnquiryAddState> emit) async {
    emit(EnquiryAddLoading());

    try {
      if (event.saleMaster != null && event.saleMaster!.isNotEmpty) {
        final m = event.saleMaster!;
        final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

        String notifyDate = now;
        if (m['ForwardingDate'] != null) {
          notifyDate = DateFormat('yyyy-MM-dd HH:mm:ss')
              .format(DateTime.parse(m['ForwardingDate'].toString()));
        }

        String collectionDate = now;
        bool checkCollection = false;
        if (m['PickupDate'] != null) {
          checkCollection = true;
          collectionDate = DateFormat('yyyy-MM-dd HH:mm:ss')
              .format(DateTime.parse(m['PickupDate'].toString()));
        }

        String deliveryDate = now;
        bool checkDelivery = false;
        if (m['DeliveryDate'] != null) {
          checkDelivery = true;
          deliveryDate = DateFormat('yyyy-MM-dd HH:mm:ss')
              .format(DateTime.parse(m['DeliveryDate'].toString()));
        }

        emit(EnquiryAddLoaded(
          editId:          m['Id'] ?? 0,
          custId:          m['CustomerRefId'] ?? 0,
          custName:        m['CustomerName'] ?? '',
          jobTypeId:       m['JobMasterRefId'] ?? 0,
          jobTypeName:     m['JobType'] ?? '',
          originId:        m['OriginRefId'] ?? 0,
          originName:      m['Origin'] ?? '',
          destinationId:   m['DestinationRefId'] ?? 0,
          destinationName: m['Destination'] ?? '',
          quantity:        m['Quantity']?.toString() ?? '',
          weight:          m['TotalWeight']?.toString() ?? '',
          lPort:           m['SPort'] ?? '',
          oPort:           m['OPort'] ?? '',
          notifyDate:      notifyDate,
          collectionDate:  collectionDate,
          deliveryDate:    deliveryDate,
          oetaDate:        now,
          checkCollection: checkCollection,
          checkDelivery:   checkDelivery,
          checkOeta:       false,
        ));
      } else {
        emit(_emptyLoaded());
      }
    } catch (e) {
      emit(EnquiryAddError(e.toString()));
    }
  }

  // ── Customer ────────────────────────────────────────────────────────────────
  void _onCustomerChanged(
      EnquiryAddCustomerChanged event, Emitter<EnquiryAddState> emit) {
    if (state is EnquiryAddLoaded) {
      emit((state as EnquiryAddLoaded)
          .copyWith(custId: event.custId, custName: event.custName));
    }
  }

  void _onCustomerCleared(
      EnquiryAddCustomerCleared event, Emitter<EnquiryAddState> emit) {
    if (state is EnquiryAddLoaded) {
      emit((state as EnquiryAddLoaded).copyWith(custId: 0, custName: ''));
    }
  }

  // ── Job Type ────────────────────────────────────────────────────────────────
  void _onJobTypeChanged(
      EnquiryAddJobTypeChanged event, Emitter<EnquiryAddState> emit) {
    if (state is EnquiryAddLoaded) {
      emit((state as EnquiryAddLoaded).copyWith(
          jobTypeId: event.jobTypeId, jobTypeName: event.jobTypeName));
    }
  }

  void _onJobTypeCleared(
      EnquiryAddJobTypeCleared event, Emitter<EnquiryAddState> emit) {
    if (state is EnquiryAddLoaded) {
      emit((state as EnquiryAddLoaded).copyWith(jobTypeId: 0, jobTypeName: ''));
    }
  }

  // ── Origin ──────────────────────────────────────────────────────────────────
  void _onOriginChanged(
      EnquiryAddOriginChanged event, Emitter<EnquiryAddState> emit) {
    if (state is EnquiryAddLoaded) {
      emit((state as EnquiryAddLoaded).copyWith(
          originId: event.originId, originName: event.originName));
    }
  }

  void _onOriginCleared(
      EnquiryAddOriginCleared event, Emitter<EnquiryAddState> emit) {
    if (state is EnquiryAddLoaded) {
      emit((state as EnquiryAddLoaded).copyWith(originId: 0, originName: ''));
    }
  }

  // ── Destination ─────────────────────────────────────────────────────────────
  void _onDestinationChanged(
      EnquiryAddDestinationChanged event, Emitter<EnquiryAddState> emit) {
    if (state is EnquiryAddLoaded) {
      emit((state as EnquiryAddLoaded).copyWith(
          destinationId: event.destinationId,
          destinationName: event.destinationName));
    }
  }

  void _onDestinationCleared(
      EnquiryAddDestinationCleared event, Emitter<EnquiryAddState> emit) {
    if (state is EnquiryAddLoaded) {
      emit((state as EnquiryAddLoaded)
          .copyWith(destinationId: 0, destinationName: ''));
    }
  }

  // ── Dates ────────────────────────────────────────────────────────────────────
  void _onNotifyDate(
      EnquiryAddNotifyDateChanged event, Emitter<EnquiryAddState> emit) {
    if (state is EnquiryAddLoaded) {
      emit((state as EnquiryAddLoaded).copyWith(notifyDate: event.date));
    }
  }

  void _onCollectionDate(
      EnquiryAddCollectionDateChanged event, Emitter<EnquiryAddState> emit) {
    if (state is EnquiryAddLoaded) {
      emit((state as EnquiryAddLoaded).copyWith(collectionDate: event.date));
    }
  }

  void _onDeliveryDate(
      EnquiryAddDeliveryDateChanged event, Emitter<EnquiryAddState> emit) {
    if (state is EnquiryAddLoaded) {
      emit((state as EnquiryAddLoaded).copyWith(deliveryDate: event.date));
    }
  }

  // ── Checkboxes ───────────────────────────────────────────────────────────────
  void _onCheckboxChanged(
      EnquiryAddCheckboxChanged event, Emitter<EnquiryAddState> emit) {
    if (state is! EnquiryAddLoaded) return;
    final s = state as EnquiryAddLoaded;
    final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    switch (event.field) {
      case 'collection':
        emit(s.copyWith(
          checkCollection: event.value,
          collectionDate: event.value ? s.collectionDate : now,
        ));
        break;
      case 'delivery':
        emit(s.copyWith(
          checkDelivery: event.value,
          deliveryDate: event.value ? s.deliveryDate : now,
        ));
        break;
      case 'oeta':
        emit(s.copyWith(checkOeta: event.value));
        break;
    }
  }

  // ── Text fields ──────────────────────────────────────────────────────────────
  void _onTextChanged(
      EnquiryAddTextChanged event, Emitter<EnquiryAddState> emit) {
    if (state is! EnquiryAddLoaded) return;
    final s = state as EnquiryAddLoaded;
    switch (event.field) {
      case 'quantity':
        emit(s.copyWith(quantity: event.value));
        break;
      case 'weight':
        emit(s.copyWith(weight: event.value));
        break;
      case 'lPort':
        emit(s.copyWith(lPort: event.value));
        break;
      case 'oPort':
        emit(s.copyWith(oPort: event.value));
        break;
    }
  }

  // ── Save ─────────────────────────────────────────────────────────────────────
  Future<void> _onSaveRequested(
      EnquiryAddSaveRequested event, Emitter<EnquiryAddState> emit) async {
    if (state is! EnquiryAddLoaded) return;
    final s = state as EnquiryAddLoaded;

    emit(EnquiryAddLoading());
    try {
      final payload = [
        {
          'Id':               s.editId,
          'CompanyRefId':     objfun.Comid,
          'UserRefId':        null,
          'EmployeeRefId':    objfun.EmpRefId == 0 ? null : objfun.EmpRefId,
          'AgentCompanyRefId': null,
          'AgentMasterRefId': null,
          'OAgentCompanyRefId': null,
          'OAgentMasterRefId': null,
          'CustomerRefId':    s.custId,
          'JobMasterRefId':   s.jobTypeId,
          'SaleType':         '',
          'CNumberDisplay':   '',
          'CNumber':          0,
          'Coinage':          0,
          'GrossAmount':      0,
          'TaxAmount':        0,
          'DiscountAmount':   0,
          'Remarks':          '',
          'PlusAmount':       0,
          'MinusAmount':      0,
          'DODescription':    '',
          'Amount':           0,
          'Offvesselname':    '',
          'Loadingvesselname': '',
          'BillType':         'TR',
          'SPort':            s.lPort,
          'OPort':            s.oPort,
          'Vessel':           '',
          'OVessel':          '',
          'Commodity':        '',
          'Cargo':            '',
          'ETA':              null,
          'ETB':              null,
          'ETD':              null,
          'OETA':             null,
          'OETB':             null,
          'OETD':             null,
          'DOCNo':            null,
          'InvoiceNo':        null,
          'TruckRefid':       null,
          'DriverRefid':      null,
          'AWBNo':            '',
          'BLCopy':           '',
          'Quantity':         s.quantity,
          'TotalWeight':      s.weight,
          'OriginRefId':      s.originId,
          'DestinationRefId': s.destinationId,
          'TruckSize':        '',
          'JStatus':          null,
          'OStatus':          0,
          'ForkliftbyRefid':  null,
          'SealbyRefid':      null,
          'SealbreakbyRefid': null,
          'SealbyRefid2':     null,
          'SealbreakbyRefid2': null,
          'SealbyRefid3':     null,
          'SealbreakbyRefid3': null,
          'BoardingOfficerRefid':  null,
          'BoardingOfficer1Refid': null,
          'BoardingAmount':   0,
          'BoardingAmount1':  0,
          'ForwardingEnterRef':  '',
          'ForwardingExitRef':   '',
          'ForwardingEnterRef2': '',
          'ForwardingExitRef2':  '',
          'ForwardingEnterRef3': '',
          'ForwardingExitRef3':  '',
          'ForwardingSMKNo':  '',
          'ForwardingSMKNo2': '',
          'ForwardingSMKNo3': '',
          'PortChargesRef':   '',
          'PortCharges':      0,
          'SealAmount':       0,
          'BreakSealAmount':  0,
          'SealAmount2':      0,
          'BreakSealAmount2': 0,
          'SealAmount3':      0,
          'BreakSealAmount3': 0,
          'PickupDate':   s.checkCollection
              ? DateTime.parse(s.collectionDate).toIso8601String()
              : null,
          'DeliveryDate': s.checkDelivery
              ? DateTime.parse(s.deliveryDate).toIso8601String()
              : null,
          'WareHouseEnterDate': null,
          'WareHouseExitDate':  null,
          'WareHouseAddress':   '',
          'PickupAddress':      '',
          'DeliveryAddress':    '',
          'Forwarding':         '',
          'Forwarding2':        '',
          'Forwarding3':        '',
          'Origin':             s.originName,
          'Destination':        s.destinationName,
          'SCN':                '',
          'LSCN':               '',
          'Zb':                 '',
          'PTW':                '',
          'Zb2':                '',
          'ZbRef':              '',
          'ZbRef2':             '',
          'Forwarding1S1':      '',
          'Forwarding1S2':      '',
          'Forwarding2S1':      '',
          'Forwarding2S2':      '',
          'Forwarding3S1':      '',
          'Forwarding3S2':      '',
          'CurrencyValue':      0,
          'ActualNetAmount':    0,
          'ForwardingDate':
          DateTime.parse(s.notifyDate).toIso8601String(),
          'Forwarding2Date':    null,
          'Forwarding3Date':    null,
        }
      ];

      final header = {'Content-Type': 'application/json; charset=UTF-8'};
      final resultData = await objfun.apiAllinoneSelectArray(
          '${objfun.apiInsertEnquiry}?Comid=${objfun.Comid}',
          payload,
          header,
          null);

      if (resultData != '') {
        final value = ResponseViewModel.fromJson(resultData);
        if (value.IsSuccess == true) {
          emit(EnquiryAddSaveSuccess());
        } else {
          emit(s);
          // Error handled in UI via listener
        }
      } else {
        emit(s);
      }
    } catch (e) {
      emit(EnquiryAddError(e.toString()));
    }
  }

  // ── Clear ────────────────────────────────────────────────────────────────────
  void _onClearRequested(
      EnquiryAddClearRequested event, Emitter<EnquiryAddState> emit) {
    emit(_emptyLoaded());
  }
}