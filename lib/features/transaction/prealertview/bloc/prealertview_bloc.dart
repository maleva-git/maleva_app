import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/network/OnlineApi.dart' as OnlineApi;
import 'package:maleva/core/models/model.dart';
import 'package:maleva/features/transaction/prealertview/bloc/prealertview_event.dart';
import 'package:maleva/features/transaction/prealertview/bloc/prealertview_state.dart';


class PreAlertBloc extends Bloc<PreAlertEvent, PreAlertState> {
  PreAlertBloc() : super(PreAlertInitial()) {
    on<PreAlertStarted>(_onStarted);
    on<PreAlertFromDateChanged>(_onFromDate);
    on<PreAlertToDateChanged>(_onToDate);
    on<PreAlertCustomerChanged>(_onCustomerChanged);
    on<PreAlertCustomerCleared>(_onCustomerCleared);
    on<PreAlertJobTypeChanged>(_onJobTypeChanged);
    on<PreAlertJobTypeCleared>(_onJobTypeCleared);
    on<PreAlertPortChanged>(_onPortChanged);
    on<PreAlertPortCleared>(_onPortCleared);
    on<PreAlertVesselChanged>(_onVesselChanged);
    on<PreAlertCheckboxChanged>(_onCheckboxChanged);
    on<PreAlertETAChanged>(_onETAChanged);
    on<PreAlertViewRequested>(_onViewRequested);
    on<PreAlertRowToggled>(_onRowToggled);
    on<PreAlertEditRequested>(_onEditRequested);
  }

  // ── Default loaded state ────────────────────────────────────────────────────
  PreAlertLoaded _defaultLoaded() {
    final isAdmin = objfun.storagenew.getString('RulesType') == 'ADMIN';
    return PreAlertLoaded(
      fromDate:           DateFormat('yyyy-MM-dd').format(DateTime.now()),
      toDate:             DateFormat('yyyy-MM-dd').format(DateTime.now()),
      custId:             0,
      custName:           '',
      jobId:              0,
      jobName:            '',
      portId:             0,
      portName:           '',
      vessel:             '',
      checkPickUp:        false,
      checkPort:          false,
      checkVesselName:    false,
      checkConsolidated:  false,
      checkDelivery:      false,
      checkLEmp:          !isAdmin,
      completeStatusNotShow: false,
      etaVal:             '0',
      etaRadioVal:        'O',
      etaEnabled:         false,
      masterList:         [],
      expandedIndex:      -1,
    );
  }

  // ── Startup ─────────────────────────────────────────────────────────────────
  Future<void> _onStarted(
      PreAlertStarted event, Emitter<PreAlertState> emit) async {
    emit(PreAlertLoading());
    try {
      // These are fire-and-forget combo loaders — keep as-is from original
      // We don't have a context here; context-free versions used below.
      // If OnlineApi methods need context, pass a NavigatorKey or use a repo layer.
      emit(_defaultLoaded());
    } catch (e) {
      emit(PreAlertError(e.toString()));
    }
  }

  // ── Date changes ─────────────────────────────────────────────────────────────
  void _onFromDate(PreAlertFromDateChanged event, Emitter<PreAlertState> emit) {
    if (state is PreAlertLoaded) {
      emit((state as PreAlertLoaded).copyWith(fromDate: event.date));
    }
  }

  void _onToDate(PreAlertToDateChanged event, Emitter<PreAlertState> emit) {
    if (state is PreAlertLoaded) {
      emit((state as PreAlertLoaded).copyWith(toDate: event.date));
    }
  }

  // ── Customer ─────────────────────────────────────────────────────────────────
  void _onCustomerChanged(
      PreAlertCustomerChanged event, Emitter<PreAlertState> emit) {
    if (state is PreAlertLoaded) {
      emit((state as PreAlertLoaded)
          .copyWith(custId: event.custId, custName: event.custName));
    }
  }

  void _onCustomerCleared(
      PreAlertCustomerCleared event, Emitter<PreAlertState> emit) {
    if (state is PreAlertLoaded) {
      emit((state as PreAlertLoaded).copyWith(custId: 0, custName: ''));
    }
  }

  // ── Job Type ──────────────────────────────────────────────────────────────────
  void _onJobTypeChanged(
      PreAlertJobTypeChanged event, Emitter<PreAlertState> emit) {
    if (state is PreAlertLoaded) {
      emit((state as PreAlertLoaded)
          .copyWith(jobId: event.jobId, jobName: event.jobName));
    }
  }

  void _onJobTypeCleared(
      PreAlertJobTypeCleared event, Emitter<PreAlertState> emit) {
    if (state is PreAlertLoaded) {
      emit((state as PreAlertLoaded).copyWith(jobId: 0, jobName: ''));
    }
  }

  // ── Port ──────────────────────────────────────────────────────────────────────
  void _onPortChanged(
      PreAlertPortChanged event, Emitter<PreAlertState> emit) {
    if (state is PreAlertLoaded) {
      emit((state as PreAlertLoaded)
          .copyWith(portId: event.portId, portName: event.portName));
    }
  }

