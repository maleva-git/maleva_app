import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/colors/colors.dart' as colour;
import '../bloc/paymentview_bloc.dart';
import '../bloc/paymentview_event.dart';
import '../bloc/paymentview_state.dart';

// ── Entry Point ───────────────────────────────────────────────────────────────
class PaymentPendingPage extends StatelessWidget {
  const PaymentPendingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PaymentPendingBloc(context),
      child: const _PaymentPendingBody(),
    );
  }
}

// ── Body (uses DefaultTabController for expense tabs) ─────────────────────────
class _PaymentPendingBody extends StatelessWidget {
  const _PaymentPendingBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PaymentPendingBloc, PaymentPendingState>(
      builder: (context, state) {
        final expFilter  = _expFilter(state);
        final paidFilter = _paidFilter(state);
        final fromDate   = _fromDate(state);
        final toDate     = _toDate(state);
        final isLoading  = state is PaymentPendingLoading;
        final loaded     = state is PaymentPendingLoaded ? state : null;

        final expIdx = kExpenseFilters.indexOf(expFilter).clamp(0, kExpenseFilters.length - 1);

        return DefaultTabController(
          length: kExpenseFilters.length,
          initialIndex: expIdx,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ════════════════════════════════════════════════════
              // TAB BAR — Expense categories
              // ════════════════════════════════════════════════════
              Container(
                color: colour.kPrimary,
                child: TabBar(
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  indicatorColor: colour.kWhite,
                  indicatorWeight: 3,
                  labelColor: colour.kWhite,
                  unselectedLabelColor: colour.kWhite.withOpacity(0.55),
                  labelStyle: GoogleFonts.lato(
                      fontWeight: FontWeight.bold, fontSize: 13),
                  unselectedLabelStyle:
                  GoogleFonts.lato(fontSize: 13),
                  dividerColor: Colors.transparent,
                  onTap: (i) => context
                      .read<PaymentPendingBloc>()
                      .add(SelectExpenseFilterEvent(kExpenseFilters[i])),
                  tabs: kExpenseFilters
                      .map((f) => Tab(text: f))
                      .toList(),
                ),
              ),

              // ════════════════════════════════════════════════════
              // PAID FILTER — segmented control style
              // ════════════════════════════════════════════════════
              Container(
                color: colour.kPrimary.withOpacity(0.06),
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                child: Row(
                  children: kPaidFilters.map((f) {
                    final active = paidFilter == f;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => context
                            .read<PaymentPendingBloc>()
                            .add(SelectPaidFilterEvent(f)),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          margin: const EdgeInsets.symmetric(
                              horizontal: 3),
                          padding: const EdgeInsets.symmetric(
                              vertical: 9),
                          decoration: BoxDecoration(
                            color: active
                                ? colour.kPrimary
                                : colour.kAccent,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: active
                                    ? colour.kPrimary
                                    : colour.kPrimaryLight
                                    .withOpacity(0.25)),
                          ),
                          child: Text(f,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.lato(
                                  fontSize: 12,
                                  fontWeight: active
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: active
                                      ? colour.kWhite
                                      : colour.kPrimaryDark)),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              // ════════════════════════════════════════════════════
              // DATE FILTER BAR
              // ════════════════════════════════════════════════════
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 4),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 9),
                  decoration: BoxDecoration(
                    color: colour.kAccent,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: colour.kPrimaryLight.withOpacity(0.3)),
                  ),
                  child: Row(children: [
                    Expanded(
                        child: _dateCell(
                          context: context,
                          label: "From",
                          value: DateFormat('dd-MM-yy').format(fromDate),
                          onTap: () => _pickDate(
                              context, fromDate,
                                  (d) => context
                                  .read<PaymentPendingBloc>()
                                  .add(SelectFromDateEvent(d))),
                        )),
                    _calBtn(() => _pickDate(
                        context, fromDate,
                            (d) => context
                            .read<PaymentPendingBloc>()
                            .add(SelectFromDateEvent(d)))),
                    Container(
                        width: 1, height: 28,
                        color: colour.kPrimaryLight.withOpacity(0.3),
                        margin: const EdgeInsets.symmetric(
                            horizontal: 8)),
                    Expanded(
                        child: _dateCell(
                          context: context,
                          label: "To",
                          value: DateFormat('dd-MM-yy').format(toDate),
                          onTap: () => _pickDate(
                              context, toDate,
                                  (d) => context
                                  .read<PaymentPendingBloc>()
                                  .add(SelectToDateEvent(d))),
                        )),
                    _calBtn(() => _pickDate(
                        context, toDate,
                            (d) => context
                            .read<PaymentPendingBloc>()
                            .add(SelectToDateEvent(d)))),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () => context
                          .read<PaymentPendingBloc>()
                          .add(const SearchByDateEvent()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colour.kPrimary,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      child: Text("Search",
                          style: GoogleFonts.lato(
                              color: colour.kWhite,
                              fontWeight: FontWeight.bold,
                              fontSize: 13)),
                    ),
                  ]),
                ),
              ),

              // ════════════════════════════════════════════════════
              // TOTAL SUMMARY STRIP
              // ════════════════════════════════════════════════════
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 4),
                child: Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: colour.kPrimary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(children: [
                      const Icon(Icons.account_balance_wallet_rounded,
                          color: colour.kWhite, size: 16),
                      const SizedBox(width: 6),
                      Text("Total: ",
                          style: GoogleFonts.lato(
                              color: colour.kWhite,
                              fontSize: 13,
                              fontWeight: FontWeight.w500)),
                      Text(
                        "RM ${loaded?.totalAmount.toStringAsFixed(2) ?? '0.00'}",
                        style: GoogleFonts.lato(
                            color: colour.kWhite,
                            fontSize: 14,
                            fontWeight: FontWeight.bold),
                      ),
                    ]),
                  ),
                  const Spacer(),
                  if (isLoading)
                    const SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: colour.kPrimary),
                    ),
                  Text(
                    "${loaded?.filteredMaster.length ?? 0} records",
                    style: GoogleFonts.lato(
                        color: Colors.grey[500], fontSize: 12),
                  ),
                ]),
              ),

              const SizedBox(height: 4),

              // ════════════════════════════════════════════════════
              // GRID LIST
              // ════════════════════════════════════════════════════
              Expanded(
                child: isLoading
                    ? const Center(
                    child: CircularProgressIndicator(
                        color: colour.kPrimary))
                    : state is PaymentPendingError
                    ? _errorView(context, state.message)
                    : loaded == null ||
                    loaded.filteredMaster.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                          Icons
                              .receipt_long_outlined,
                          size: 60,
                          color: Colors.grey.shade300),
                      const SizedBox(height: 12),
                      Text("No Records Found",
                          style: GoogleFonts.lato(
                              fontSize: 16,
                              color: Colors.grey)),
                    ],
                  ),
                )
                    : GridView.builder(
                  padding: const EdgeInsets.fromLTRB(
                      10, 4, 10, 20),
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.82,
                  ),
                  itemCount:
                  loaded.filteredMaster.length,
                  itemBuilder: (_, i) {
                    final item =
                    loaded.filteredMaster[i];
                    return _PaymentGridCard(
                      item: item,
                      onTap: () => _showDetailSheet(
                          context,
                          item,
                          loaded.relatedDetails(item)),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Date picker helper ──────────────────────────────────────────────────
  Future<void> _pickDate(
      BuildContext context,
      DateTime initial,
      ValueChanged<DateTime> onPicked) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
            colorScheme:
            const ColorScheme.light(primary: colour.kPrimary)),
        child: child!,
      ),
    );
    if (picked != null) onPicked(picked);
  }

  // ── Detail Bottom Sheet ─────────────────────────────────────────────────
  void _showDetailSheet(
      BuildContext context,
      PaymentPendingModel master,
      List<PaymentPendingModel> related) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DetailSheet(master: master, related: related),
    );
  }

  // ── Error view ──────────────────────────────────────────────────────────
  Widget _errorView(BuildContext context, String msg) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.error_outline, color: Colors.red, size: 48),
        const SizedBox(height: 12),
        Text(msg,
            textAlign: TextAlign.center,
            style: GoogleFonts.lato(color: Colors.red)),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () => context
              .read<PaymentPendingBloc>()
              .add(const LoadPaymentPendingEvent()),
          icon: const Icon(Icons.refresh),
          label: const Text("Retry"),
          style:
          ElevatedButton.styleFrom(backgroundColor: colour.kPrimary),
        ),
      ]),
    );
  }

  // ── State helpers ───────────────────────────────────────────────────────
  String _expFilter(PaymentPendingState s) {
    if (s is PaymentPendingLoading) return s.selectedFilter;
    if (s is PaymentPendingLoaded) return s.selectedFilter;
    if (s is PaymentPendingError) return s.selectedFilter;
    return 'All';
  }

  String _paidFilter(PaymentPendingState s) {
    if (s is PaymentPendingLoading) return s.selectedPaidFilter;
    if (s is PaymentPendingLoaded) return s.selectedPaidFilter;
    if (s is PaymentPendingError) return s.selectedPaidFilter;
    return 'All Payments';
  }

  DateTime _fromDate(PaymentPendingState s) {
    if (s is PaymentPendingLoading) return s.fromDate;
    if (s is PaymentPendingLoaded) return s.fromDate;
    if (s is PaymentPendingError) return s.fromDate;
    return DateTime.now();
  }

  DateTime _toDate(PaymentPendingState s) {
    if (s is PaymentPendingLoading) return s.toDate;
    if (s is PaymentPendingLoaded) return s.toDate;
    if (s is PaymentPendingError) return s.toDate;
    return DateTime.now().add(const Duration(days: 6));
  }
}

