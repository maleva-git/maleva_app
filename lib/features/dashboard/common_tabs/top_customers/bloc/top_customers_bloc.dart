import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import '../models/top_customer.dart';
import 'package:maleva/core/utils/app_globals.dart';

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

class TopCustomersBloc extends Bloc<TopCustomersEvent, TopCustomersState> {
  TopCustomersBloc() : super(TopCustomersInitial()) {
    on<FetchTopCustomers>(_onFetchTopCustomers);
  }

  Future<void> _onFetchTopCustomers(FetchTopCustomers event, Emitter<TopCustomersState> emit) async {
    emit(TopCustomersLoading());
    try {
      final String url = '${AppGlobals.port}/api/DashBoardApp/SelectTopCustomers?Comid=${event.comid}&Fromdate=${event.fromDate}&Todate=${event.toDate}&FilterType=${event.filterType}';
      print('Calling API: $url');
      
      final response = await http.post(
        Uri.parse(url),
        headers: AppGlobals.buildRequestHeaders(null),
      );
      
      print('API Response Status: ${response.statusCode}');
      print('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded != null && decoded is List) {
          final customers = (decoded as List).map((e) => TopCustomer.fromJson(Map<String, dynamic>.from(e))).toList();
          emit(TopCustomersLoaded(customers, event.filterType));
        } else {
          emit(TopCustomersLoaded([], event.filterType));
        }
      } else {
        try {
          final decodedError = json.decode(response.body);
          if (decodedError['Message'] == 'No Data Found') {
            emit(TopCustomersLoaded([], event.filterType));
            return;
          }
        } catch (_) {}
        emit(TopCustomersError('Failed to fetch data: '));
      }
    } catch (e) {
      print('Parse Error: $e');
      emit(TopCustomersError(e.toString()));
    }
  }
}
