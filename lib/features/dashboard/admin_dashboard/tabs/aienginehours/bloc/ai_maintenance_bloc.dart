import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repositories/maintenance_ai_repository.dart';
import '../domain/models/ai_maintenance_risk_model.dart';

// Events
abstract class AIMaintenanceEvent {}
class LoadAIMaintenanceRisks extends AIMaintenanceEvent {
  final Map<String, dynamic>? filter;
  LoadAIMaintenanceRisks({this.filter});
}

// States
abstract class AIMaintenanceState {}
class AIMaintenanceInitial extends AIMaintenanceState {}
class AIMaintenanceLoading extends AIMaintenanceState {}
class AIMaintenanceLoaded extends AIMaintenanceState {
  final List<AIMaintenanceRisk> risks;
  AIMaintenanceLoaded(this.risks);
}
class AIMaintenanceError extends AIMaintenanceState {
  final String message;
  AIMaintenanceError(this.message);
}

// BLoC
class AIMaintenanceBloc extends Bloc<AIMaintenanceEvent, AIMaintenanceState> {
  final MaintenanceAIRepository repository;

  AIMaintenanceBloc({required this.repository}) : super(AIMaintenanceInitial()) {
    on<LoadAIMaintenanceRisks>((event, emit) async {
      emit(AIMaintenanceLoading());
      try {
        final Map<String, dynamic> apiFilter = event.filter ?? {};

        final data = await repository.getMaintenancePredictions(apiFilter);
        emit(AIMaintenanceLoaded(data));
      } catch (e) {
        emit(AIMaintenanceError(e.toString()));
      }
    });
  }
}