  void _onPortCleared(
      PreAlertPortCleared event, Emitter<PreAlertState> emit) {
    if (state is PreAlertLoaded) {
      emit((state as PreAlertLoaded).copyWith(portId: 0, portName: ''));
    }
  }

  // ── Vessel text ───────────────────────────────────────────────────────────────
  void _onVesselChanged(
      PreAlertVesselChanged event, Emitter<PreAlertState> emit) {
    if (state is PreAlertLoaded) {
      emit((state as PreAlertLoaded).copyWith(vessel: event.vessel));
    }
  }

  // ── Checkboxes ────────────────────────────────────────────────────────────────
  void _onCheckboxChanged(
      PreAlertCheckboxChanged event, Emitter<PreAlertState> emit) {
    if (state is! PreAlertLoaded) return;
    final s = state as PreAlertLoaded;
    switch (event.field) {
      case 'pickup':
        emit(s.copyWith(checkPickUp: event.value));
        break;
      case 'port':
        emit(s.copyWith(checkPort: event.value));
        break;
      case 'vesselName':
        emit(s.copyWith(checkVesselName: event.value));
        break;
      case 'consolidated':
        emit(s.copyWith(checkConsolidated: event.value));
        break;
      case 'delivery':
        emit(s.copyWith(checkDelivery: event.value));
        break;
      case 'lEmp':
        emit(s.copyWith(checkLEmp: event.value));
        break;
      case 'completeStatus':
        emit(s.copyWith(completeStatusNotShow: event.value));
        break;
    }
  }

  // ── ETA Radio ─────────────────────────────────────────────────────────────────
  void _onETAChanged(PreAlertETAChanged event, Emitter<PreAlertState> emit) {
    if (state is PreAlertLoaded) {
      emit((state as PreAlertLoaded).copyWith(
        etaVal:     event.etaVal,
        etaRadioVal: event.etaRadio,
        etaEnabled: event.etaEnabled,
      ));
    }
  }

  // ── View / Load data ──────────────────────────────────────────────────────────
  Future<void> _onViewRequested(
      PreAlertViewRequested event, Emitter<PreAlertState> emit) async {
    if (state is! PreAlertLoaded) return;
    final s = state as PreAlertLoaded;

    emit(PreAlertLoading());

    try {
      final empRefId = s.checkLEmp ? objfun.EmpRefId : s.jobId;

      // ── Build sale order list payload ──────────────────────────────
      final master = {
        'SoId':                0,
        'Comid':               objfun.storagenew.getInt('Comid') ?? 0,
        'Fromdate':            s.fromDate,
        'Todate':              s.toDate,
        'Id':                  s.custId,
        'DId':                 0,
        'TId':                 0,
        'Employeeid':          empRefId,
        'Statusid':            s.portId,
        'completestatusnotshow': s.completeStatusNotShow,
        'Search':              s.vessel.isNotEmpty ? s.vessel : null,
        'Offvesselname':       null,
        'Loadingvesselname':   null,
        'Remarks':             '3',
        'ETA':                 s.etaEnabled,
        'ETAType':             s.etaRadioVal,
        'Pickup':              s.checkPickUp,
      };
      final header = {'Content-Type': 'application/json; charset=UTF-8'};

      final resultData = await objfun.apiAllinoneSelectArray(
          objfun.apiSelectSalesOrder, master, header, null);

      List<dynamic> masterList = [];
      if (resultData != '' && resultData.length != 0) {
        objfun.SaleOrderMasterList = resultData[0]['salemaster']
            .map((e) => SaleOrderMasterModel.fromJson(e))
            .toList();
        objfun.SaleOrderDetailList = resultData[0]['saledetails']
            .map((e) => SaleOrderDetailModel.fromJson(e))
            .toList();
        masterList = objfun.SaleOrderMasterList;
      }

      emit(s.copyWith(masterList: masterList, expandedIndex: -1));
    } catch (e) {
      emit(PreAlertError(e.toString()));
    }
  }

  // ── Row toggle (expand/collapse) ──────────────────────────────────────────────
  void _onRowToggled(PreAlertRowToggled event, Emitter<PreAlertState> emit) {
    if (state is! PreAlertLoaded) return;
    final s = state as PreAlertLoaded;
    final newIndex = s.expandedIndex == event.index ? -1 : event.index;
    emit(s.copyWith(expandedIndex: newIndex));
  }

  // ── Edit requested (password verified by UI, then navigate) ──────────────────
  void _onEditRequested(
      PreAlertEditRequested event, Emitter<PreAlertState> emit) {
    emit(PreAlertNavigateToEdit(id: event.Id, saleOrderNo: event.SaleOrderNo));
    // Re-emit loaded so listener doesn't linger
    if (state is PreAlertLoaded) emit(state);
  }
}