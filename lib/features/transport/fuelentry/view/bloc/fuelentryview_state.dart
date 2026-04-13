

import 'package:intl/intl.dart';

abstract class FuelEntryViewState {}

class FuelEntryViewInitial extends FuelEntryViewState {}

class FuelEntryViewLoading extends FuelEntryViewState {}

class FuelEntryViewLoaded extends FuelEntryViewState {
  final String fromDate;
  final String toDate;
  final List<dynamic> items;

   FuelEntryViewLoaded({
    required this.fromDate,
    required this.toDate,
    required this.items,
  });

  FuelEntryViewLoaded copyWith({
    String? fromDate,
    String? toDate,
    List<dynamic>? items,
  }) {
    return FuelEntryViewLoaded(
      fromDate: fromDate ?? this.fromDate,
      toDate:   toDate   ?? this.toDate,
      items:    items    ?? this.items,
    );
  }

  static String today() =>
      DateFormat('yyyy-MM-dd').format(DateTime.now());

  factory FuelEntryViewLoaded.empty() => FuelEntryViewLoaded(
    fromDate: today(),
    toDate:   today(),
    items:    [],
  );
}

class FuelEntryViewError extends FuelEntryViewState {
  final String message;
  FuelEntryViewError(this.message);
}