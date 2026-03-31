import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/network/OnlineApi.dart' as OnlineApi;
import 'package:maleva/core/models/model.dart';


import 'enquirytrview_event.dart';
import 'enquirytrview_state.dart';



class EnquiryViewBloc extends Bloc<EnquiryViewEvent, EnquiryViewState> {
  EnquiryViewBloc() : super(EnquiryViewInitial()) {
    on<EnquiryViewStarted>(_onStarted);
    on<EnquiryViewFromDateChanged>(_onFromDate);
    on<EnquiryViewToDateChanged>(_onToDate);
    on<EnquiryViewCustomerChanged>(_onCustomerChanged);
    on<EnquiryViewCustomerCleared>(_onCustomerCleared);
    on<EnquiryViewJobTypeChanged>(_onJobTypeChanged);
    on<EnquiryViewJobTypeCleared>(_onJobTypeCleared);
    on<EnquiryViewEmployeeChanged>(_onEmployeeChanged);
    on<EnquiryViewEmployeeCleared>(_onEmployeeCleared);
    on<EnquiryViewCheckboxChanged>(_onCheckboxChanged);
    on<EnquiryViewLoadRequested>(_onLoadRequested);
    on<EnquiryViewCancelRequested>(_onCancelRequested);
    on<EnquiryViewPushToSaleOrder>(_onPushToSaleOrder);
    on<EnquiryViewDetailsRequested>(_onDetailsRequested);
    on<EnquiryViewEditRequested>(_onEditRequested);
    on<EnquiryViewShareRequested>(_onShareRequested);
  }

  // ── Default loaded state ────────────────────────────────────────────────────
  EnquiryViewLoaded _defaultLoaded() => EnquiryViewLoaded(
    fromDate:   DateFormat('yyyy-MM-dd').format(DateTime.now()),
    toDate:     DateFormat('yyyy-MM-dd').format(DateTime.now()),
    custId:     0,
    custName:   '',
    jobId:      0,
    jobName:    '',
    empId:      0,
    empName:    '',
    checkLEmp:  true,
    checkEnq:   false,
    masterList: [],
  );

  // ── Startup ─────────────────────────────────────────────────────────────────
  Future<void> _onStarted(
      EnquiryViewStarted event, Emitter<EnquiryViewState> emit) async {
    emit(EnquiryViewLoading());
    try {
      emit(_defaultLoaded());
      // Initial load without date filter
      add(EnquiryViewLoadRequested(useDate: false));
    } catch (e) {
      emit(EnquiryViewError(e.toString()));
    }
  }

  // ── Date ────────────────────────────────────────────────────────────────────
  void _onFromDate(
      EnquiryViewFromDateChanged event, Emitter<EnquiryViewState> emit) {
    if (state is EnquiryViewLoaded) {
      emit((state as EnquiryViewLoaded).copyWith(fromDate: event.date));
    }
  }

  void _onToDate(
      EnquiryViewToDateChanged event, Emitter<EnquiryViewState> emit) {
    if (state is EnquiryViewLoaded) {
      emit((state as EnquiryViewLoaded).copyWith(toDate: event.date));
    }
  }

  // ── Customer ────────────────────────────────────────────────────────────────
  void _onCustomerChanged(
      EnquiryViewCustomerChanged event, Emitter<EnquiryViewState> emit) {
    if (state is EnquiryViewLoaded) {
      emit((state as EnquiryViewLoaded)
          .copyWith(custId: event.custId, custName: event.custName));
    }
  }

  void _onCustomerCleared(
      EnquiryViewCustomerCleared event, Emitter<EnquiryViewState> emit) {
    if (state is EnquiryViewLoaded) {
      emit((state as EnquiryViewLoaded).copyWith(custId: 0, custName: ''));
    }
  }

  // ── Job Type ────────────────────────────────────────────────────────────────
  void _onJobTypeChanged(
      EnquiryViewJobTypeChanged event, Emitter<EnquiryViewState> emit) {
    if (state is EnquiryViewLoaded) {
      emit((state as EnquiryViewLoaded)
          .copyWith(jobId: event.jobId, jobName: event.jobName));
    }
  }

  void _onJobTypeCleared(
      EnquiryViewJobTypeCleared event, Emitter<EnquiryViewState> emit) {
    if (state is EnquiryViewLoaded) {
      emit((state as EnquiryViewLoaded).copyWith(jobId: 0, jobName: ''));
    }
  }

  // ── Employee ────────────────────────────────────────────────────────────────
  void _onEmployeeChanged(
      EnquiryViewEmployeeChanged event, Emitter<EnquiryViewState> emit) {
    if (state is EnquiryViewLoaded) {
      emit((state as EnquiryViewLoaded)
          .copyWith(empId: event.empId, empName: event.empName));
    }
  }

  void _onEmployeeCleared(
      EnquiryViewEmployeeCleared event, Emitter<EnquiryViewState> emit) {
    if (state is EnquiryViewLoaded) {
      emit((state as EnquiryViewLoaded).copyWith(empId: 0, empName: ''));
    }
  }

