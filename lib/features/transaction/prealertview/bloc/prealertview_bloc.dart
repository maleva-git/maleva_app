import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/utils/app_globals.dart';
import 'package:maleva/core/network/OnlineApi.dart' as OnlineApi;
import 'package:maleva/core/models/model.dart';
import 'prealertview_event.dart';

// ─── STATE CLASSES ────────────────────────────────────────────────────────
abstract class PreAlertState {}
class PreAlertInitial extends PreAlertState {}
class PreAlertLoading extends PreAlertState {}
class PreAlertError extends PreAlertState {
  final String message;
  PreAlertError(this.message);
}

class PreAlertLoaded extends PreAlertState {
  final String fromDate, toDate, custName, jobName, portName, vessel;
  final int custId, jobId, portId;
  final bool checkPickUp, checkPort, checkVesselName, checkConsolidated, checkDelivery, checkLEmp, completeStatusNotShow, etaEnabled;
  final String etaVal, etaRadioVal;

  PreAlertLoaded({
    required this.fromDate, required this.toDate, required this.custId, required this.custName,
    required this.jobId, required this.jobName, required this.portId, required this.portName,
    required this.vessel, required this.checkPickUp, required this.checkPort, required this.checkVesselName,
    required this.checkConsolidated, required this.checkDelivery, required this.checkLEmp,
    required this.completeStatusNotShow, required this.etaVal, required this.etaRadioVal, required this.etaEnabled,
  });

  PreAlertLoaded copyWith({
    String? fromDate, String? toDate, int? custId, String? custName, int? jobId, String? jobName,
    int? portId, String? portName, String? vessel, bool? checkPickUp, bool? checkPort,
    bool? checkVesselName, bool? checkConsolidated, bool? checkDelivery, bool? checkLEmp,
    bool? completeStatusNotShow, String? etaVal, String? etaRadioVal, bool? etaEnabled,
  }) {
    return PreAlertLoaded(
      fromDate: fromDate ?? this.fromDate, toDate: toDate ?? this.toDate, custId: custId ?? this.custId,
      custName: custName ?? this.custName, jobId: jobId ?? this.jobId, jobName: jobName ?? this.jobName,
      portId: portId ?? this.portId, portName: portName ?? this.portName, vessel: vessel ?? this.vessel,
      checkPickUp: checkPickUp ?? this.checkPickUp, checkPort: checkPort ?? this.checkPort,
      checkVesselName: checkVesselName ?? this.checkVesselName, checkConsolidated: checkConsolidated ?? this.checkConsolidated,
      checkDelivery: checkDelivery ?? this.checkDelivery, checkLEmp: checkLEmp ?? this.checkLEmp,
      completeStatusNotShow: completeStatusNotShow ?? this.completeStatusNotShow, etaVal: etaVal ?? this.etaVal,
      etaRadioVal: etaRadioVal ?? this.etaRadioVal, etaEnabled: etaEnabled ?? this.etaEnabled,
    );
  }
}

// ─── BLOC IMPLEMENTATION ──────────────────────────────────────────────────
class PreAlertBloc extends Bloc<PreAlertEvent, PreAlertState> {
  PreAlertBloc() : super(PreAlertInitial()) {
    on<PreAlertStarted>(_onStarted);
    on<PreAlertFromDateChanged>((event, emit) { if (state is PreAlertLoaded) emit((state as PreAlertLoaded).copyWith(fromDate: event.date)); });
    on<PreAlertToDateChanged>((event, emit) { if (state is PreAlertLoaded) emit((state as PreAlertLoaded).copyWith(toDate: event.date)); });
    on<PreAlertCustomerChanged>((event, emit) { if (state is PreAlertLoaded) emit((state as PreAlertLoaded).copyWith(custId: event.custId, custName: event.custName)); });
    on<PreAlertCustomerCleared>((event, emit) { if (state is PreAlertLoaded) emit((state as PreAlertLoaded).copyWith(custId: 0, custName: '')); });
    on<PreAlertJobTypeChanged>((event, emit) { if (state is PreAlertLoaded) emit((state as PreAlertLoaded).copyWith(jobId: event.jobId, jobName: event.jobName)); });
    on<PreAlertJobTypeCleared>((event, emit) { if (state is PreAlertLoaded) emit((state as PreAlertLoaded).copyWith(jobId: 0, jobName: '')); });
    on<PreAlertPortChanged>((event, emit) { if (state is PreAlertLoaded) emit((state as PreAlertLoaded).copyWith(portId: event.portId, portName: event.portName)); });
    on<PreAlertPortCleared>((event, emit) { if (state is PreAlertLoaded) emit((state as PreAlertLoaded).copyWith(portId: 0, portName: '')); });
    on<PreAlertVesselChanged>((event, emit) { if (state is PreAlertLoaded) emit((state as PreAlertLoaded).copyWith(vessel: event.vessel)); });
    on<PreAlertETAChanged>((event, emit) { if (state is PreAlertLoaded) emit((state as PreAlertLoaded).copyWith(etaVal: event.etaVal, etaRadioVal: event.etaRadio, etaEnabled: event.etaEnabled)); });
    on<PreAlertCheckboxChanged>(_onCheckboxChanged);
  }

  Future<void> _onStarted(PreAlertStarted event, Emitter<PreAlertState> emit) async {
    emit(PreAlertLoading());
    try {
      await OnlineApi.SelectCustomer(event.context);await OnlineApi.SelectJobStatus(event.context);await OnlineApi.SelectEmployee(event.context, 'Sales', '');await OnlineApi.loadComboS1(event.context, 0);final isAdmin = AppGlobals.storagenew.getString('RulesType') == 'ADMIN';
      emit(PreAlertLoaded(
        fromDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
        toDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
        custId: 0, custName: '', jobId: 0, jobName: '', portId: 0, portName: '', vessel: '',
        checkPickUp: false, checkPort: false, checkVesselName: false, checkConsolidated: false,
        checkDelivery: false, checkLEmp: !isAdmin, completeStatusNotShow: false,
        etaVal: '0', etaRadioVal: 'O', etaEnabled: false,
      ));
    } catch (e) {
      emit(PreAlertError(e.toString()));
    }
  }

  void _onCheckboxChanged(PreAlertCheckboxChanged event, Emitter<PreAlertState> emit) {
    if (state is! PreAlertLoaded) return;
    final s = state as PreAlertLoaded;
    switch (event.field) {
      case 'pickup': emit(s.copyWith(checkPickUp: event.value)); break;
      case 'port': emit(s.copyWith(checkPort: event.value)); break;
      case 'vesselName': emit(s.copyWith(checkVesselName: event.value)); break;
      case 'consolidated': emit(s.copyWith(checkConsolidated: event.value)); break;
      case 'delivery': emit(s.copyWith(checkDelivery: event.value)); break;
      case 'lEmp': emit(s.copyWith(checkLEmp: event.value)); break;
    }
  }
}