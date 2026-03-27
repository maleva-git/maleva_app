import 'package:maleva/core/models/model.dart';

// ── Filter constants ──────────────────────────────────────────────────────────
const kExpenseFilters = [
  'All', 'Hire Purchase', 'Vendor', 'Utility', 'Tenancy', 'Monthly Purpose'
];
const kPaidFilters = ['All Payments', 'Paid', 'Not Paid'];

// ── SID mapping ───────────────────────────────────────────────────────────────
int expenseFilterToSid(String filter) {
  const map = {
    'All': 0, 'Hire Purchase': 1, 'Vendor': 2,
    'Utility': 3, 'Tenancy': 4, 'Monthly Purpose': 5,
  };
  return map[filter] ?? 0;
}

int paidFilterToSid(String filter) {
  const map = {'All Payments': 0, 'Paid': 1, 'Not Paid': 2};
  return map[filter] ?? 0;
}

// ─────────────────────────────────────────────────────────────────────────────
abstract class PaymentPendingState {
  const PaymentPendingState();
}

// ── Loading ───────────────────────────────────────────────────────────────────
class PaymentPendingLoading extends PaymentPendingState {
  final String selectedFilter;
  final String selectedPaidFilter;
  final DateTime fromDate;
  final DateTime toDate;

  const PaymentPendingLoading({
    required this.selectedFilter,
    required this.selectedPaidFilter,
    required this.fromDate,
    required this.toDate,
  });
}

// ── Loaded ────────────────────────────────────────────────────────────────────
class PaymentPendingLoaded extends PaymentPendingState {
  final List<PaymentPendingModel> masterList;
  final List<PaymentPendingModel> detailsList;
  final String selectedFilter;
  final String selectedPaidFilter;
  final DateTime fromDate;
  final DateTime toDate;
  final PaymentPendingModel? selectedItem;

  const PaymentPendingLoaded({
    required this.masterList,
    required this.detailsList,
    required this.selectedFilter,
    required this.selectedPaidFilter,
    required this.fromDate,
    required this.toDate,
    this.selectedItem,
  });

  // Computed: filtered master list
  List<PaymentPendingModel> get filteredMaster {
    return masterList.where((m) {
      bool matchesExpense = selectedFilter == 'All' ||
          (m.SubExpenseName != null &&
              m.SubExpenseName!
                  .toLowerCase()
                  .contains(selectedFilter.toLowerCase())) ||
          (m.ExpenseName != null &&
              m.ExpenseName!
                  .toLowerCase()
                  .contains(selectedFilter.toLowerCase()));
      return matchesExpense;
    }).toList();
  }

  // Computed: total
  double get totalAmount =>
      filteredMaster.fold(0.0, (sum, m) => sum + (m.Amount ?? 0));

  // Related details for a master record
  List<PaymentPendingModel> relatedDetails(PaymentPendingModel master) {
    return detailsList.where((detail) =>
    detail.SubExpenseName?.toLowerCase().contains(
        master.SubExpenseName!.split(" ")[0].toLowerCase()
    ) ?? false
    ).toList();
  }

  PaymentPendingLoaded copyWith({
    List<PaymentPendingModel>? masterList,
    List<PaymentPendingModel>? detailsList,
    String? selectedFilter,
    String? selectedPaidFilter,
    DateTime? fromDate,
    DateTime? toDate,
    PaymentPendingModel? selectedItem,
    bool clearSelected = false,
  }) {
    return PaymentPendingLoaded(
      masterList: masterList ?? this.masterList,
      detailsList: detailsList ?? this.detailsList,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      selectedPaidFilter: selectedPaidFilter ?? this.selectedPaidFilter,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      selectedItem: clearSelected
          ? null
          : (selectedItem ?? this.selectedItem),
    );
  }

  @override
  List<Object?> get props => [
    masterList, detailsList, selectedFilter,
    selectedPaidFilter, fromDate, toDate,
  ];
}

// ── Error ─────────────────────────────────────────────────────────────────────
class PaymentPendingError extends PaymentPendingState {
  final String message;
  final String selectedFilter;
  final String selectedPaidFilter;
  final DateTime fromDate;
  final DateTime toDate;

  const PaymentPendingError({
    required this.message,
    required this.selectedFilter,
    required this.selectedPaidFilter,
    required this.fromDate,
    required this.toDate,
  });
}