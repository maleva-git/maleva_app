import 'package:equatable/equatable.dart';

/// The RTI list's filters (`RTIViewPage.tsx:55-160`): From / To (today), Driver ("All
/// Drivers"), Truck ("All Trucks"), RTI No (exact; ignores the dates), "My RTIs" (off on first
/// open, on after Clear, K13) and "Not Salary Entered RTI" (client side).
class RtiListFilter extends Equatable {
  const RtiListFilter({
    required this.fromDate,
    required this.toDate,
    this.driverId = 0,
    this.driverName = '',
    this.truckId = 0,
    this.truckName = '',
    this.rtiNo = '',
    this.myRtis = false,
    this.notSalary = false,
  });

  /// The first-open filters: today, everyone's RTIs.
  factory RtiListFilter.initial(DateTime today) => RtiListFilter(fromDate: today, toDate: today);

  /// After Clear (`handleClear`): today, and "My RTIs" on.
  factory RtiListFilter.cleared(DateTime today) => RtiListFilter(fromDate: today, toDate: today, myRtis: true);

  final DateTime fromDate;
  final DateTime toDate;
  final int driverId;
  final String driverName;
  final int truckId;
  final String truckName;
  final String rtiNo;
  final bool myRtis;
  final bool notSalary;

  /// How many filters differ from the first-open ones (the "Filters · n" badge).
  int activeCount(DateTime today) {
    var n = 0;
    if (fromDate != today || toDate != today) n++;
    if (driverId != 0) n++;
    if (truckId != 0) n++;
    if (rtiNo.trim().isNotEmpty) n++;
    if (myRtis) n++;
    if (notSalary) n++;
    return n;
  }

  RtiListFilter copyWith({
    DateTime? fromDate,
    DateTime? toDate,
    int? driverId,
    String? driverName,
    int? truckId,
    String? truckName,
    String? rtiNo,
    bool? myRtis,
    bool? notSalary,
  }) =>
      RtiListFilter(
        fromDate: fromDate ?? this.fromDate,
        toDate: toDate ?? this.toDate,
        driverId: driverId ?? this.driverId,
        driverName: driverName ?? this.driverName,
        truckId: truckId ?? this.truckId,
        truckName: truckName ?? this.truckName,
        rtiNo: rtiNo ?? this.rtiNo,
        myRtis: myRtis ?? this.myRtis,
        notSalary: notSalary ?? this.notSalary,
      );

  @override
  List<Object?> get props => [fromDate, toDate, driverId, driverName, truckId, truckName, rtiNo, myRtis, notSalary];
}
