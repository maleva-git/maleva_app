

import 'package:intl/intl.dart';

abstract class StockInEntryState {}

class StockInEntryInitial extends StockInEntryState {}

class StockInEntryLoading extends StockInEntryState {}

class StockInEntryLoaded extends StockInEntryState {
  // ── Job No lookup ─────────────────────────────────────────────────────────
  final String billType;
  final String jobNoText;
  final int    saleOrderId;
  final List<dynamic> jobNoSuggestions;

  // ── Readonly info fields (filled after LoadJobDetails) ────────────────────
  final String stockNo;
  final String shipName;
  final String customerName;
  final String jobDate;
  final int    jobMasterId; // used for JobAllStatus navigation
  final int    weightPkg;  // expected packages count for validation

  // ── Editable fields ───────────────────────────────────────────────────────
  final String stockDate;
  final String packages;
  final int    statusId;
  final String statusName;

  // ── Image ─────────────────────────────────────────────────────────────────
  final bool         imageUploadEnabled;
  final List<String> images;

   StockInEntryLoaded({
    required this.billType,
    required this.jobNoText,
    required this.saleOrderId,
    required this.jobNoSuggestions,
    required this.stockNo,
    required this.shipName,
    required this.customerName,
    required this.jobDate,
    required this.jobMasterId,
    required this.weightPkg,
    required this.stockDate,
    required this.packages,
    required this.statusId,
    required this.statusName,
    required this.imageUploadEnabled,
    required this.images,
  });

  static String _today() =>
      DateFormat('yyyy-MM-dd').format(DateTime.now());

  factory StockInEntryLoaded.empty({String stockNo = ''}) =>
      StockInEntryLoaded(
        billType:          '0',
        jobNoText:         '',
        saleOrderId:       0,
        jobNoSuggestions:  [],
        stockNo:           stockNo,
        shipName:          '',
        customerName:      '',
        jobDate:           '',
        jobMasterId:       0,
        weightPkg:         0,
        stockDate:         _today(),
        packages:          '',
        statusId:          0,
        statusName:        '',
        imageUploadEnabled: false,
        images:            [],
      );

  StockInEntryLoaded copyWith({
    String? billType,
    String? jobNoText,
    int?    saleOrderId,
    List<dynamic>? jobNoSuggestions,
    String? stockNo,
    String? shipName,
    String? customerName,
    String? jobDate,
    int?    jobMasterId,
    int?    weightPkg,
    String? stockDate,
    String? packages,
    int?    statusId,
    String? statusName,
    bool?   imageUploadEnabled,
    List<String>? images,
  }) {
    return StockInEntryLoaded(
      billType:          billType          ?? this.billType,
      jobNoText:         jobNoText         ?? this.jobNoText,
      saleOrderId:       saleOrderId       ?? this.saleOrderId,
      jobNoSuggestions:  jobNoSuggestions  ?? this.jobNoSuggestions,
      stockNo:           stockNo           ?? this.stockNo,
      shipName:          shipName          ?? this.shipName,
      customerName:      customerName      ?? this.customerName,
      jobDate:           jobDate           ?? this.jobDate,
      jobMasterId:       jobMasterId       ?? this.jobMasterId,
      weightPkg:         weightPkg         ?? this.weightPkg,
      stockDate:         stockDate         ?? this.stockDate,
      packages:          packages          ?? this.packages,
      statusId:          statusId          ?? this.statusId,
      statusName:        statusName        ?? this.statusName,
      imageUploadEnabled: imageUploadEnabled ?? this.imageUploadEnabled,
      images:            images            ?? this.images,
    );
  }
}

// ── Special states ────────────────────────────────────────────────────────────
class StockInEntrySaveSuccess extends StockInEntryState {
  final int stockId;
  StockInEntrySaveSuccess(this.stockId);
}

// Stock already exists → confirm dialog needed in UI
class StockInEntryStockExistsConfirmNeeded extends StockInEntryState {
  final int    saleOrderId;
  final String jobNo;
  StockInEntryStockExistsConfirmNeeded(
      {required this.saleOrderId, required this.jobNo});
}

class StockInEntryError extends StockInEntryState {
  final String message;
  StockInEntryError(this.message);
}