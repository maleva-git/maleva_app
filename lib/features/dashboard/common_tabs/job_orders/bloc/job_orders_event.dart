import 'package:equatable/equatable.dart';

abstract class JobOrdersEvent extends Equatable {
  const JobOrdersEvent();
  @override
  List<Object?> get props => [];
}

class FetchJobOrders extends JobOrdersEvent {
  final int jId;
  final int tId;

  const FetchJobOrders({this.jId = 1, this.tId = 0});

  @override
  List<Object?> get props => [jId, tId];
}

class UpdateJobOrderStatus extends JobOrdersEvent {
  final int jobId;
  final int statusId;

  const UpdateJobOrderStatus(this.jobId, this.statusId);

  @override
  List<Object?> get props => [jobId, statusId];
}