// ── 2-Column Grid Card ────────────────────────────────────────────────────────
class _PaymentGridCard extends StatelessWidget {
  final PaymentPendingModel item;
  final VoidCallback onTap;
  const _PaymentGridCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Paid status colour
    final isPaid = item.Paiddate != null &&
        item.Paiddate!.isNotEmpty &&
        item.Paiddate != '-';
    final statusColor = isPaid ? Colors.green : Colors.orange;
    final statusLabel = isPaid ? "Paid" : "Pending";

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: colour.kWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colour.kAccent, width: 1.5),
          boxShadow: [
            BoxShadow(
                color: colour.kPrimary.withOpacity(0.07),
                blurRadius: 8,
                offset: const Offset(0, 3)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Top colour band ───────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: colour.kPrimary,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16)),
              ),
              child: Row(children: [
                Expanded(
                  child: Text(
                    item.ExpenseName ?? '-',
                    style: GoogleFonts.lato(
                        color: colour.kWhite,
                        fontWeight: FontWeight.bold,
                        fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ]),
            ),

            // ── Body ─────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // Amount
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        color: colour.kAccent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "RM ${(item.Amount ?? 0).toStringAsFixed(2)}",
                        style: GoogleFonts.lato(
                            color: colour.kPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Bank
                    _gridRow(Icons.account_balance_rounded,
                        item.BankName ?? '-'),
                    const SizedBox(height: 4),

                    // Sub expense
                    _gridRow(Icons.category_rounded,
                        item.SubExpenseName ?? '-'),
                    const SizedBox(height: 4),

                    // Due date
                    _gridRow(Icons.event_rounded,
                        item.ExpenceDueDate?.toString() ?? '-'),
                    const Spacer(),

                    // Status badge
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: statusColor.withOpacity(0.4)),
                        ),
                        child: Text(statusLabel,
                            style: GoogleFonts.lato(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: statusColor)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _gridRow(IconData icon, String text) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, size: 13, color: colour.kPrimaryLight),
      const SizedBox(width: 4),
      Expanded(
        child: Text(text,
            style: GoogleFonts.lato(
                fontSize: 11, color: Colors.black54),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
      ),
    ]);
  }
}

