import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/models/model.dart';

import 'billorder_event.dart';
import 'billorder_state.dart';
import '../data/billorder_repository.dart'; // Import your new repository

class BillOrderBloc extends Bloc<BillOrderEvent, BillOrderState> {
  // Inject the repository instead of BuildContext
  final BillOrderRepository repository;

  BillOrderBloc({required this.repository}) : super(BillOrderInitial()) {
    on<LoadBillOrderEvent>(_onLoad);
  }

  Future<void> _onLoad(
      LoadBillOrderEvent event,
      Emitter<BillOrderState> emit,
      ) async {
    emit(BillOrderLoading());

    try {
      // The BLoC just asks the Repository for data
      final list = await repository.fetchBillOrders(event.fromDate, event.toDate);

      emit(BillOrderLoaded(list));
    } catch (error) {
      // Catch exceptions thrown by the repository
      emit(BillOrderError(error.toString()));
    }
  }
}