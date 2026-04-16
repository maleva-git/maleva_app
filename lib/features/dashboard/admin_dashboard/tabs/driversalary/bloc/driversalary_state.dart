

import 'package:intl/intl.dart';

abstract class DriverSalaryState {}

class DriverSalaryInitial extends DriverSalaryState {}

class DriverSalaryLoading extends DriverSalaryState {}

class DriverSalaryLoaded extends DriverSalaryState {
  final String fromDate;
  final String toDate;
  final List<dynamic> salaryList;
  final double salaryAmount;

   DriverSalaryLoaded({
    required this.fromDate,
    required this.toDate,
    required this.salaryList,
    required this.salaryAmount,
  });

  DriverSalaryLoaded copyWith({
    String? fromDate,
    String? toDate,
    List<dynamic>? salaryList,
    double? salaryAmount,
  }) {
    return DriverSalaryLoaded(
      fromDate:     fromDate     ?? this.fromDate,
      toDate:       toDate       ?? this.toDate,
      salaryList:   salaryList   ?? this.salaryList,
      salaryAmount: salaryAmount ?? this.salaryAmount,
    );
  }

  static String _today() =>
      DateFormat('yyyy-MM-dd').format(DateTime.now());

  factory DriverSalaryLoaded.empty() => DriverSalaryLoaded(
    fromDate:     _today(),
    toDate:       _today(),
    salaryList:   [],
    salaryAmount: 0.0,
  );
}

// Trigger dialog in UI via BlocListener
class DriverSalaryShowDetail extends DriverSalaryState {
  final Map<String, dynamic> item;
  DriverSalaryShowDetail(this.item);
}

class DriverSalaryError extends DriverSalaryState {
  final String message;
  DriverSalaryError(this.message);
}