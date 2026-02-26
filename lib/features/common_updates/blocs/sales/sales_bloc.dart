import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/features/common_updates/blocs/sales/sales_event.dart';
import 'package:maleva/features/common_updates/blocs/sales/sales_state.dart';

import '../../../dashboard/admin_dashboard/tabs/invoice/bloc/invoice_event.dart';
import '../../../dashboard/admin_dashboard/tabs/invoice/bloc/invoice_state.dart';

class SalesBloc extends Bloc<SalesEvent, SalesState> {
  SalesBloc() : super(SalesInitial()) {
    on<LoadSales>((event, emit) async {
/*
      final data = await fetchSales(event.page); // your API call
*/
      final data = await fetchSales(); // your API call
      emit(SalesLoaded(data));
    });
  }
}

Future<List> fetchSales() async {
  await Future.delayed(const Duration(seconds: 1)); // simulate API delay
  return [
    {"id": 1, "name": "Truck A"},
    {"id": 2, "name": "Truck B"},
  ];
}

