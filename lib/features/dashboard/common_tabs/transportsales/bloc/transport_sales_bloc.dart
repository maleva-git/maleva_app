import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/utils/app_globals.dart';

import '../data/transport_sales_repository.dart';
import 'transport_sales_event.dart';
import 'transport_sales_state.dart';

class TransportSalesBloc extends Bloc<TransportSalesEvent, TransportSalesState> {
  final TransportSalesRepository repository; // ✅ Injected Repository

  TransportSalesBloc({required this.repository}) : super(const TransportSalesState()) {
    on<InitTransportSalesEvent>(_onInit);
    on<ChangeEmployeeEvent>(_onChangeEmployee);
    on<LoadSalesDataEvent>(_onLoadSalesData);

    // Auto-trigger initialization when created
    add(const InitTransportSalesEvent());
  }

  Future<void> _onInit(
      InitTransportSalesEvent event, Emitter<TransportSalesState> emit) async {
    emit(state.copyWith(status: TransportSalesStatus.loading));

    final comId = AppGlobals.storagenew.getInt('Comid') ?? 0;
    final empId = AppGlobals.EmpRefId;

    try {
      // ✅ Call Repository
      final resultData = await repository.fetchRules(comId, empId);

      {
        final List<Map<String, dynamic>> rules = resultData;

        String? defaultEmpId;
        final ids = rules.map((e) => e['Id'].toString()).toList();
        if (ids.contains(empId.toString())) {
          defaultEmpId = empId.toString();
        }

        emit(state.copyWith(
          rulesTypeEmployee: rules,
          selectedEmpId: defaultEmpId,
        ));

        // Load data initially right after setting up the employee
        add(const LoadSalesDataEvent());
      }
    } catch (e) {
      emit(state.copyWith(
          status: TransportSalesStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _onChangeEmployee(
      ChangeEmployeeEvent event, Emitter<TransportSalesState> emit) async {
    emit(state.copyWith(
        selectedEmpId: event.empId, status: TransportSalesStatus.loading));
    add(const LoadSalesDataEvent());
  }

  Future<void> _onLoadSalesData(
      LoadSalesDataEvent event, Emitter<TransportSalesState> emit) async {
    emit(state.copyWith(status: TransportSalesStatus.loading));

    int empId = int.tryParse(state.selectedEmpId ?? "0") ?? AppGlobals.EmpRefId;
    int comId = AppGlobals.storagenew.getInt('Comid') ?? 0;

    try {
      final desk = await repository.fetchSalesDesk(comId, empId);

      emit(state.copyWith(
        status: TransportSalesStatus.success,
        withoutInvoiceCount: desk.withoutInvoice,
        totalCount: desk.total,
        totalBilledCount: desk.billed,
        totalUnBilledCount: desk.unbilled,
        salesReport: desk.statuses,
      ));
    } catch (e) {
      emit(state.copyWith(
          status: TransportSalesStatus.failure, errorMessage: e.toString()));
    }
  }
}