import 'package:maleva/core/models/model.dart';

abstract class BocState {}

class BocInitial extends BocState {}

class BocLoading extends BocState {}

class BocLoaded extends BocState {
  final List<BoDetailResponse> boDetails;
  BocLoaded(this.boDetails);

  @override
  List<Object?> get props => [boDetails];
}

class BocEmpty extends BocState {}

class BocError extends BocState {
  final String message;
  BocError(this.message);

  @override
  List<Object?> get props => [message];
}