// ── Calendar button ───────────────────────────────────────────────────────────
Widget _calBtn(VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: 34, height: 34,
      decoration: BoxDecoration(
          color: colour.kPrimary,
          borderRadius: BorderRadius.circular(8)),
      child: const Icon(Icons.calendar_month_outlined,
          color: colour.kWhite, size: 18),
    ),
  );
}

// ── Date cell ─────────────────────────────────────────────────────────────────
Widget _dateCell({
  required BuildContext context,
  required String label,
  required String value,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: GoogleFonts.lato(
              fontSize: 10,
              color: Colors.grey[500],
              fontWeight: FontWeight.w600)),
      Text(value,
          style: GoogleFonts.lato(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: colour.kPrimaryDark)),
    ]),
  );
}

// ── Detail Bottom Sheet ───────────────────────────────────────────────────────
class _DetailSheet extends StatelessWidget {
  final PaymentPendingModel master;
  final List<PaymentPendingModel> related;
  const _DetailSheet({required this.master, required this.related});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.55,
      maxChildSize: 0.9,
      builder: (_, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: colour.kWhite,
            borderRadius:
            BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(children: [

            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 4),
              width: 50, height: 5,
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(3)),
            ),

            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
              decoration: const BoxDecoration(
                color: colour.kPrimary,
                borderRadius:
                BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Row(children: [
                const Icon(Icons.receipt_long_rounded,
                    color: colour.kWhite, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(master.ExpenseName ?? '',
                            style: GoogleFonts.lato(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: colour.kWhite),
                            overflow: TextOverflow.ellipsis),
                        Text("Bank: ${master.BankName ?? '-'}",
                            style: GoogleFonts.lato(
                                color: colour.kWhite.withOpacity(0.75),
                                fontSize: 12)),
                      ]),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 30, height: 30,
                    decoration: BoxDecoration(
                        color: colour.kWhite.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(15)),
                    child: const Icon(Icons.close,
                        color: colour.kWhite, size: 16),
                  ),
                ),
              ]),
            ),

            // Master summary row
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(children: [
                _summaryChip(Icons.event_rounded,
                    "Due: ${master.ExpenceDueDate ?? '-'}"),
                const SizedBox(width: 8),
                _summaryChip(Icons.payments_rounded,
                    "RM ${(master.Amount ?? 0).toStringAsFixed(2)}"),
              ]),
            ),

            Divider(color: colour.kAccent, thickness: 1.5, height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text("Details",
                    style: GoogleFonts.lato(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: colour.kPrimaryDark)),
              ),
            ),

            const SizedBox(height: 8),

            // Detail list
            Expanded(
              child: related.isEmpty
                  ? Center(
                  child: Text("No detail records",
                      style: GoogleFonts.lato(color: Colors.grey)))
                  : ListView.builder(
                controller: controller,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 4),
                itemCount: related.length,
                itemBuilder: (_, i) {
                  final d = related[i];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: colour.kAccent,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: colour.kPrimaryLight
                              .withOpacity(0.2)),
                    ),
                    child: Row(children: [
                      Expanded(
                        child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(d.SubExpenseName ?? '-',
                                  style: GoogleFonts.lato(
                                      fontWeight: FontWeight.w600,
                                      color: colour.kPrimaryDark,
                                      fontSize: 14)),
                              const SizedBox(height: 2),
                              Text("Due: ${d.DueDate ?? '-'}",
                                  style: GoogleFonts.lato(
                                      color: Colors.grey[500],
                                      fontSize: 12)),
                            ]),
                      ),
                      Text(
                        "RM ${(d.Amount ?? 0).toStringAsFixed(2)}",
                        style: GoogleFonts.lato(
                            fontWeight: FontWeight.bold,
                            color: colour.kPrimary,
                            fontSize: 15),
                      ),
                    ]),
                  );
                },
              ),
            ),

            // Close button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colour.kPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text("Close",
                      style: GoogleFonts.lato(
                          color: colour.kWhite,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ]),
        );
      },
    );
  }

  Widget _summaryChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colour.kAccent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colour.kPrimaryLight.withOpacity(0.3)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 13, color: colour.kPrimary),
        const SizedBox(width: 5),
        Text(label,
            style: GoogleFonts.lato(
                fontSize: 12,
                color: colour.kPrimaryDark,
                fontWeight: FontWeight.w600)),
      ]),
    );
  }
}