import '../models/sale_order_update_model.dart';

abstract class SaleUpdateState {}

class SaleUpdateInitial extends SaleUpdateState {}

class SaleUpdateLoading extends SaleUpdateState {}

class SaleUpdateLoaded extends SaleUpdateState {
  final List<SaleOrderUpdateModel> saleOrders;
  SaleUpdateLoaded(this.saleOrders);
}

class SaleUpdateError extends SaleUpdateState {
  final String message;
  SaleUpdateError(this.message);
}

class SaleUpdateSubmitting extends SaleUpdateState {}

class SaleUpdateSubmitSuccess extends SaleUpdateState {}
