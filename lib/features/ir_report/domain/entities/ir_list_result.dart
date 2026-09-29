import 'package:equatable/equatable.dart';

import 'ir_report.dart';

/// One page of the IR list with the server's totals for the same filter.
class IrListResult extends Equatable {
  const IrListResult({
    required this.items,
    required this.totalAmount,
    required this.count,
  });

  final List<IrReport> items;

  /// Sum of ActualAmount, computed by the server over the filtered rows.
  final int totalAmount;
  final int count;

  @override
  List<Object?> get props => [items, totalAmount, count];
}