  // ── Checkboxes ──────────────────────────────────────────────────────────────
  void _onCheckboxChanged(
      EnquiryViewCheckboxChanged event, Emitter<EnquiryViewState> emit) {
    if (state is! EnquiryViewLoaded) return;
    final s = state as EnquiryViewLoaded;
    switch (event.field) {
      case 'lEmp':
        emit(s.copyWith(checkLEmp: event.value));
        break;
      case 'enq':
        emit(s.copyWith(checkEnq: event.value));
        break;
    }
  }

  // ── Load data ───────────────────────────────────────────────────────────────
  Future<void> _onLoadRequested(
      EnquiryViewLoadRequested event, Emitter<EnquiryViewState> emit) async {
    if (state is! EnquiryViewLoaded) return;
    final s = state as EnquiryViewLoaded;

    emit(EnquiryViewLoading());
    try {
      final empRefId = s.checkLEmp ? objfun.EmpRefId : s.empId;

      final master = {
        'Comid':     objfun.storagenew.getInt('Comid') ?? 0,
        'Fromdate':  event.useDate ? s.fromDate : null,
        'Todate':    event.useDate ? s.toDate : null,
        'Employeeid': empRefId,
        'Invoice':   s.checkEnq,
        'Id':        s.custId,
        'JId':       s.jobId,
      };
      final header = {'Content-Type': 'application/json; charset=UTF-8'};

      final resultData = await objfun.apiAllinoneSelectArray(
          objfun.apiSelectEnquiryMaster, master, header, null);

      List<dynamic> masterList = [];
      if (resultData != '' && resultData.length != 0) {
        masterList = List<dynamic>.from(resultData);
        // Format SForwardingDate
        for (var i = 0; i < masterList.length; i++) {
          if (masterList[i]['ForwardingDate'] == null) {
            masterList[i]['SForwardingDate'] = '';
          } else {
            masterList[i]['SForwardingDate'] = DateFormat('dd-MM-yyyy HH:mm')
                .format(DateTime.parse(masterList[i]['ForwardingDate']));
          }
        }
        objfun.EnquiryMasterList = masterList;
      }

      emit(s.copyWith(masterList: masterList));
    } catch (e) {
      emit(EnquiryViewError(e.toString()));
    }
  }

  // ── Cancel enquiry ──────────────────────────────────────────────────────────
  Future<void> _onCancelRequested(
      EnquiryViewCancelRequested event, Emitter<EnquiryViewState> emit) async {
    if (state is! EnquiryViewLoaded) return;
    final s = state as EnquiryViewLoaded;

    emit(EnquiryViewLoading());
    try {
      final comid = objfun.storagenew.getInt('Comid') ?? 0;
      final header = {'Content-Type': 'application/json; charset=UTF-8'};

      await objfun.apiAllinoneSelectArray(
          '${objfun.apiUpdateEnquiryMaster}${event.id}&Comid=$comid&StatusName=CANCEL',
          null,
          header,
          null);

      emit(s);
      add(EnquiryViewLoadRequested(useDate: false));
    } catch (e) {
      emit(EnquiryViewError(e.toString()));
    }
  }

  // ── Push to sale order ──────────────────────────────────────────────────────
  void _onPushToSaleOrder(
      EnquiryViewPushToSaleOrder event, Emitter<EnquiryViewState> emit) {
    if (state is! EnquiryViewLoaded) return;
    final s = state as EnquiryViewLoaded;
    if (event.index >= s.masterList.length) return;

    final item = s.masterList[event.index];
    objfun.storagenew.setString('EnquiryOpen', 'true');
    emit(EnquiryViewNavigateToPushSaleOrder([item]));
    emit(s);
  }

  // ── Show details ────────────────────────────────────────────────────────────
  void _onDetailsRequested(
      EnquiryViewDetailsRequested event, Emitter<EnquiryViewState> emit) {
    final prev = state;
    emit(EnquiryViewShowDetails(event.item));
    emit(prev);
  }

  // ── Edit ────────────────────────────────────────────────────────────────────
  void _onEditRequested(
      EnquiryViewEditRequested event, Emitter<EnquiryViewState> emit) {
    final prev = state;
    emit(EnquiryViewNavigateToEdit(event.item));
    emit(prev);
  }

  // ── Share / PDF ─────────────────────────────────────────────────────────────
  Future<void> _onShareRequested(
      EnquiryViewShareRequested event, Emitter<EnquiryViewState> emit) async {
    if (state is! EnquiryViewLoaded) return;
    try {
      final master = {
        'SoId':  event.id,
        'Comid': objfun.Comid,
      };
      final header = {'Content-Type': 'application/json; charset=UTF-8'};
      final resultData = await objfun.apiAllinoneSelectArray(
          '${objfun.apiViewPlanningPdf}${event.planningNo}',
          master,
          header,
          null);
      if (resultData != '') {
        final value = ResponseViewModel.fromJson(resultData);
        if (value.IsSuccess == true) objfun.launchInBrowser(value.data1);
      }
    } catch (_) {}
  }
}