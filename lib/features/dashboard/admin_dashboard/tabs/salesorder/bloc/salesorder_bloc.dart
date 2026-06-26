import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import '../data/salesorder_repository.dart';
import 'salesorder_event.dart';
import 'salesorder_state.dart';

class SalesOrderBloc extends Bloc<SalesOrderEvent, SalesOrderState> {
  final SalesOrderRepository repository;
  bool _isLoadingInvoice = false;

  SalesOrderBloc({required this.repository}) : super(InvoiceInitial()) {
    on<LoadInvoiceByTypes>(
          (event, emit) async {
        final sw = Stopwatch()..start();

        final newTabIndex = event.type == 0 ? 0 : event.type - 1;

        if (state is InvoiceLoaded) {
          final current = state as InvoiceLoaded;
          if (current.selectedTabIndex == newTabIndex) return;
        }

        if (state is InvoiceTabSwitching) {
          final switching = state as InvoiceTabSwitching;
          if (switching.targetTabIndex == newTabIndex) return;
        }

        if (_isLoadingInvoice) return;
        _isLoadingInvoice = true;

        if (state is InvoiceLoaded) {
          emit(InvoiceTabSwitching(
            previous: state as InvoiceLoaded,
            targetTabIndex: newTabIndex,
          ));
        } else if (state is InvoiceTabSwitching) {
          emit(InvoiceTabSwitching(
            previous: (state as InvoiceTabSwitching).previous,
            targetTabIndex: newTabIndex,
          ));
        } else {
          emit(InvoiceLoading());
        }

        try {
          final t1 = sw.elapsedMilliseconds;
          print('⏱ Before API call: ${t1}ms');
          
          final results = await Future.wait([
            repository.fetchSalesData(event.type),
          ]);

          final t2 = sw.elapsedMilliseconds;
          print('⏱ After API response: ${t2}ms  (API took: ${t2 - t1}ms)');

          final resultData = results[0];

          if (resultData != null && resultData != "") {
            final saleMonthData =
            List<dynamic>.from(resultData["Data2"] ?? []);
            final monthResult = _buildMonthData(saleMonthData, 6);

            emit(InvoiceLoaded(
              saleDataAll: List<dynamic>.from(resultData["Data1"] ?? []),
              saleMonthData: saleMonthData,
              monthList: monthResult.$1,
              monthData: monthResult.$2,
              is6Months: true,
              currentMonthName: DateFormat('MMMM').format(DateTime.now()),
              selectedTabIndex: newTabIndex,
              employeeData: null,
            ));

            final t3 = sw.elapsedMilliseconds;
            print('⏱ After emit: ${t3}ms  (Processing took: ${t3 - t2}ms)');
            print('⏱ TOTAL: ${t3}ms');
          } else {
            emit(InvoiceError("No data returned"));
          }
        } catch (e) {
          print('❌ Error at: ${sw.elapsedMilliseconds}ms — $e');

          if (state is InvoiceTabSwitching) {
            emit((state as InvoiceTabSwitching).previous);
          } else {
            emit(InvoiceError(e.toString()));
          }
        } finally {
          _isLoadingInvoice = false;
        }
      },
      transformer: sequential(),
    );

    on<LoadMonthRanges>((event, emit) {
      if (state is! InvoiceLoaded) return;
      final s = state as InvoiceLoaded;

      final alreadySelected =
          (event.months == 6 && s.is6Months) ||
              (event.months == 12 && !s.is6Months);
      if (alreadySelected) return;

      final monthResult = _buildMonthData(s.saleMonthData, event.months);
      emit(s.copyWith(
        monthList: monthResult.$1,
        monthData: monthResult.$2,
        is6Months: event.months == 6,
        clearEmployeeData: true,
      ));
    });

    on<LoadEmployeeInvDatas>(
          (event, emit) async {
        if (state is! InvoiceLoaded) return;
        final current = state as InvoiceLoaded;
        emit(current.copyWith(clearEmployeeData: true));

        try {

          final resultData = await repository.fetchEmployeeInvData(
              event.type,
              objfun.Comid
          );

          emit(current.copyWith(
            employeeData: List<dynamic>.from(resultData?["Data1"] ?? []),
          ));
        } catch (_) {}
      },
      transformer: droppable(),
    );
    on<LoadEmployeeSalesData>(
          (event, emit) async {
        if (state is! InvoiceLoaded) return;
        final current = state as InvoiceLoaded;

        // ✅ Clear first — fixes "second tap doesn't open" bug
        emit(current.copyWith(clearEmployeeData: true));

        try {
          final resultData = await repository.fetchEmployeeSalesData(
            event.type, // 0=Today, 1=Yesterday, 2=Weekly, 3=Monthly
          );
          emit(current.copyWith(
            employeeData:    List<dynamic>.from(resultData?["Data1"] ?? []),
          ));
        } catch (_) {}
      },
      transformer: droppable(),
    );
    on<TabChanged>((event, emit) {
      if (state is! InvoiceLoaded) return;
      final current = state as InvoiceLoaded;
      if (current.selectedTabIndex == event.index) return;
      emit(current.copyWith(
        selectedTabIndex: event.index,
        clearEmployeeData: true,
      ));
    });

    on<RefreshSalesOrder>((event, emit) async {
      _isLoadingInvoice = false; // guard release

      final previousLoaded = switch (state) {
        InvoiceLoaded s => s,
        InvoiceTabSwitching s => s.previous,
        _ => null,
      };

      if (previousLoaded != null) {
        add(LoadInvoiceByTypes(previousLoaded.selectedTabIndex + 1 == 1
            ? 0
            : previousLoaded.selectedTabIndex + 1));
      } else {
        emit(InvoiceLoading());
        add(LoadInvoiceByTypes(0));
      }
    });

  }

  (List<String>, List<dynamic>) _buildMonthData(
      List<dynamic> saleMonthData, int count) {
    const monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];

    final monthIndex = DateTime.now().month;
    final monthList = <String>[];

    for (int i = 0; i < count; i++) {
      int idx = ((monthIndex - 1) - i) % 12;
      if (idx < 0) idx += 12;
      monthList.add(monthNames[idx]);
    }

    return (monthList, saleMonthData.take(count).toList());
  }
}