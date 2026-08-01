import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/sale_update_repository.dart';
import 'sale_update_event.dart';
import 'sale_update_state.dart';

class SaleUpdateBloc extends Bloc<SaleUpdateEvent, SaleUpdateState> {
  final SaleUpdateRepository repository;

  SaleUpdateBloc(this.repository) : super(SaleUpdateInitial()) {
    on<SearchSaleOrdersEvent>((event, emit) async {
      emit(SaleUpdateLoading());
      try {
        final results = await repository.searchSaleOrders(
          fromDate: event.fromDate,
          toDate: event.toDate,
          customerId: event.customerId,
        );
        emit(SaleUpdateLoaded(results));
      } catch (e) {
        emit(SaleUpdateError(e.toString()));
      }
    });

    on<SubmitSaleOrderUpdateEvent>((event, emit) async {
      emit(SaleUpdateSubmitting());
      try {
        await repository.updateSaleOrderFields(
          id: event.id,
          remarks1: event.remarks1,
          origin: event.origin,
          destination: event.destination,
        );
        emit(SaleUpdateSubmitSuccess());
      } catch (e) {
        emit(SaleUpdateError(e.toString()));
      }
    });
  }
}
