import 'package:bloc/bloc.dart';
import 'package:maleva/core/dashboard/dashboard_api.dart';
import 'package:maleva/core/di/injection.dart';
import '../models/top_customer.dart';

abstract class TopCustomersEvent {}

class FetchTopCustomers extends TopCustomersEvent {
  final int comid;
  final String fromDate;
  final String toDate;
  final String filterType;

  FetchTopCustomers(this.comid, this.fromDate, this.toDate, this.filterType);
}

abstract class TopCustomersState {}

class TopCustomersInitial extends TopCustomersState {}

class TopCustomersLoading extends TopCustomersState {}

class TopCustomersLoaded extends TopCustomersState {
  final List<TopCustomer> customers;
  final String currentFilter;
  
  TopCustomersLoaded(this.customers, this.currentFilter);
}

class TopCustomersError extends TopCustomersState {
  final String message;
  TopCustomersError(this.message);
}

/// Top 20 customers, from the shared Java `GET /api/dashboard/top-customers/{comid}`
/// (ported from .NET SelectTopCustomers; rows keep the .NET names). An empty list is
/// no customers, not an error.
class TopCustomersBloc extends Bloc<TopCustomersEvent, TopCustomersState> {
  TopCustomersBloc({DashboardApi? api})
      : _api = api,
        super(TopCustomersInitial()) {
    on<FetchTopCustomers>(_onFetchTopCustomers);
  }

  final DashboardApi? _api;

  Future<void> _onFetchTopCustomers(FetchTopCustomers event, Emitter<TopCustomersState> emit) async {
    emit(TopCustomersLoading());
    try {
      final rows = await (_api ?? sl<DashboardApi>()).topCustomers(event.comid,
          fromDate: event.fromDate, toDate: event.toDate, filterType: event.filterType);
      emit(TopCustomersLoaded(rows.map(TopCustomer.fromJson).toList(), event.filterType));
    } catch (e) {
      emit(TopCustomersError(e.toString()));
    }
  }
}
