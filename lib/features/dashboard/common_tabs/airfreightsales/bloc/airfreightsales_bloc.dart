import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/utils/app_globals.dart';

import '../data/airfreight_repository.dart';
import 'airfreightsales_event.dart';
import 'airfreightsales_state.dart';

class AirfreightBloc extends Bloc<CustomerDashboardEvent, AirfreightState> {
  final AirfreightRepository repository; // ✅ Injected Repository

  AirfreightBloc({required this.repository}) : super(const AirfreightState()) {
    on<LoadRulesTypeEvent>(_onLoadRulesType);
    on<EmployeeChangedEvent>(_onEmployeeChanged);
    on<LoadSalesDataEvent>(_onLoadSalesData);

    // ✅ Auto-load data when BLoC is created
    add(LoadRulesTypeEvent());
  }

  Future<void> _onLoadRulesType(
      LoadRulesTypeEvent event,
      Emitter<AirfreightState> emit,
      ) async {
    emit(state.copyWith(isLoading: true));

    final int comId = AppGlobals.storagenew.getInt('Comid') ?? 0;

    try {
      // ✅ Call repository
      final resultData = await repository.fetchRules(comId, AppGlobals.EmpRefId);

      if (resultData.isNotEmpty) {
        final List<Map<String, dynamic>> employees = resultData;

        emit(state.copyWith(
          isLoading: false,
          rulesTypeEmployee: employees,
          dropdownValueEmp: AppGlobals.EmpRefId.toString(),
          empId: AppGlobals.EmpRefId,
        ));

        // Rules load aana udane sales data load pannurom
        add(LoadSalesDataEvent(AppGlobals.EmpRefId));
      } else {
        emit(state.copyWith(isLoading: false));
      }
    } catch (error) {
      emit(state.copyWith(isLoading: false));
    }
  }

  void _onEmployeeChanged(
      EmployeeChangedEvent event,
      Emitter<AirfreightState> emit,
      ) {
    final int newEmpId = int.parse(event.selectedEmpId);
    emit(state.copyWith(
      dropdownValueEmp: event.selectedEmpId,
      empId: newEmpId,
    ));
    add(LoadSalesDataEvent(newEmpId));
  }

  Future<void> _onLoadSalesData(
      LoadSalesDataEvent event,
      Emitter<AirfreightState> emit,
      ) async {
    emit(state.copyWith(isLoading: true));

    final int comId = AppGlobals.storagenew.getInt('Comid') ?? 0;
    final int empId = event.empId;

    try {
      final desk = await repository.fetchSalesDesk(comId, empId);

      emit(state.copyWith(
        isLoading: false,
        withoutInvoiceCount: desk.withoutInvoice,
        totalCount:          desk.total,
        totalBilledCount:    desk.billed,
        totalUnBilledCount:  desk.unbilled,
        salesReport:         desk.statuses,
      ));
    } catch (error) {
      emit(state.copyWith(isLoading: false));
    }
  }
}