import 'package:maleva/core/models/shared/bill_view_model.dart';

abstract class BillOrderState {}

class BillOrderInitial extends BillOrderState {}

class BillOrderLoading extends BillOrderState {}

class BillOrderLoaded extends BillOrderState {
  final List<BillViewModel> records;
  BillOrderLoaded(this.records);
}

class BillOrderError extends BillOrderState {
  final String message;
  BillOrderError(this.message);
}