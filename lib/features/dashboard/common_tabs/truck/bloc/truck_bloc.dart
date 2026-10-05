import 'package:maleva/core/theme/app_typography.dart';
import 'package:maleva/core/colors/colors.dart' as colour;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:maleva/features/dashboard/common_tabs/truck/bloc/truck_state.dart';
import '../data/truck_repository.dart';
part 'truck_event.dart';


class TruckDetailsBloc extends Bloc<TruckDetailsEvent, TruckDetailsState> {
  final TruckRepository repository;

  TruckDetailsBloc({required this.repository}) : super(const TruckInitial()) {
    on<LoadTruckDetailsEvent>(_onLoadTruck);
  }

  Future<void> _onLoadTruck(
      LoadTruckDetailsEvent event,
      Emitter<TruckDetailsState> emit,
      ) async {
    emit(const TruckLoadingState());

    try {
      // .NET's window: every date due within the next 5 days
      final truckList = await repository.fetchTruckDetails(until: DateTime.now().add(const Duration(days: 5)));
      emit(TruckLoadedState(truckData: truckList));
    } catch (error) {

      emit(TruckErrorState(errorMessage: error.toString()));
    }
  }

  static String formatTruckDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return '-';
    try {
      final dt = DateTime.parse(rawDate);
      if (dt.year <= 1) return '-';
      return DateFormat('dd MMM yyyy').format(dt);
    } catch (_) {
      return rawDate;
    }
  }

  static Color expiryColor(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return Colors.grey;
    try {
      final dt = DateTime.parse(rawDate);
      if (dt.year <= 1) return Colors.grey;
      final diff = dt.difference(DateTime.now()).inDays;
      if (diff < 0)  return colour.commonColorred;
      if (diff <= 30) return Colors.orange;
      return const Color(0xFF1555F3);
    } catch (_) {
      return Colors.grey;
    }
  }
}